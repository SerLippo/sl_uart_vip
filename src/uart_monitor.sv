`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

class uart_monitor extends uvm_monitor;

  virtual uart_if vif;
  uart_config cfg;
  logic[15:0] divisor;
  uart_transaction trans_collected;
  uvm_analysis_port#(uart_transaction) item_mon_ana_port;

  bit sbe;
  bit pe;
  bit fe;
  logic clk;
  logic parity;
  logic[7:0] rx_data;

  `uvm_component_utils_begin(uart_monitor)
  `uvm_component_utils_end

  function new(string name="uart_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    item_mon_ana_port = new("item_mon_ana_port", this);
    if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("UART_MON", "UART_monitor can't get uart_config object from uvm_config_db!")
    divisor = cfg.baud_divisor;
    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_MON", "UART_monitor can't get virtual uart_if object from uvm_config_db!")
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    repeat(3)
      @(posedge vif.clk);
    forever begin
      trans_collected = new("trans_collected");
      fork
        monitor_trans();
        sbe_detect();
      join_any
      disable fork;
      if(!sbe) begin
        trans_collected.data = rx_data;
        trans_collected.pe = pe;
        trans_collected.fe = fe;
        item_mon_ana_port.write(trans_collected);
        rx_data = 0;
      end
    end
  endtask: run_phase

  protected task sbe_detect();
    int i;
    int start_bit = 0;
    sbe = 0;
    trans_collected.sbe = 0;
    while(vif.sdata==1'b1 || vif.sdata==1'bx)
      @(posedge vif.clk);
    start_bit = 1;
    start_bit = 99;
    while(sbe!=1 || i<8) begin
      @(posedge vif.clk);
      if(vif.sdata==1'b1) begin
        `uvm_warning("UART_MON", "False start bit detected!")
        start_bit = 88;
        sbe = 1;
        trans_collected.sbe = 1;
      end
      i++;
      start_bit = i;
    end
    if(!sbe)
      forever
        @(posedge vif.clk);
  endtask: sbe_detect

  protected task monitor_trans();
    int start_bit;
    // Wait for a falling edge on txd
    fe = 0;
    rx_data = 0;
    while(vif.sdata==1'b1 || vif.sdata==1'bx)
      @(posedge vif.clk);
    start_bit = 1;

    // Ignore correct start bit and sample bits 0-4
    repeat(23)
      wait_posedge_divised_clk(divisor);
    start_bit = 0;
    rx_data[0] = vif.sdata;
    bit_period(divisor);
    rx_data[1] = vif.sdata;
    bit_period(divisor);
    rx_data[2] = vif.sdata;
    bit_period(divisor);
    rx_data[3] = vif.sdata;
    bit_period(divisor);
    rx_data[4] = vif.sdata;
    // Sample bits 5-7
    casex(cfg.lcr[3:0])
      4'b0x00: begin
      end
      4'b1x00: begin
        bit_period(divisor);
        parity = vif.sdata;
      end
      4'b0x01: begin
        bit_period(divisor);
        rx_data[5] = vif.sdata;
      end
      4'b1x01: begin
        bit_period(divisor);
        rx_data[5] = vif.sdata;
        bit_period(divisor);
        parity = vif.sdata;
      end
      4'b0x10: begin
        bit_period(divisor);
        rx_data[5] = vif.sdata;
        bit_period(divisor);
        rx_data[6] = vif.sdata;
      end
      4'b1x10: begin
        bit_period(divisor);
        rx_data[5] = vif.sdata;
        bit_period(divisor);
        rx_data[6] = vif.sdata;
        bit_period(divisor);
        parity = vif.sdata;
      end
      4'b0x11: begin
        bit_period(divisor);
        rx_data[5] = vif.sdata;
        bit_period(divisor);
        rx_data[6] = vif.sdata;
        bit_period(divisor);
        rx_data[7] = vif.sdata;
      end
      4'b1x11: begin
        bit_period(divisor);
        rx_data[5] = vif.sdata;
        bit_period(divisor);
        rx_data[6] = vif.sdata;
        bit_period(divisor);
        rx_data[7] = vif.sdata;
        bit_period(divisor);
        parity = vif.sdata;
      end
    endcase
    if(cfg.lcr[3]) begin
      pe = parity==logic'(cal_parity(cfg.lcr, rx_data)) ? 0:1;
    end
    // Check framing error
    repeat(8)
      wait_posedge_divised_clk(divisor);
    repeat(8) begin
      wait_posedge_divised_clk(divisor);
      if(vif.sdata == 1'b0)
        fe = 1;
    end
  endtask: monitor_trans

  protected function bit cal_parity(logic[7:0] lcr, logic[7:0] data);
    bit parity;
    if(lcr[5]) begin
      case(lcr[4])
        1'b0: parity = 1'b1;
        1'b1: parity = 1'b0;
      endcase
    end
    else begin
      case(lcr[1:0])
        2'b00: parity = ^data[4:0];
        2'b01: parity = ^data[5:0];
        2'b10: parity = ^data[6:0];
        2'b11: parity = ^data[7:0];
      endcase
      if(!lcr[4])
        parity = ~parity;
    end
    return parity;
  endfunction: cal_parity

  protected task wait_posedge_divised_clk(logic[15:0] divisor);
    repeat(divisor)
      @(posedge vif.clk);
  endtask: wait_posedge_divised_clk

  protected task bit_period(logic[15:0] divisor);
    repeat(16)
      wait_posedge_divised_clk(divisor);
  endtask: bit_period

endclass: uart_monitor

`endif
`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

class uart_driver extends uvm_driver#(uart_transaction);

  virtual uart_if vif;
  uart_config cfg;
  logic [15:0] divisor;

  `uvm_component_utils_begin(uart_driver)
  `uvm_component_utils_end

  function new(string name="uart_driver", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("UART_DRV", "UART_driver can't get uart_config object from uvm_config_db!")
    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_DRV", "UART_driver can't get virtual uart_if object from uvm_config_db!")
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    get_and_drive();
  endtask: run_phase

  protected task get_and_drive();
    int bit_ptr = 0;
    vif.sdata = 1;
    forever begin
      seq_item_port.get_next_item(req);
      divisor = req.baud_divisor;

      // Veriable delay
      repeat(req.delay)
        wait_posedge_divised_clk(divisor);
      if(req.sbe) begin
        vif.sdata = 0;
        repeat(req.sbe_clks)
          wait_posedge_divised_clk(divisor);
        vif.sdata = 1;
        repeat(req.sbe_clks)
          wait_posedge_divised_clk(divisor);
      end
      // Start bit
      vif.sdata = 0;
      bit_ptr = 0;
      bit_period(divisor);
      // Data bits 0-4
      while(bit_ptr<5) begin
        vif.sdata = req.data[bit_ptr];
        bit_period(divisor);
        bit_ptr++;
      end
      // Data bits 5-7
      if(req.lcr[1:0]>2'b00) begin
        vif.sdata = req.data[5];
        bit_period(divisor);
      end
      if(req.lcr[1:0]>2'b01) begin
        vif.sdata = req.data[6];
        bit_period(divisor);
      end
      if(req.lcr[1:0]>2'b10) begin
        vif.sdata = req.data[7];
        bit_period(divisor);
      end
      // Parity
      if(req.lcr[3]) begin
        vif.sdata = logic'(cal_parity(req.lcr, req.data));
        if(req.pe)
          vif.sdata = ~vif.sdata;
        bit_period(divisor);
      end
      // Stop bit
      if(!req.fe)
        vif.sdata = 1;
      else
        vif.sdata = 0;
      bit_period(divisor);
      if(!req.fe) begin
        if(pkt.lcr[2]) begin
          if(req.lcr[1:0]==2'b00) begin
            repeat(8)
              wait_posedge_divised_clk(divisor);
          end
          else
            bit_period(divisor);
        end
      end
      else begin
        vif.sdata = 1;
        bit_period(divisor);
      end

      void'($cast(rsp, req.clone()));
      rsp.set_sequence_id(req.get_sequence_id());
      rsp.set_transaction_id(req.get_transaction_id());
      seq_item_port.item_done(rsp);
    end
  endtask: get_and_drive

  protected task wait_posedge_divised_clk(logic[15:0] divisor);
    repeat(divisor)
      @(posedge vif.clk);
  endtask: wait_posedge_divised_clk

  protected task bit_period(logic[15:0] divisor);
    repeat(16)
      wait_posedge_divised_clk(divisor);
  endtask: bit_period

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

endclass: uart_driver

`endif
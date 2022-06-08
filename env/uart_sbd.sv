`ifndef UART_SBD_SV
`define UART_SBD_SV

class uart_sbd extends uvm_component;

  int tx_count, rx_count;
  int total_count;
  uvm_tlm_analysis_fifo#(uart_transaction) dte_tx_ana_fifo;
  uvm_tlm_analysis_fifo#(uart_transaction) dce_tx_ana_fifo;
  uvm_tlm_analysis_fifo#(uart_transaction) dte_rx_ana_fifo;
  uvm_tlm_analysis_fifo#(uart_transaction) dce_rx_ana_fifo;

  `uvm_component_utils_begin(uart_sbd)
    `uvm_field_int(total_count, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="uart_sbd", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dte_tx_ana_fifo = new("dte_tx_ana_fifo", this);
    dce_tx_ana_fifo = new("dce_tx_ana_fifo", this);
    dte_rx_ana_fifo = new("dte_rx_ana_fifo", this);
    dce_rx_ana_fifo = new("dce_rx_ana_fifo", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    uart_transaction dte_tx, dce_tx;
    uart_transaction dte_rx, dce_rx;
    fork
      forever begin: tx_compare
        fork
          dte_tx_ana_fifo.get(dte_tx);
          dce_tx_ana_fifo.get(dce_tx);
        join
        check_uart_trans(dte_tx, dce_tx, 1);
      end
      forever begin: rx_compare
        fork
          dte_rx_ana_fifo.get(dte_rx);
          dce_rx_ana_fifo.get(dce_rx);
        join
        check_uart_trans(dce_rx, dte_rx, 0);
      end
    join_none
  endtask: run_phase

  function void check_uart_trans(uart_transaction req, uart_transaction rsp, bit is_tx);
    int err_cnt;
    if(req.data != rsp.data) begin
      err_cnt++;
      `uvm_error("SBD", $sformatf("Compare Error! req.data: 0x%0x, rsp.data: 0x%0x.", req.data, rsp.data))
    end
    if(req.lcr != rsp.lcr) begin
      err_cnt++;
      `uvm_error("SBD", $sformatf("Compare Error! req.lcr: 0x%0x, rsp.lcr: 0x%0x.", req.lcr, rsp.lcr))
    end
    if(req.baud_divisor != rsp.baud_divisor) begin
      err_cnt++;
      `uvm_error("SBD", $sformatf("Compare Error! req.baud_divisor: 0x%0x, rsp.baud_divisor: 0x%0x.", req.baud_divisor, rsp.baud_divisor))
    end
    if(req.sbe != rsp.sbe) begin
      err_cnt++;
      `uvm_error("SBD", $sformatf("Compare Error! req.sbe: 0x%0x, rsp.sbe: 0x%0x.", req.sbe, rsp.sbe))
    end
    if(req.fe != rsp.fe) begin
      err_cnt++;
      `uvm_error("SBD", $sformatf("Compare Error! req.fe: 0x%0x, rsp.fe: 0x%0x.", req.fe, rsp.fe))
    end
    if(req.pe != rsp.pe) begin
      err_cnt++;
      `uvm_error("SBD", $sformatf("Compare Error! req.pe: 0x%0x, rsp.pe: 0x%0x.", req.pe, rsp.pe))
    end
    if(!err_cnt)
      if(is_tx) begin
        `uvm_info("SBD", $sformatf("Compare Success for the tx %0d th time, total %0d th time!", tx_count, total_count), UVM_LOW)
        tx_count++;
      end
      else begin
        `uvm_info("SBD", $sformatf("Compare Success for the rx %0d th time, total %0d th time!", rx_count, total_count), UVM_LOW)
        rx_count++;
      end
    else
      if(is_tx) begin
        `uvm_error("SBD", $sformatf("Compare Failed for the tx %0d th time, total %0d th time!", tx_count, total_count))
        req.print();
        rsp.print();
        tx_count++;
      end
      else begin
        `uvm_error("SBD", $sformatf("Compare Failed for the rx %0d th time, total %0d th time!", rx_count, total_count))
        req.print();
        rsp.print();
        rx_count++;
      end
    total_count++;
  endfunction: check_uart_trans

endclass: uart_sbd

`endif
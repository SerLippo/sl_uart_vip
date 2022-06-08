`ifndef UART_ENV_SV
`define UART_ENV_SV

class uart_env extends uvm_env;

  uart_agent dte_tx;
  uart_agent dte_rx;
  uart_agent dce_tx;
  uart_agent dce_rx;
  uart_sbd sbd;

  `uvm_component_utils(uart_env)

  function new(string name="uart_env", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dte_tx = uart_agent::type_id::create("dte_tx", this);
    dte_rx = uart_agent::type_id::create("dte_rx", this);
    dce_tx = uart_agent::type_id::create("dce_tx", this);
    dce_rx = uart_agent::type_id::create("dce_rx", this);
    sbd = uart_sbd::type_id::create("sbd", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dte_tx.mon.item_mon_ana_port.connect(sbd.dte_tx_ana_fifo.analysis_export);
    dte_rx.mon.item_mon_ana_port.connect(sbd.dte_rx_ana_fifo.analysis_export);
    dce_tx.mon.item_mon_ana_port.connect(sbd.dce_tx_ana_fifo.analysis_export);
    dce_rx.mon.item_mon_ana_port.connect(sbd.dce_rx_ana_fifo.analysis_export);
  endfunction: connect_phase

endclass: uart_env

`endif
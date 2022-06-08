`ifndef UART_SEQUENCER_SV
`define UART_SEQUENCER_SV

class uart_sequencer extends uvm_sequencer#(uart_transaction);

  virtual uart_if vif;
  uart_config cfg;

  `uvm_component_utils(uart_sequencer)

  function new(string name="uart_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("UART_SQR", "UART_sequencer can't get uart_config object from uvm_config_db!")
    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_SQR", "UART_sequencer can't get virtual uart_if object from uvm_config_db!")
  endfunction: build_phase

endclass: uart_sequencer

`endif
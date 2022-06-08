`ifndef UART_BASE_HSEQ_SV
`define UART_BASE_HSEQ_SV

class uart_base_hseq extends uvm_sequence#(uart_transaction);

  virtual uart_if vif;
  uart_config cfg;

  `uvm_declare_p_sequencer(uart_sequencer)
  `uvm_object_utils_begin(uart_base_hseq)
  `uvm_object_utils_end

  function new(string name="uart_base_hseq");
    super.new(name);
  endfunction: new

  task body();
    vif = p_sequencer.vif;
    cfg = p_sequencer.cfg;
  endtask: body

endclass: uart_base_hseq

`endif
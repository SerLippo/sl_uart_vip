`ifndef UART_SINGLE_HSEQ_SV
`define UART_SINGLE_HSEQ_SV

class uart_single_hseq extends uart_base_hseq;

  `uvm_object_utils_begin(uart_single_hseq)
  `uvm_object_utils_end

  function new(string name="uart_single_hseq");
    super.new(name);
  endfunction: new

  task body();
    uart_burst_seq seq;
    super.body();
    req = uart_transaction::type_id::create("req");
    start_item(req);
    req.randomize();
    finish_item(req);
    get_response(rsp);
    seq = uart_burst_seq::type_id::create("seq");
    seq.randomize() with {size==10;};
    seq.start(m_sequencer, this);
  endtask: body

endclass: uart_single_hseq

`endif
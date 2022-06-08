`ifndef UART_SINGLE_TEST_SV
`define UART_SINGLE_TEST_SV

class uart_single_test extends uart_base_test;

  `uvm_component_utils_begin(uart_single_test)
  `uvm_component_utils_end

  function new(string name="uart_single_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = uart_config::type_id::create("cfg");
    uvm_config_db#(uart_config)::set(this, "env.*", "cfg", cfg);
    env = uart_env::type_id::create("env", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    uart_single_hseq seq = uart_single_hseq::type_id::create("seq");
    phase.raise_objection(this);
    super.run_phase(phase);
    seq.start(env.dte_tx.sqr);
    phase.drop_objection(this);
  endtask: run_phase

endclass: uart_single_test

`endif
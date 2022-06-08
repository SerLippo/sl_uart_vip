`ifndef UART_DUAL_TEST_SV
`define UART_DUAL_TEST_SV

class uart_dual_test extends uart_base_test;

  `uvm_component_utils_begin(uart_dual_test)
  `uvm_component_utils_end

  function new(string name="uart_dual_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = uart_config::type_id::create("cfg");
    uvm_config_db#(uart_config)::set(this, "env.*", "cfg", cfg);
    env = uart_env::type_id::create("env", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    uart_single_hseq seq_dte = uart_single_hseq::type_id::create("seq_dte");
    uart_single_hseq seq_dce = uart_single_hseq::type_id::create("seq_dce");
    phase.raise_objection(this);
    super.run_phase(phase);
    fork
      seq_dte.start(env.dte_tx.sqr);
      seq_dce.start(env.dce_rx.sqr);
    join
    phase.drop_objection(this);
  endtask: run_phase

endclass: uart_dual_test

`endif
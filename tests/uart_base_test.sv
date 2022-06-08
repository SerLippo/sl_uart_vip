`ifndef UART_BASE_TEST_SV
`define UART_BASE_TEST_SV

class uart_base_test extends uvm_test;

  uart_env env;
  uart_config cfg;

  `uvm_component_utils_begin(uart_base_test)
  `uvm_component_utils_end

  function new(string name="uart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction: connect_phase

endclass: uart_base_test

`endif
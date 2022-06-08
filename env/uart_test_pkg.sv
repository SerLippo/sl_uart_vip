`ifndef UART_TEST_PKG_SV
`define UART_TEST_PKG_SV

`include "uart_define.sv"

package uart_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_pkg::*;

  `include "uart_sbd.sv"
  `include "uart_env.sv"
  `include "uart_sequences.svh"
  `include "uart_tests.svh"

endpackage: uart_test_pkg

`endif
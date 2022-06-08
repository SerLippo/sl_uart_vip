`ifndef UART_TB_SV
`define UART_TB_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import uart_test_pkg::*;

module uart_tb;

  logic clk, tx, rx;

  uart_if dte_tx_if();
  uart_if dte_rx_if();
  uart_if dce_tx_if();
  uart_if dce_rx_if();

  assign dte_tx_if.clk = clk;
  assign dte_rx_if.clk = clk;
  assign dce_tx_if.clk = clk;
  assign dce_rx_if.clk = clk;

  assign tx = dte_tx_if.sdata;
  assign dte_rx_if.sdata = rx;
  assign dce_tx_if.sdata = tx;
  assign rx = dce_rx_if.sdata;

  initial begin
    forever
      #5 clk <= ~clk;
  end

  initial begin
    clk <= 0;
  end

  initial begin
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top.env.dte_tx", "vif", dte_tx_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top.env.dte_rx", "vif", dte_rx_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top.env.dce_tx", "vif", dce_tx_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top.env.dce_rx", "vif", dce_rx_if);
    run_test();
  end

endmodule: uart_tb

`endif
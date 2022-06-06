`ifndef UART_CONFIG_SV
`define UART_CONFIG_SV

class uart_config extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Register config
  // Line Control Register
  // [1:0]: dicide the data's width
  //        2'b00: 5 bits;
  //        2'b01: 6 bits;
  //        2'b10: 7 bits;
  //        2'b11: 8 bits;
  // [2]: decide the stop-bit's width
  //        1'b0: 1 bit;
  //        1'b1: 2 bits when the data's width is 6, 7 or 8;
  //              1.5 btis when the data's width is 5;
  // [3]: add the parity-bit into one data transmit
  //        1'b0: disable;
  //        1'b1: enable;
  // [4]: decide odd-parity or even-parity
  //        1'b0: odd-parity;
  //        1'b1: even-parity;
  // [5]: fix the parity-bit to represent odd-parity or even-parity;
  //        1'b0: disable;
  //        1'b1: parity-bit would be fixed to 1 when lcr[4] is configed odd-parity(0);
  //              parity-bit would be fixed to 0 when lcr[4] is configed even-parity(1);
  // [6]: enable TX to send interrupt, but not realized in the driver;
  // [7]: reserved;
  logic [7:0] lcr = 8'h3f;
  // Baud divider
  // Divide the base clk
  // Baud_divisor and the base clk jointly determine the Baud-rate
  // Baud-rate = (clk frequency) / (16*baud_divisor);
  logic [15:0] baud_divisor = 16'h0001;

  `uvm_object_utils(uart_config)

  function new(string name="uart_config");
    super.new(name);
  endfunction: new

endclass: uart_config

`endif
`ifndef UART_TRANSACTION_SV
`define UART_TRANSACTION_SV

class uart_transaction extends uvm_sequence_item;

  rand int delay;
  rand bit[7:0] data;

  // Register config
  // Line Control Register
  rand bit[7:0] lcr;
  // Baud divider
  rand bit[15:0] baud_divisor;

  // Error injection
  // Start bit error
  rand bit sbe;
  rand int sbe_clks;
  // Framing error
  rand bit fe;
  // Parity error
  rand bit pe;

  constraint baudrate_divide_c{
    soft baud_divisor == 16'h01;
  }

  constraint error_dists_c{
    soft fe dist {1:=1, 0:=99};
    soft pe dist {1:=1, 0:=99};
    soft sbe dist {1:=1, 0:=99};
  }

  constraint clks_c{
    soft delay inside {[0:20]};
    soft sbe_clks inside {[1:4]};
  }

  constraint lcr_setup_c{
    soft lcr == 8'h3f;
  }

  `uvm_object_utils_begin(uart_transaction)
    `uvm_field_int(delay, UVM_ALL_ON)
    `uvm_field_int(sbe, UVM_ALL_ON)
    `uvm_field_int(sbe_clks, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(fe, UVM_ALL_ON)
    `uvm_field_int(lcr, UVM_ALL_ON)
    `uvm_field_int(pe, UVM_ALL_ON)
    `uvm_field_int(baud_divisor, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="uart_transaction");
    super.new(name);
  endfunction: new

endclass: uart_transaction

`endif
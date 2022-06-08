`ifndef UART_BURST_SEQ_SV
`define UART_BURST_SEQ_SV

class uart_burst_seq extends uvm_sequence#(uart_transaction);

  rand int size;
  rand bit[7:0] data[];
  rand bit[7:0] lcr;
  rand bit[15:0] baud_divisor;
  rand bit error_i;

  constraint data_size_c{
    data.size == size;
  }

  constraint lcr_setup_c{
    soft lcr == 8'h3f;
  }

  constraint baudrate_divide_c{
    soft baud_divisor == 16'h01;
  }

  `uvm_object_utils_begin(uart_burst_seq)
    `uvm_field_int(size, UVM_ALL_ON)
    `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_field_int(lcr, UVM_ALL_ON)
    `uvm_field_int(baud_divisor, UVM_ALL_ON)
    `uvm_field_int(error_i, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="uart_burst_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info("UART_BURST_SEQ", "----- Starting uart_burst_seq -----", UVM_LOW)
    req = uart_transaction::type_id::create("req");
    foreach(data[i]) begin
      start_item(req);
      req.randomize() with {
        data == local::data[i];
        lcr == local::lcr;
        baud_divisor == local::baud_divisor;
        local::error_i == 0 -> {
          sbe == 0;
          fe == 0;
          pe == 0;
        }
      };
      finish_item(req);
      req.print();
      get_response(rsp);
    end
    `uvm_info("UART_BURST_SEQ", "----- Finishing uart_burst_seq -----", UVM_LOW)
  endtask: body

endclass: uart_burst_seq

`endif
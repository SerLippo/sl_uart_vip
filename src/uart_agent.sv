`ifndef UART_AGENT_SV
`define UART_AGENT_SV

class uart_agent extends uvm_agent;

  virtual uart_if vif;
  uart_config cfg;

  uart_driver drv;
  uart_monitor mon;
  uart_sequencer sqr;

  `uvm_component_utils_begin(uart_agent)
  `uvm_component_utils_end

  function new(string name="uart_agent", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("UART_AGT", "Can not get config object from uvm_config_db!")
    else begin
      uvm_config_db#(uart_config)::set(this, "*", "cfg", cfg);
    end

    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("UART_AGT", "Can not get virtual interface object from uvm_config_db!")
    else begin
      uvm_config_db#(virtual uart_if)::set(this, "*", "vif", vif);
    end

    mon = uart_monitor::type_id::create("mon", this);
    if(cfg.is_active == UVM_ACTIVE) begin
      drv = uart_driver::type_id::create("drv", this);
      sqr = uart_sequencer::type_id::create("sqr", this);
    end
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    if(cfg.is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction: connect_phase

endclass: uart_agent

`endif
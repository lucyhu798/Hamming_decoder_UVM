/*
   Copyright 2013 Ray Salemi
*/
class hamming_agent extends uvm_agent;
  `uvm_component_utils(hamming_agent)

   h_sequencer	   sequencer_h; 
   driver          driver_h;
   result_monitor  result_monitor_h;
  

function new (string name, uvm_component parent);
   super.new(name,parent);
endfunction : new  

function void build_phase(uvm_phase phase);
  sequencer_h = h_sequencer::type_id::create("sequencer_h", this);
  	driver_h    = driver::type_id::create("driver_h",this);
    result_monitor_h  = result_monitor::type_id::create("result_monitor_h",this);
  
endfunction : build_phase

function void connect_phase(uvm_phase phase);
  // connecting the sequencer and driver 
  driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
  uvm_report_info("APB_AGENT", "connect_phase, Connected driver to sequencer");
  // co
  driver_h.sender.connect(result_monitor_h.tr_receive);
endfunction : connect_phase

endclass : hamming_agent

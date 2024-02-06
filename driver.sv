/*
   Copyright 2013 Ray Salemi
*/
class driver extends uvm_driver#(transaction);
   `uvm_component_utils(driver)

   virtual hamming_bfm bfm;

  uvm_analysis_port#(transaction) sender;
  
   function new (string name, uvm_component parent);
      super.new(name, parent);
     sender = new("sender", this);
   endfunction : new
   
   function void build_phase(uvm_phase phase);
     super.build_phase(phase); 
     if(!uvm_config_db#(virtual hamming_bfm )::get(null,"*","bfm",bfm)) begin
      `uvm_error("build_phase","driver virtual interface failed")
     end 
   endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
     super.run_phase(phase);
     
     this.bfm.init    <= 'b0;
     #5 
    forever begin
      transaction tr;
      @(this.bfm.clk);
      //First get an item from sequencer
      seq_item_port.get_next_item(tr);
      sender.write(tr);
      uvm_report_info("DRIVER ", $psprintf("Got Transaction %s",tr.convert2string()));
      for(int i = 0; i < 15; i++) 
        this.bfm.corrupt_message[i] <= tr.corrupt_message[i]; 
      	this.bfm.init <= 'b1; 
      #10
      this.bfm.init <= 0;
      #1300
      seq_item_port.item_done();
      
      this.bfm.init <= 'b0;
    end
   endtask : run_phase
   
endclass : driver

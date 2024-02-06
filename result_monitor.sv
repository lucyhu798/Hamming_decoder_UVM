/*
   Copyright 2013 Ray Salemi
*/
class result_monitor extends uvm_monitor;
   `uvm_component_utils(result_monitor);
  
  virtual hamming_bfm bfm; 

  transaction mon_tr; 
  
  uvm_analysis_port#(transaction) mon_port;
  
  uvm_analysis_imp#(transaction, result_monitor) tr_receive; 
  
  
     function new (string name, uvm_component parent);
      super.new(name, parent);
       mon_port = new("mon_port",this);
       tr_receive = new("tr_receive", this);
   endfunction : new
   
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     mon_tr = transaction::type_id::create("mon_tr", this);
     if (!uvm_config_db#(virtual hamming_bfm)::get(null, "*", "bfm", bfm)) begin
       `uvm_error("build_phase", "No virtual interface specified for this monitor instance")
       end
     $display("built result monitor");
   endfunction
 
  virtual function void write(transaction tr);
    for(int i = 0; i < 15; i++) begin  
       mon_tr.corrupt_message[i] = tr.corrupt_message[i];
       mon_tr.original_message[i] = tr.original_message[i];
       mon_tr.p1[i] = tr.p1[i];
       mon_tr.p2[i] = tr.p2[i];
      end
  endfunction 
  
  
    virtual task run_phase(uvm_phase phase);
             transaction r;
    super.run_phase(phase);
      #40
      forever begin
        @bfm.done;
      //while(bfm.done == 1) begin
  	   r = transaction::type_id::create("r", this);
    for(int i = 0; i < 15; i++) begin  
      r.recovered_message[i] = this.bfm.recovered_message[i]; 
     // $display ("RESULT MONITOR at %0d: resultA: %0b  ",i, r.recovered_message[i]);
      r.corrupt_message[i] = mon_tr.corrupt_message[i];
      r.original_message[i] = mon_tr.original_message[i];
      r.p1[i] = mon_tr.p1[i];
      r.p2[i] = mon_tr.p2[i];
      end
          mon_port.write(r);

        //end
      end
    endtask
endclass : result_monitor



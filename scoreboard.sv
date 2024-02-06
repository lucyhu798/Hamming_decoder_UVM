/*
   Copyright 2013 Ray Salemi
*/
class scoreboard extends uvm_scoreboard;
   `uvm_component_utils(scoreboard);

  
   // figure out which ports to use 
  uvm_analysis_imp#(transaction, scoreboard) mon_export;
  
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
     mon_export = new ("mon_export", this);
   endfunction : new
  

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
   endfunction : build_phase

   int correct, incorrect;
   function void write(transaction r );
    for(int i = 0; i < 15; i++) begin 
      if( r.recovered_message[i][15] == 'b1) begin 
        $display ( "SCOREBOARD: PASS IDENTIFIED DOUBLE ERROR   at %0d actual result: %b  expected: %b",i,  r.recovered_message[i] , r.original_message[i]);
        correct++;
      end 
      else if (r.recovered_message[i] != r.original_message[i]) begin 
        $display ( "FAILED at %0d: actual result: %b   expected: %b",i, r.recovered_message[i] , r.original_message[i]);
      	incorrect++; 
      end 
      else begin 
        $display ( "SCOREBOARD: PASS  actual result: %b  ", r.recovered_message[i]);
      	correct++; 
      end 
    end 
     $display("incorrect = %d correct = %d ",incorrect, correct);
   endfunction
   
endclass : scoreboard

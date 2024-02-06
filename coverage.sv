/*
   Copyright 2013 Ray Salemi
*/
class coverage extends uvm_subscriber #(transaction);
   `uvm_component_utils(coverage)

  bit [3:0] p1; 
  bit [3:0] p2; 
  bit [10:0] original_value; 
  // how to be able to check an array in coverage. 

  	covergroup two_error;
     // all comb of original message 
      c1: coverpoint original_value;
     
     // all comb  p1 and p2
     c2: cross p1, p2;
     
     // all comb of p1, p2, message 
     //c3: cross c2, original_message; 
     

   	endgroup

   	covergroup one_error;
      // all comb of original message
      c1: coverpoint original_value; 
      
      // all comb of  p1
      c2: coverpoint p1 ;
      
      //all comb p1 and message 
      //c3: cross p1, original_value[0:$]; 

	endgroup

  	covergroup no_error;
      // all comb of message 
      c1: coverpoint original_value; 
    endgroup 

   function new (string name, uvm_component parent);
      super.new(name, parent);
      two_error = new();
      one_error = new();
     no_error = new();
   endfunction : new



  function void write(transaction t);
    // for loop to go through each iteration of the array for the original value 
    
    for(int i = 0; i < 15; i++) begin 
      p1[i] = t.p1[i];
      p2[i] = t.p2[i];
      original_value[i] = {t.original_message[i][15:9], t.original_message[i][7:5], t.original_message[i][3]}; 
      if(t.recovered_message[i][15:13] == 'b000) 
      	no_error.sample();
      else if(t.recovered_message[i][15:13] == 'b010)
      	one_error.sample();
      else if(t.recovered_message[i][15:13] == 'b100)
   	  	two_error.sample();
    
    end 
   endfunction : write
  
  
  // may add this if cannot figure out the txt file dump 
   function void report_phase(uvm_phase phase);
  
     $display("\n  NO ERROR COVERAGE: %2.0f%% ", no_error.get_coverage());
     $display("\n ONE ERROR COVERAGE: %2.0f%% ", one_error.get_coverage());
     $display("\n TWO ERROR COVERAGE: %2.0f%% ", two_error.get_coverage());

   endfunction : report_phase
   
 
  
endclass : coverage






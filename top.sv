/*
   Copyright 2013 Ray Salemi 
   use classes and objects to move data around model
*/
module top;
   import uvm_pkg::*;
   import   hamming_pkg::*;
`include "uvm_macros.svh"

   
  hamming_bfm       bfm();
  
  hamming_decoder DUT (.clk(bfm.clk), .init(bfm.init), .corrupt_message(bfm.corrupt_message), .recovered_message(bfm.recovered_message), .done(bfm.done));
  
  
initial begin
    $dumpfile("dump.vcd");
	$dumpvars;
  uvm_config_db #(virtual hamming_bfm)::set(null, "*", "bfm", bfm);
  // uncomment if want to test the other things. 
   run_test("two_error_test");
    //run_test("one_error_test");
  //run_test("no_error_test");
end

endmodule : top

     
/*
   Copyright 2013 Ray Salemi
*/
interface hamming_bfm;
  import uvm_pkg::*;
    `include "uvm_macros.svh"
  import hamming_pkg::*;
  
   
  result_monitor  result_monitor_h;

  logic       	clk;
  logic      		init; 
  logic [15:0]  	corrupt_message[15]; 
  logic [15:0] 	recovered_message[15];
  logic         	done;



  
 initial begin
      clk = 0;
      forever begin
         #5;
         clk = ~clk;
      end
   end
  
endinterface : hamming_bfm

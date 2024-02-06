/*
   Copyright 2013 Ray Salemi
*/
class env extends uvm_env;
   `uvm_component_utils(env);

   //no_error_tester     	no_error_tester_h;
   //one_error_tester	   	one_error_tester_h;
   //two_error_tester    	two_error_tester_h;
   hamming_agent  		hamming_agent_h; 
   coverage   			coverage_h;
   scoreboard 			scoreboard_h;

  
   
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

  function void build_phase(uvm_phase phase);
    //no_error_tester_h 	= no_error_tester::type_id::create("no_error_tester_h",this);
    //one_error_tester_h  = one_error_tester::type_id::create("one_error_tester_h",this);
    //two_error_tester_h  = two_error_tester::type_id::create("two_error_tester_h",this);
    coverage_h        	=  coverage::type_id::create ("coverage_h",this);
    scoreboard_h      	= scoreboard::type_id::create("scoreboard_h",this);
    hamming_agent_h		= hamming_agent::type_id::create("hamming_agent_h", this);

    
    
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    hamming_agent_h.result_monitor_h.mon_port.connect(coverage_h.analysis_export);
    hamming_agent_h.result_monitor_h.mon_port.connect(scoreboard_h.mon_export);
  endfunction : connect_phase
   
endclass
   
/*
   Copyright 2013 Ray Salemi
*/
class no_error_test extends uvm_test;
  `uvm_component_utils(no_error_test);

  env       env_h;
   
  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    env_h = env::type_id::create("env_h",this);

  endfunction : build_phase
  
  //connect to the sequence 
  task run_phase( uvm_phase phase );
    no_error_sequence seq;
    seq = no_error_sequence::type_id::create("seq");
    phase.raise_objection( this, "Starting sequence main phase" );
    $display("%t Starting sequence apb_seq run_phase",$time);
    seq.start(env_h.hamming_agent_h.sequencer_h);
    #10000ns
    phase.drop_objection( this , "Finished seq in main phase" );   
  endtask
  


endclass
   
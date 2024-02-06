class h_sequencer extends uvm_sequencer#(transaction);
  
  `uvm_component_utils(h_sequencer)
  
  function new ( string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
endclass
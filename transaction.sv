class transaction extends uvm_sequence_item;
  
  `uvm_object_utils(transaction)
  
  // whatever I need for the transaction will put here. 
  bit [15:0] corrupt_message [15]; 
  bit [15:0] recovered_message[15];
  bit [15:0] original_message [15];
  bit [3:0] p1[15]; 
  bit [3:0] p2[15];
  
  

  
  function new (string name = "apb_transaction");
    super.new(name);
  endfunction
  
  function string convert2string();
    // need to fix this soon 
    return $psprintf("corrupt_message=%0b recovered_message=%0b orignal_message=%0b p1 = %0d p2 = %0d ",corrupt_message[1], recovered_message[1], original_message[1], p1[1], p2[1]);
  endfunction
  
endclass
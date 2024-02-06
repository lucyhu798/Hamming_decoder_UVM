// not sure if this virtual class will let us choose which one to use 
class no_error_sequence extends uvm_sequence#(transaction);
  `uvm_object_utils(no_error_sequence)
  
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  task body();
    // name transaction 
    transaction tr;
    bit [15:0] original_message;
    bit [11:1] message; 
    bit p8;
    bit p4;
    bit p2;
    bit p1;
    bit p0;
    // repeat the number of times you want to do it 
    repeat(100) begin 
    // initialize the transaction 
    // start the item 
      tr = new();
      start_item(tr);
    // fill in the transaction value with the randomized values 
      for(int i = 0; i < 15; i++) begin 
         message = $random;
         p8 = ^message[11:5];
         p4 = (^message[11:8])^(^message[4:2]);
         p2 = message[11]^message[10]^message[7]^message[6]^message[4]^message[3]^message[1];
         p1 = message[11]^message[9]^message[7]^message[5]^message[4]^message[2]^message[1];
         p0 = ^message^p8^p4^p2^p1;

         original_message = {message[11:5],p8,message[4:2],p4,message[1],p2,p1,p0};
        
        tr.original_message[i] = message; 
        tr.corrupt_message[i] = original_message;
        //$display("random messages at %0d : %0b", i, message);
      end 
    // finish the item 
      finish_item(tr);

    end
  endtask
endclass
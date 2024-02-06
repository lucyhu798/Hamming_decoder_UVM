// not sure if this virtual class will let us choose which one to use 
class two_error_sequence extends uvm_sequence#(transaction);
  `uvm_object_utils(two_error_sequence)
  
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  task body();
    // name transaction 
    transaction tr;
    bit [15:0] original_message;
    bit [15:0] corrupted_1;
    bit [11:1] message; 
    bit [3:0] flip;
    bit [3:0] flip2;
    bit p8;
    bit p4;
    bit p2;
    bit p1;
    bit p0;
    // repeat the number of times you want to do it 
    repeat(130) begin 
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
        
        tr.original_message[i][15] = 'b1;
        
        flip = $random;
        corrupted_1 = original_message ^ (1'b1<<flip);
        tr.p1[i] = flip;
        flip2 = $random;
    	while(flip == flip2)
      		flip2 = $random;
        tr.p2[i] = flip2;
        tr.corrupt_message[i] = corrupted_1 ^ (1'b1<<flip2);
        
        

        
      end 
    // finish the item 
      finish_item(tr);
      // do we need to assert when its done to finish the item? 
    

    end
  endtask
endclass
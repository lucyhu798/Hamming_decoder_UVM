// W is data path width (8 bits)
// byte count = number of "words" (bytes) in reg_file
//   or data_memory
`include "dat_mem.sv"
module hamming_decoder #(parameter W=8,
                   byte_count = 256)(
  input        clk, 
               init, 			// req. from test bench
  input [15:0] corrupt_message[15], // put data to memory 
  output logic [15:0] recovered_message[15], // grab data from memory 
  output logic done);		    // ack. to test bench

// memory interface = 
//   write_en, raddr, waddr, data_in, data_out: 
  logic write_en;                  // store enable for dat_mem

// address pointers for reg_file/data_mem
  logic[$clog2(byte_count)-1:0] raddr, waddr;

// data path connections into/out of reg file/data mem
  logic[W-1:0] data_in;
  wire [W-1:0] data_out; 

  
/* instantiate data memory (reg file)
   Here we can override the two parameters, if we 
     so desire (leaving them as defaults here) */
  dat_mem #(.W(W),.byte_count(byte_count)) 
    dm1(.*);		               // reg_file or data memory
  
      

/* ********** insert your code here
   read from data mem, manipulate bits, write
   result back into data_mem  ************
*/
// program counter: bits[6:3] count passes through for loop/subroutine
// bits[2:0] count clock cycles within subroutine (I use 5 out of 8 possible, pad w/ 3 no ops)
  logic[ 6:0] count;
  logic[ 8:0] parity;
  logic[15:0] temp1, temp2;
  logic       temp1_enh, temp1_enl, temp2_en;

  assign parity[8] = ^temp1[15:9]; 
  assign parity[4] = ^temp1[15:12]^temp1[7]^temp1[6]^temp1[5];
  assign parity[2] = ^temp1[15]^temp1[14]^temp1[11]^temp1[10]^temp1[7]^temp1[6]^temp1[3];
  assign parity[1] = ^temp1[15]^temp1[13]^temp1[11]^temp1[9]^temp1[7]^temp1[5]^temp1[3];
  assign parity[0] = ^temp1[15:1];

  always @(posedge clk)
    if(init) begin
      count <= 'b0;
      temp1 <= 'b0;
      temp2 <= 'b0;
    end
    else begin
      count                     <= count + 1;
      if(temp1_enh) temp1[15:8] <= data_out;
      if(temp1_enl) temp1[ 7:0] <= data_out;
//    if(temp2_en)  temp2       <= function of temp1 and parity bits 
	  if(temp2_en) begin    
	  	//compare parity bits 
	  	//correct message  
	  	if(parity[8] == temp1[8] && parity[4] == temp1[4] && 
	  		parity[2] == temp1[2] && parity[1] == temp1[1] && 
	  		parity[0] == temp1[0]) begin   
	  		temp2[10:4] = temp1[15:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3]; 
	  		temp2[15] = 0;
	  		temp2[14] = 0; 
	  		temp2[13:11] = 0;
	  		end    
	  	//single parity bit error
	  	else if(parity[8] != temp1[8] && parity[4] == temp1[4] && 
	  		parity[2] == temp1[2] && parity[1] == temp1[1] && 
	  		parity[0]!= temp1[0]) begin 
	  		temp2[10:4] = temp1[15:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3]; 
	  		temp2[15] = 0;
	  		temp2[14] = 1; 
	  		temp2[13:11] = 0;
	  		end 
	  	else if(parity[8] == temp1[8] && parity[4] != temp1[4] && 
	  		parity[2] == temp1[2] && parity[1] == temp1[1] && 
	  		parity[0] != temp1[0]) begin 
	  		temp2[10:4] = temp1[15:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3]; 
	  		temp2[15] = 0;
	  		temp2[14] = 1; 
	  		temp2[13:11] = 0;
	  		end
	  	else if(parity[8] == temp1[8] && parity[4] == temp1[4] && 
	  		parity[2] != temp1[2] && parity[1] == temp1[1] && 
	  		parity[0] != temp1[0]) begin 
	  		temp2[10:4] = temp1[15:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3]; 
	  		temp2[15] = 0;
	  		temp2[14] = 1; 
	  		temp2[13:11] = 0;
	  		end 
	  	else if(parity[8] == temp1[8] && parity[4] == temp1[4] && 
	  		parity[2] == temp1[2] && parity[1] != temp1[1] && 
	  		parity[0] != temp1[0]) begin 
	  		temp2[10:4] = temp1[15:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3]; 
	  		temp2[15] = 0;
	  		temp2[14] = 1; 
	  		temp2[13:11] = 0;
	  		end     
	  	else if(parity[8] == temp1[8] && parity[4] == temp1[4] && 
	  		parity[2] == temp1[2] && parity[1] == temp1[1] && 
	  		parity[0] != temp1[0]) begin 
	  		temp2[10:4] = temp1[15:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3]; 
	  		temp2[15] = 0;
	  		temp2[14] = 1; 
	  		temp2[13:11] = 0;
	  		end
	  	//1 bit error            
	  	else if(parity[0] != temp1[0])begin
	  		temp2[15] = 0;  
	  		temp2[14] = 1;   
	  		temp2[13:11] = 0;
	  		//d0 is wrong
	  		if(parity[1] != temp1[1] && parity[2] != temp1[2] && parity[4] ==temp1[4] &&
	  			parity[8] == temp1[8])begin 
	  			temp2[10:4] = temp1[15:9];
	  			temp2[3:1] = temp1[7:5];
	  			temp2[0] = ^temp1[3]^(1); 
	  		end 
	  		//d1 is wrong
	  		else if(parity[1] !=temp1[1] && parity[4] != temp1[4]&&parity[2] ==temp1[2] &&
	  				parity[8] == temp1[8])begin
	  			temp2[10:4] = temp1[15:9];
	  			temp2[3:2] = temp1[7:6];
	  			temp2[1] = ^temp1[5]^(1);
	  			temp2[0] = temp1[3];
	  		end
	  		//d2 is wrong
	  		else if(parity[2] != temp1[2] && parity[4] != temp1[4] && parity[1] == temp1[1] &&
	  				parity[8] == temp1[8]) begin
	  			temp2[10:4] = temp1[15:9];
	  			temp2[3] = temp1[7];
	  			temp2[2] = ^temp1[6]^(1);
	  			temp2[1] = temp1[5];
	  			temp2[0] = temp1[3];
	  		end
	  		//d3 is wrong
	  		else if(parity[1] != temp1[1] && parity[2] != temp1[2] && parity[4] != temp1[4]&&
	  				parity[8] == temp1[8]) begin
	  			temp2[10:4] = temp1[15:9];
	  			temp2[3] = ^temp1[7]^(1);
	  			temp2[2:1] = temp1[6:5];
	  			temp2[0] = temp1[3];
	  		end                     
	  		//d4 is wrong
	  		else if(parity[1] != temp1[1] && parity[8] != temp1[8] && parity[2] == temp1[2] &&
	  				parity[4] == temp1[4]) begin
	  			temp2[10:5] = temp1[15:10];
	  			temp2[4] = ^temp1[9]^(1);
	  			temp2[3:1] = temp1[7:5];
	  			temp2[0] = temp1[3];
	  		end                     
	  		//d5 is wrong
	  		else if(parity[2] != temp1[2] && parity[8] != temp1[8]&&parity[1] == temp1[1] &&
	  				parity[4] == temp1[4]) begin
	  			temp2[10:6] = temp1[15:11];
	  			temp2[5] = ^temp1[10]^(1);
	  			temp2[4] = temp1[9];
	  			temp2[3:1] = temp1[7:5];
	  			temp2[0] = temp1[3];
	  		end
	  		//d6 is wrong
	  		else if(parity[1] != temp1[1] && parity[2] != temp1[2] && parity[8] != temp1[8]&&
	  				parity[4] == temp1[4])begin
	  			temp2[10:7] = temp1[15:12];
	  			temp2[6] = ^temp1[11]^(1);
	  			temp2[5:4] = temp1[10:9];
	  			temp2[4] = temp1[9];
	  			temp2[3:1] = temp1[7:5];
	  			temp2[0] = temp1[3];
	  		end
	  		//d7 is wrong
	  		else if(parity[4]!=temp1[4] && parity[8] !=temp1[8]&&parity[1] == temp1[1] &&
	  				parity[2] == temp1[2])begin
	  		temp2[10:8] = temp1[15:13];
	  		temp2[7] = ^temp1[12]^(1);
	  		temp2[6:4] = temp1[11:9];
	  		temp2[3:1] = temp1[7:5];
	  		temp2[0] = temp1[3];
	  		end
	  		//d8 is wrong
	  		else if(parity[1] != temp1[1] && parity[4]!=temp1[4] && parity[8] !=temp1[8]&&
	  				parity[2] == temp1[2])begin
	  			temp2[10:9] = temp1[15:14];
	  			temp2[8] = ^temp1[13]^(1);
	  			temp2[7:4] = temp1[12:9];
	  			temp2[3:1] = temp1[7:5];
	  			temp2[0] = temp1[3];
	  		end 
	  		else if(parity[2] != temp1[2] && parity[4] != temp1[4] && 
	  				parity[8] != temp1[8]&& parity[1] == temp1[1]) begin
				temp2[10] = temp1[15];
				temp2[9] = ^temp1[14]^(1);
				temp2[8:4] = temp1[13:9];
				temp2[3:1] = temp1[7:5];
				temp2[0] = temp1[3];
			end
			else if(parity[1] != temp1[1] && parity[2] != temp1[2] && 
					parity[4] != temp1[4] && parity[8] != temp1[8]) begin
				temp2[10] = ^temp1[15]^(1);
				temp2[9:4] = temp1[14:9];
				temp2[3:1] = temp1[7:5];
				temp2[0] = temp1[3];
			end
	  	end     
	  	//two bit error    
	  	else begin
	  	     temp2 = temp1;
	  	     temp2[15] = 1; 
	  	     temp2[14] = 0;  
	  	     temp2[13:11] = 0;
	  	end
	  
	  end  
          
	 
    end  

  always_comb begin
// defaults  
    temp1_enl        = 'b0;
    temp1_enh        = 'b0;
    temp2_en         = 'b0;   
    raddr            = 'b0;
    waddr            = 'b0;
    write_en         = 'b0;
    data_in          = temp2[7:0]; 
    
    case(count[2:0])
      0: begin 
            write_en = 'b1;
        waddr = 2*count[6:3] + 64; 
        data_in = corrupt_message[count[6:3]][7:0];
      end 
      1: begin                  // step 1: load from data_mem into lower byte of temp1
//         raddr     = function of count[6:3]
           write_en = 'b1;
        waddr = 2*count[6:3] + 65; 
        data_in = corrupt_message[count[6:3]][15:8];
		   raddr = 2*count[6:3]+64;
           temp1_enl = 'b1;
         end  
      2: begin                  // step 2: load from data_mem into upper byte of temp1
//           raddr      = function of count[6:3]  
		   raddr = 2*count[6:3]+65;
           temp1_enh = 'b1;
         end
      3: temp2_en    = 'b1;     // step 3: copy from temp1 and parity bits into temp2
      4: begin                  // step 4: store from one bytte of temp2 into data_mem 
           write_en = 'b1;
           waddr = 2*count[6:3]+94;  
           data_in = temp2[7:0];
        recovered_message[count[6:3]] = temp2;
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
         end
      5: begin
           write_en = 'b1;      // step 5: store from other byte of temp2 into data_mem  
           waddr = 2*count[6:3] + 95;
           data_in = temp2[15:8];
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
         end
    endcase
  end

// automatically stop at count 127; 120 might be even better (why?)
  assign done = &count;

endmodule

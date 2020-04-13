`include "Defines.v"

module Ctrl(
    input wire         rst,
    input wire         rdy,
    
    input wire         stallreq_from_if,
	//input wire         stallreq_from_id,
	input wire         stallreq_from_mem,
	
	output reg[5:0]    stall
    );
    
    // stall[0] PC
    // stall[1] IF
    // stall[2] ID
    // stall[3] EX
    // stall[4] MEM
    // stall[5] WB
    
    always @ (*) begin
        if(rst == `RstEnable) begin
            stall = 6'b000000;
        end else if (rdy == `NotReady) begin
            stall = 6'b111111;
        end else if (stallreq_from_mem == `Stop) begin
            stall = 6'b011111;
        //end else if (stallreq_from_id == `Stop) begin
        //    stall = 6'b000111;
        end else if (stallreq_from_if == `Stop) begin
            stall = 6'b000011;
        end else begin
            stall = 6'b000000;
        end
    end
    
endmodule

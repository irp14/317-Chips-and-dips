`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2026 02:57:08 PM
// Design Name: 
// Module Name: accelerator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module accelerator(
        input wire clk, rst,

        input wire x_valid, w_valid,
        input wire signed [7:0] x_data, w_data,
        input wire signed [31:0] T,
        input wire signed [3:0]  U,

        input wire start, stall_inject,
        input wire [1:0] mode,
        input wire y_ready,
        
        output wire done,
        output reg signed [31:0] y_data,
    );
    localparam IDLE = 3'b000;
    localparam CFG = 3'b001;
    localparam WAIT_IN = 3'b010;
    localparam COMPUTE = 3'b011;
    localparam HOLD_OUT = 3'b100;

    reg [2:0] state, next_state;
    reg [3:0] stored_count;
    reg finish, early_exit;

    always @(posedge clk) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:
                if (start) next_state = CFG;
            CFG:
                if (mode != 2'b11) next_state = WAIT_IN;
            WAIT_IN:
                // not parallel compute mode
                if ( mode != 2'b01 && !stall_inject && x_valid && w_valid) next_state = COMPUTE;
                // if parallel compute mode, wait until the stored data is equal to U
                if ( mode == 2'b01 && stall_inject && x_valid && w_valid && stored_count == U) next_state = COMPUTE;
            COMPUTE:
                if (finish || early_exit) next_state = HOLD_OUT;
            HOLD_OUT:
                if (y_ready) next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            stored_count <= 0;
            y_data       <= 0;
            finish       <= 0;
            early_exit   <= 0;
        end else begin
            finish       <= 0;
            early_exit   <= 0;
            case (state)
                IDLE: begin
                    stored_count <= 0;

                end

                CFG: begin
                    
                end

                WAIT_IN: begin
                    if (x_valid && w_valid)
                        stored_count <= 0;
                end

                COMPUTE: begin
                    stored_count <= 0;
                    if (mode != 2'01)
                        y_data <= y_data + (x_data * w_data);
                    else
                        
                   
                end

                HOLD_OUT: begin

                end
            endcase
        end
    end


endmodule

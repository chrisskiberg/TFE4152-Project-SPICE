`timescale 1ns / 1ps

module PixelTop_tb;
    
    logic clk = 0;
    logic reset_n = 0;
    parameter num_pixels_in_tb = 16;
    parameter integer clk_half_period = 500;
    parameter integer clk_period = clk_half_period*2;
    parameter integer some_time = num_pixels_in_tb*100*clk_period;
    parameter integer sim_end = clk_period*700;
    always #clk_half_period clk=~clk;
    
    logic [7:0] data_out;
    logic       data_ready;
    logic       data_out_valid;
    logic       read_data;
    
    PIXEL_TOP pixel_top (
        .clk(clk),
        .reset_n(reset_n),
        .read_data(read_data),
        .data_ready(data_ready),
        .data_out_valid(data_out_valid),
        .data_out(data_out)
    );
    
    defparam pixel_top.num_pixels = num_pixels_in_tb;
    
    always @(posedge data_ready) begin
        read_data <= 1; 
    end
    
    always @(negedge data_ready) begin
        read_data <= 0;
    end
    
    defparam pixel_top.num_pixels = num_pixels_in_tb;
    initial
        begin
            #clk_period reset_n <= 1;
            #some_time
            
            #sim_end $stop;
        end
endmodule


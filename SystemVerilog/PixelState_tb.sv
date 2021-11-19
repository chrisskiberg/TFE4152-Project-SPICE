`timescale 1ns / 1ps

module PixelState_tb;
    logic clk =0;
    logic reset_n =0;
    parameter integer num_pixels = 64;
    parameter integer clk_half_period = 500;
    parameter integer clk_period = clk_half_period*2;
    parameter integer sim_end = clk_half_period*2000;
    always #clk_half_period clk=~clk;

    wire expose;
    wire erase;
    wire read;
    wire convert;
    wire[$clog2($rtoi($sqrt(num_pixels)))-1:0] row_addr;
    wire[$clog2($rtoi($sqrt(num_pixels)))-1:0] col_addr;
    
    // merge high and low addresses for easier debugging
    wire [$clog2(num_pixels)-1:0] pixel_addr;
    assign pixel_addr = {row_addr, col_addr};
    
    PIXEL_STATE pixel_fsm
    (
        .clk(clk),
        .reset_n(reset_n),
        .erase(erase),
        .expose(expose),
        .read(read),
        .convert(convert),
        .row_addr(row_addr),
        .col_addr(col_addr)
    );
    
    defparam pixel_fsm.num_pixels = num_pixels;

    initial
        begin
        #clk_period reset_n <= 1;
        #sim_end $stop;
    end
endmodule

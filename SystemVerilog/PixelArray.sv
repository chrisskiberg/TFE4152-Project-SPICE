`timescale 1ns / 1ps

module PIXEL_ARRAY
    #(parameter num_pixels = 4)
    (
        input  logic                                        reset_n,
        input  logic                                        read,
        input  logic                                        expose,
        input  logic                                        erase,
        input  logic                                        bias,
        input  logic                                        ramp,
        input  logic[$clog2($rtoi($sqrt(num_pixels)))-1:0]  row_addr,
        input  logic[$clog2($rtoi($sqrt(num_pixels)))-1:0]  col_addr,
        output logic[7:0]                                   data
    );
    
    // 8 bit data bus
    // Pixels are read individually
    tri [7:0] pixel_array_data_bus;
    tri [$rtoi($sqrt(num_pixels))-1:0][$rtoi($sqrt(num_pixels))-1:0] pixel_read;
    
    // Common signals for all pixels
    // All pixels are ramped and biased in the same way
    // All pixels are reset, erased, and exposed at the same time
    wire [$rtoi($sqrt(num_pixels))-1:0][$rtoi($sqrt(num_pixels))-1:0] pixel_array_reset;
    wire [$rtoi($sqrt(num_pixels))-1:0][$rtoi($sqrt(num_pixels))-1:0] pixel_array_expose;
    wire [$rtoi($sqrt(num_pixels))-1:0][$rtoi($sqrt(num_pixels))-1:0] pixel_array_erase;
    wire [$rtoi($sqrt(num_pixels))-1:0][$rtoi($sqrt(num_pixels))-1:0] pixel_array_vbn1;
    wire [$rtoi($sqrt(num_pixels))-1:0][$rtoi($sqrt(num_pixels))-1:0] pixel_array_ramp;
    
    // i-by-j matrix of pixels
    generate
        for (genvar i = 0; i < $rtoi($sqrt(num_pixels)); i = i + 1) begin
            for (genvar j = 0; j < $rtoi($sqrt(num_pixels)); j = j + 1) begin
                PIXEL_SENSOR pixel_x (
                    .VBN1   (pixel_array_vbn1[i][j]),
                    .RAMP   (pixel_array_ramp[i][j]),
                    .RESET  (pixel_array_reset[i][j]),
                    .ERASE  (pixel_array_erase[i][j]), 
                    .EXPOSE (pixel_array_expose[i][j]),
                    .READ   (pixel_read[i][j]),
                    .DATA   (pixel_array_data_bus)
                );
            end
        end
    endgenerate
    
    // Connect inputs
    for (genvar i = 0; i < $rtoi($sqrt(num_pixels)); i = i + 1) begin
        for (genvar j = 0; j < $rtoi($sqrt(num_pixels)); j = j + 1) begin
            // Common signals between all pixels
            assign data = pixel_array_data_bus;
            assign pixel_array_reset[i][j] = reset_n;
            assign pixel_array_expose[i][j] = expose;
            assign pixel_array_erase[i][j] = erase;
            assign pixel_array_vbn1[i][j] = bias;
            assign pixel_array_ramp[i][j] = ramp;
            
            // Read signal requires tristate
            assign pixel_read[i][j] = (i == row_addr && j == col_addr) ? read : 0;
        end
    end
endmodule


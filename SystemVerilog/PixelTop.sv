`timescale 1ns / 1ps

module PIXEL_TOP
    #(parameter num_pixels = 4)
    (
        input  logic       clk,
        input  logic       reset_n,
        input  logic       read_data,
        output logic       data_ready,
        output logic       data_out_valid,
        output logic[7:0]  data_out
    );
    
    // Buffer the latest data from every pixel
    integer                    pixel_data_buffer_counter;
    logic[num_pixels-1:0][7:0] pixel_data_buffer;
    tri[7:0]                   current_data_bus_value;
    logic[7:0]                 temp_buffer;
    
    // Interconnects between the pixel array and FSM
    wire expose;
    wire erase;
    wire ramp;
    wire read;
    wire convert;
    wire analog_bias;
    wire[$clog2($rtoi($sqrt(num_pixels)))-1:0] row_addr;
    wire[$clog2($rtoi($sqrt(num_pixels)))-1:0] col_addr;
    
    PIXEL_ARRAY pixel_arr (
        .reset_n(reset_n),
        .read(read),
        .expose(expose),
        .erase(erase),
        .bias(analog_bias),
        .ramp(ramp),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .data(temp_buffer)
    );
    PIXEL_STATE pixel_fsm (
        .clk(clk),
        .reset_n(reset_n),
        .erase(erase),
        .expose(expose),
        .read(read),
        .convert(convert),
        .row_addr(row_addr),
        .col_addr(col_addr)
    );
    
    defparam pixel_arr.num_pixels = num_pixels;
    defparam pixel_fsm.num_pixels = num_pixels;
    
    // Use clk as a ramp during the integration phase. This works as a simplification
    // because each pixel sensor unit contains its own counter.
    assign ramp = convert ? clk : 0;
    
    // "Clock" the analog bias. This is a simplification so that the analog circuit
    // (which is asynchronous) will work with the synchronous logic.
    // In reality this is not necessary
    assign analog_bias = expose ? clk : 0;
    
    // Data is shifted out in 8-bit chunks
    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n == 0) begin
            pixel_data_buffer_counter <= 0;
            pixel_data_buffer <= 0;
            data_out <= 0;
            data_ready <= 0;
        end
        else if (read) begin
            // Do not let the user pull data when we are reading from the pixels
            // This should represent a very small amount of time relative to the
            // exposure and conversion phases.
            pixel_data_buffer_counter <= pixel_data_buffer_counter + 1;
            pixel_data_buffer[pixel_data_buffer_counter] <= temp_buffer;
            
            if (pixel_data_buffer_counter == num_pixels) begin
                data_ready <= 1;
                pixel_data_buffer_counter <= 0;
            end
            else begin
                data_ready <= 0;
            end
        end
        else if (!read && read_data && data_ready) begin
            data_out_valid <= 1;
            data_out <= pixel_data_buffer[pixel_data_buffer_counter];
            if (pixel_data_buffer_counter != num_pixels) begin
                pixel_data_buffer_counter <= pixel_data_buffer_counter + 1;
            end
            else begin
                data_ready <= 0;
                data_out_valid <= 0;
                pixel_data_buffer_counter <= 0;
            end
        end
        else begin
            data_ready <= 0;
            data_out_valid <= 0;
            pixel_data_buffer_counter <= 0;
        end
    end
endmodule

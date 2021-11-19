`timescale 1ns / 1ps

module pixelArray_tb;
   logic clk =0;
   logic reset_n =0;
   parameter num_pixels_in_tb = 64;
   parameter integer clk_half_period = 500;
   parameter integer clk_period = clk_half_period*2;
   parameter integer short_exposure_time = 25*clk_period;
   parameter integer long_exposure_time = 75*clk_period;
   parameter integer conversion_time = 255*clk_period;
   parameter integer read_time = 5*clk_period;
   parameter integer sim_end = clk_half_period*600;
   always #clk_half_period clk=~clk;

   //Analog signals
   logic              analog_bias_1;
   logic              analog_ramp;
   logic              analog_reset;

   //Tie off the unused lines
   assign analog_reset = 1;

   //Digital logic
   logic            erase;
   logic            expose;
   logic            read;
   logic            convert;
   tri[7:0]         pixData;
   
   // Addressing of the pixel within the array
   logic[$clog2($rtoi($sqrt(num_pixels_in_tb)))-1:0] row_addr;
   logic[$clog2($rtoi($sqrt(num_pixels_in_tb)))-1:0] col_addr;

   PIXEL_ARRAY pa  (.reset_n(analog_reset),
                    .read(read),
                    .expose(expose),
                    .erase(erase),
                    .bias(analog_bias_1),
                    .ramp(analog_ramp),
                    .row_addr(row_addr),
                    .col_addr(col_addr),
                    .data(pixData)
                    );

   defparam pa.num_pixels = num_pixels_in_tb;

   assign analog_ramp = convert ? clk : 0;
   assign analog_bias_1 = expose ? clk : 0;

   initial
     begin
        read <= 0;
        erase <= 0;
        expose <= 0;
        convert <= 0;
        #clk_period;
        
        // Test 1 -- short exposure time
        read <= 0;
        erase <= 1;
        expose <= 0;
        convert <= 0;
        #clk_period;
        
        erase <= 0;
        #clk_period;

        expose <= 1;
        #short_exposure_time;
        
        expose <= 0;
        convert <= 1;
        #conversion_time;
        
        convert  <= 0;
        read     <= 1;
        row_addr <= 1;
        col_addr <= 0;
        #read_time;
        
        read <= 0;
        erase <= 0;
        expose <= 0;
        convert <= 0;
        #clk_period;
        
        // Test 2 -- long exposure time
        
        read <= 0;
        erase <= 1;
        expose <= 0;
        convert <= 0;
        #clk_period;
        
        erase <= 0;
        #clk_period;

        expose <= 1;
        #long_exposure_time;
        
        expose <= 0;
        convert <= 1;
        #conversion_time;
        
        convert  <= 0;
        read     <= 1;
        row_addr <= 0;
        col_addr <= 0;
        #clk_period;
        
        row_addr <= 0;
        col_addr <= 1;
        #clk_period;
        
        row_addr <= 1;
        col_addr <= 0;
        #clk_period;
        
        row_addr <= 7;
        col_addr <= 7;
        #clk_period;
        
        read <= 0;
        #clk_period;
        #clk_period;
        
        $stop;
     end
endmodule // test

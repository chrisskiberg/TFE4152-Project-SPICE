`timescale 1ns / 1ps

module PIXEL_STATE
   #(parameter num_pixels = 4)
   (
       input  logic                                       clk,
       input  logic                                       reset_n,
       output logic                                       erase,
       output logic                                       expose,
       output logic                                       read,
       output logic                                       convert,
       output logic[$clog2($rtoi($sqrt(num_pixels)))-1:0] row_addr,
       output logic[$clog2($rtoi($sqrt(num_pixels)))-1:0] col_addr
   );


   //State duration in clock cycles
   parameter integer c_erase = 5;
   parameter integer c_expose = 75;
   parameter integer c_convert = 150;
   parameter integer c_read_per_pixel = 1;
   parameter integer c_read = c_read_per_pixel * num_pixels;

   //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSURE=1, CONVERSION=2, READ=3, IDLE=4;


   logic [2:0]         state, next_state;   //States
   integer             counter;
   integer             read_counter;

   // Addressing logic
   logic [$clog2($rtoi($sqrt(num_pixels)))-1:0] row_counter;
   logic [$clog2($rtoi($sqrt(num_pixels)))-1:0] col_counter;

   // Control the output signals
   always_ff @(negedge clk ) begin
      case(state)
        ERASE: begin
           erase <= 1;
           read <= 0;
           expose <= 0;
           convert <= 0;
        end
        EXPOSURE: begin
           erase <= 0;
           read <= 0;
           expose <= 1;
           convert <= 0;
        end
        CONVERSION: begin
           erase <= 0;
           read <= 0;
           expose <= 0;
           convert = 1;
        end
        READ: begin
           erase <= 0;
           read <= 1;
           expose <= 0;
           convert <= 0;
        end
      endcase // case (state)
   end // always @ (state)

   // Control the state transitions.
   always_ff @(posedge clk or negedge reset_n) begin
      if(reset_n == 0) begin
         next_state <= ERASE;
         counter <= 0;
         row_counter <= 0;
         col_counter <= 0;
         read_counter <= 0;
      end
      else begin
         case (state)
           ERASE: begin
              if(counter == c_erase) begin
                 next_state <= EXPOSURE;
                 counter <= 0;
              end
              else begin
                 counter <= counter + 1;
              end
           end
           EXPOSURE: begin
              if(counter == c_expose) begin
                 next_state <= CONVERSION;
                 counter <= 0;
              end
              else begin
                 counter <= counter + 1;
              end
           end
           CONVERSION: begin
              if(counter == c_convert) begin
                 next_state <= READ;
                 counter <= 0;
              end
              else begin
                 counter <= counter + 1;
              end
           end
           READ:
             if (counter == c_read) begin
                next_state <= ERASE;
                counter <= 0;
                row_counter <= 0;
                col_counter <= 0;
             end
             else begin
                counter <= counter + 1;
                if (col_counter == $rtoi($sqrt(num_pixels))-1) begin
                   if (row_counter == $rtoi($sqrt(num_pixels))-1) begin
                      row_counter <= 0;
                   end
                   else begin
                      row_counter <= row_counter + 1;
                   end
                   col_counter <= 0;
                end
                else begin
                   col_counter <= col_counter + 1;
                end
             end
         endcase // case (state)
         
         state <= next_state;
      end // reset_n
   end // always @ (posedge clk or posedge reset)
   
   always_ff @(posedge clk) begin
       row_addr <= row_counter;
       col_addr <= col_counter;
   end
endmodule // test
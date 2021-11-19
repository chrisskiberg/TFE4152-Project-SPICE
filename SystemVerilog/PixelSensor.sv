module PIXEL_SENSOR
  (
   input  logic      VBN1,
   input  logic      RAMP,
   input  logic      RESET,
   input  logic      ERASE,
   input  logic      EXPOSE,
   input  logic      READ,
   output logic[7:0] DATA

   );

   logic [7:0]    v_erase = 255;
   logic [7:0]    lsb = 1;

   reg   [7:0]    tmp;
   logic          cmp;
   logic [7:0]    adc;
   
   reg [7:0]      data_temp;

   always_ff @(posedge RAMP or posedge ERASE or posedge EXPOSE or posedge VBN1) begin
      if (ERASE) begin
        adc <= 0;
        cmp <= 0;
        tmp <= v_erase;
      end
      else if (EXPOSE) begin
        // during exposure the voltage on the pixel decreases gradually
        // in real hardware the amount will depend on the amount of light entering the photodiode
        if (VBN1) begin
            tmp <= tmp - lsb;
        end
      end
      else if (RAMP) begin
        adc <= adc + lsb;
        if(adc > tmp)
            cmp <= 1;
      end
   end

   always_ff @(posedge cmp) begin
         data_temp = tmp;
   end
 
   always_comb begin
      DATA = READ ? data_temp : 8'bZ;
   end
endmodule
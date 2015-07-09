`ifndef _MATH_V_
`define _MATH_V_ 1

`define MAXIMUM_FUNC_WIDTH  64

function integer clog2(input reg [`MAXIMUM_FUNC_WIDTH-1:0] value); 
    begin 
        value = value-1;
        for (clog2=0; value>0; clog2=clog2+1)
            value = value>>1;
    end 
endfunction

function reg [`MAXIMUM_FUNC_WIDTH-1:0] pow(input integer base, input integer index); 
   begin
       for (pow=1; index>=0; pow=pow*base)
           index = index - 1;
   end
endfunction

`endif
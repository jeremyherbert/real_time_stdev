// this define is only used for readability
`define NUMBER_OF_INTEGER_BITS_DISCARDED (2*(NUMBER_OF_BLOCKS-i))

`include "math.v"

// this module calculates the integer sqrt of an input in floor(N/2)+1 cycles, where N is the number of input bits
// it is also fully pipelined, capable of accepting a new integer every clock cycle
module sqrt #(parameter INTEGER_INPUT_WIDTH = 28) (
    input wire [INTEGER_INPUT_WIDTH-1:0] integer_input,
    output wire [(INTEGER_INPUT_WIDTH/2+1):0] remainder,
    output wire [(INTEGER_INPUT_WIDTH/2-1):0] result,

    input wire reset,
    input wire clk
  );

  localparam NUMBER_OF_BLOCKS = INTEGER_INPUT_WIDTH/2;

  // first, we generate an interconnect chain to connect together all of the sqrt_remainder modules
  // these need to have specific widths, or we will get lots of synthesis errors
  genvar i;
  generate
    for (i=NUMBER_OF_BLOCKS-1; i >= 0; i=i-1) begin : interconnect_chain
      wire [INTEGER_INPUT_WIDTH-1 - `NUMBER_OF_INTEGER_BITS_DISCARDED:0] integer_interconnect;
      wire [NUMBER_OF_BLOCKS-1+2 - i:0] remainder_interconnect ;
      wire [NUMBER_OF_BLOCKS-1 - i:0] result_interconnect;
    end : interconnect_chain
  endgenerate

  // now we simply attach the modules together, with the initial conditions specified for the first block only
  generate 
    for (i = NUMBER_OF_BLOCKS-1; i >= 0; i=i-1) begin : sqrt_chain
      if (i == (NUMBER_OF_BLOCKS-1)) begin // if this is the first block
        sqrt_remainder #(.RADICAND_WIDTH(INTEGER_INPUT_WIDTH), .STAGE_NUMBER(i)) inst (
            .reset(reset),
            .clk(clk),

            .integer_input(integer_input), // feed the initial conditions to the chain
            .remainder_previous(2'b00),
            .result_previous(1'b0), 

            .integer_output(interconnect_chain[i].integer_interconnect),
            .remainder(interconnect_chain[i].remainder_interconnect),
            .result(interconnect_chain[i].result_interconnect)
        );
      end else begin
        sqrt_remainder #(.RADICAND_WIDTH(INTEGER_INPUT_WIDTH), .STAGE_NUMBER(i)) inst (
            .reset(reset),
            .clk(clk),

            .integer_input(interconnect_chain[i+1].integer_interconnect),
            .remainder_previous(interconnect_chain[i+1].remainder_interconnect),
            .result_previous(interconnect_chain[i+1].result_interconnect),

            .integer_output(interconnect_chain[i].integer_interconnect),
            .remainder(interconnect_chain[i].remainder_interconnect),
            .result(interconnect_chain[i].result_interconnect)
        );
      end
    end : sqrt_chain
  endgenerate

  // delay the result so that we don't output garbage for the first two cycles
  reg [clog2(INTEGER_INPUT_WIDTH)-1:0] pipeline_fill_delay;

  // // attach the outputs
  wire output_valid = (pipeline_fill_delay == (INTEGER_INPUT_WIDTH-1));
  assign result = output_valid ? interconnect_chain[0].result_interconnect : 0;
  assign remainder = output_valid ? interconnect_chain[0].remainder_interconnect : 0;
  
  always @(posedge clk) begin
    if (reset == 1'b0) pipeline_fill_delay <= 0;
    else begin
      if (!output_valid) pipeline_fill_delay <= pipeline_fill_delay + 1;
    end
  end

endmodule

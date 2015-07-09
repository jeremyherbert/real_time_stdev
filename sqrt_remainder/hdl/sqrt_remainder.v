// these defines are only used for readability
`define INTEGER_INPUT_WIDTH ((STAGE_NUMBER+1) * 2)
`define INTEGER_OUTPUT_WIDTH `INTEGER_INPUT_WIDTH-2
`define REMAINDER_INPUT_WIDTH (((RADICAND_WIDTH/2) + 1) - STAGE_NUMBER)
`define RESULT_INPUT_WIDTH ((RADICAND_WIDTH/2) - STAGE_NUMBER - 1)
`define REMAINDER_OUTPUT_WIDTH (`REMAINDER_INPUT_WIDTH+1)
`define RESULT_OUTPUT_WIDTH `RESULT_INPUT_WIDTH+1

`define IS_FIRST_STAGE (STAGE_NUMBER == ((RADICAND_WIDTH/2) - 1))
`define IS_LAST_STAGE (STAGE_NUMBER == 0)

// this is the recursive sqrt remainder block
// you shouldn't have to do anything with this
module sqrt_remainder 
	#(
		parameter RADICAND_WIDTH = 8, 
		parameter STAGE_NUMBER = 3
	)
	( 
		input wire [`INTEGER_INPUT_WIDTH-1:0] integer_input,
		input wire [`REMAINDER_INPUT_WIDTH-1:0] remainder_previous,
		input wire [(`RESULT_INPUT_WIDTH-1 + `IS_FIRST_STAGE):0] result_previous, // we need to force the first input to have a size of 1 for the first block
		
		output reg [`INTEGER_OUTPUT_WIDTH-1:0] integer_output,
		output reg signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder,
		output reg [`RESULT_OUTPUT_WIDTH-1:0] result,

		input wire reset,
		input wire clk
	);


	reg phase; // state variable

	// the following wires are used to force twos-complement arithmetic
	wire signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_new_without_add;
	assign remainder_new_without_add = {
		remainder_previous[`REMAINDER_INPUT_WIDTH-2:0], // drop the sign bit
		integer_input[{STAGE_NUMBER, 1'b1}], // integer_input[2 * bit + 1]
		integer_input[{STAGE_NUMBER, 1'b0}] // integer_input[2 * bit]
	};

	wire signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_greater_than_or_equal_to_0_subtractor;
	wire signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_less_than_0_addition;
	assign remainder_greater_than_or_equal_to_0_subtractor = {result_previous, 2'b01};
	assign remainder_less_than_0_addition = {result_previous, 2'b11};

	reg signed [`REMAINDER_OUTPUT_WIDTH-1:0] remainder_delay;
	reg [`INTEGER_INPUT_WIDTH-1:0] integer_output_delay;
	reg [(`RESULT_INPUT_WIDTH-1 + `IS_FIRST_STAGE):0] result_previous_delay;

	always @(posedge clk) begin
		//if (reset == 1'b0) phase <= 0;
		//else begin
			//if (phase == 1'b0) begin
				// phase 1: calculate new remainder
				if (remainder_previous[`REMAINDER_INPUT_WIDTH-1] == 1'b0) begin // if sign bit indicates the number is positive
					remainder_delay <= remainder_new_without_add - remainder_greater_than_or_equal_to_0_subtractor;
				end else begin
					remainder_delay <= remainder_new_without_add + remainder_less_than_0_addition;
				end

				remainder <= remainder_delay;
				// save the integer into our local shift register, while dropping the top two bits
				// we need to force the output to have a size of 1 for the last block in the chain
				integer_output_delay <= integer_input[(`INTEGER_OUTPUT_WIDTH-1 + `IS_LAST_STAGE):0];
				integer_output <= integer_output_delay;
			//end else begin

				result_previous_delay <= result_previous;
				// phase 2: calculate new result
				if (remainder_delay[`REMAINDER_OUTPUT_WIDTH-1] != 1'b1) begin // if it is positive
					result <= {result_previous_delay, 1'b1};
				end else begin
					result <= {result_previous_delay, 1'b0};
					if (`IS_LAST_STAGE) remainder <= remainder_delay + {result_previous_delay, 2'b01};
				end


			//end

			//phase <= ~phase;
		//end
	end

	// initial begin
	// 	$display("sqrt_remainder block: RADICAND_WIDTH: %d, STAGE_NUMBER: %d (IS_FIRST_STAGE: %d, IS_LAST_STAGE: %d)", RADICAND_WIDTH, STAGE_NUMBER, `IS_FIRST_STAGE, `IS_LAST_STAGE);
	// 	$display("\tINTEGER_INPUT_WIDTH: \t\t%d", `INTEGER_INPUT_WIDTH);
	// 	$display("\tINTEGER_OUTPUT_WIDTH: \t\t%d", `INTEGER_OUTPUT_WIDTH);
	// 	$display("\tREMAINDER_INPUT_WIDTH: \t\t%d", `REMAINDER_INPUT_WIDTH);
	// 	$display("\tREMAINDER_OUTPUT_WIDTH: \t\t%d", `REMAINDER_OUTPUT_WIDTH);
	// 	$display("\tRESULT_INPUT_WIDTH: \t\t%d", `RESULT_INPUT_WIDTH);
	// 	$display("\tRESULT_OUTPUT_WIDTH: \t\t%d", `RESULT_OUTPUT_WIDTH);
	// end

endmodule
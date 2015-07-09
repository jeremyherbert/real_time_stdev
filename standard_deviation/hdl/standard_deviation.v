
module standard_deviation_filter 
	#(parameter WIDTH=14, parameter WINDOW_WIDTH=7)
	(
		input wire [WIDTH-1:0] data_in,
		output wire [WIDTH-1:0] data_out,

		input wire reset,
		input wire clk
		
	);

	wire [WIDTH*2-1:0] variance_out;

	variance #(.WIDTH(WIDTH), .WINDOW_WIDTH(WINDOW_WIDTH)) variance_inst (
		.data_in(data_in),
		.data_out(variance_out),
		.reset(reset),
		.clk(clk)
	);

	sqrt #(.INTEGER_INPUT_WIDTH(28)) sqrt_inst (
		.integer_input(variance_out),
		.result(data_out),
		.reset(reset),
		.clk(clk)
	);

endmodule
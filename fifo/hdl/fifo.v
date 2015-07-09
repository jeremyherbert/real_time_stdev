
module fifo #(parameter WIDTH=8, parameter DEPTH=10) (
	input wire [WIDTH-1:0] data_in,
	output reg [WIDTH-1:0] data_out,

	output reg data_valid,

	input wire reset,
	input wire clk
	);

	function integer clog2(input reg [`MAXIMUM_FUNC_WIDTH-1:0] value); 
    	begin 
			value = value-1;
			for (clog2=0; value>0; clog2=clog2+1)
				value = value>>1;
		end 
	endfunction

	reg [WIDTH-1:0] data [DEPTH-1:0];
	reg [clog2(DEPTH)-1:0] write_pointer;
	reg [clog2(DEPTH)-1:0] read_pointer;

	always @(posedge clk) begin
		if (reset == 1'b0) begin
			write_pointer <= 0;
			read_pointer <= 1;
			data_valid <= 0;
		end else begin
			if (write_pointer == DEPTH-1) write_pointer <= 0;
			else write_pointer <= write_pointer + 1;

			if (read_pointer == DEPTH-1) read_pointer <= 0;
			else read_pointer <= read_pointer + 1;

			data[write_pointer] <= data_in;
			data_out <= data[read_pointer];
		end

		if (read_pointer == 0) data_valid <= 1'b1;
	end

endmodule
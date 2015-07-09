`define WINDOW_SIZE ((2**WINDOW_WIDTH))

`define LARGE_CLOG2(x) clog2(x)

`define MAXIMUM_ROLLING_SUM ((2**WIDTH)-1)
`define MAXIMUM_ROLLING_SQUARES_SUM  (pow(2,(WIDTH*2))-1)

`include "math.v"

module variance #(
		parameter WIDTH=14, // data input width
		parameter WINDOW_WIDTH=7 // window size will be 2^WINDOW_WIDTH, so the default here is a size of 128
	)
	(
        input wire [WIDTH-1:0] data_in,
        output reg [WIDTH*2-1:0] data_out,
        
        input wire reset,
        input wire clk
    );

    reg [`LARGE_CLOG2(`MAXIMUM_ROLLING_SUM * `WINDOW_SIZE)-1:0] rolling_sum;
    reg [`LARGE_CLOG2(`MAXIMUM_ROLLING_SQUARES_SUM * `WINDOW_SIZE)-1:0] rolling_squares_sum;

    wire [WIDTH-1:0] fifo_dout;
    wire fifo_data_valid;

    fifo #(.WIDTH(WIDTH), .DEPTH(`WINDOW_SIZE)) fifo_inst (
    	.data_in(data_in),
    	.data_out(fifo_dout),
    	.data_valid(fifo_data_valid),
    	.reset(reset),
    	.clk(clk)
    );

    reg [`LARGE_CLOG2(`MAXIMUM_ROLLING_SUM*`MAXIMUM_ROLLING_SUM * (`WINDOW_SIZE+1))-1:0] mean_squared [2:0];
    reg [`LARGE_CLOG2(`MAXIMUM_ROLLING_SQUARES_SUM * (`WINDOW_SIZE+1))-1:0] mean_of_squares [2:0];

    reg [WIDTH-1:0] data_in_delay [2:0];
    reg [WIDTH-1:0] fifo_dout_delay [2:0];
    reg [`LARGE_CLOG2(pow(2,WIDTH*2))-1:0] data_in_squared [2:0];
    reg [`LARGE_CLOG2(pow(2,WIDTH*2))-1:0] fifo_dout_squared [2:0];

    always @(posedge clk) begin
    	if (reset == 1'b0) begin
    		rolling_sum <= 0;
    		rolling_squares_sum <= 0;

    		data_in_delay[0] <= 0; data_in_delay[1] <= 0; data_in_delay[2] <= 0;
    		data_in_squared[0] <= 0; data_in_squared[1] <= 0; data_in_squared[2] <= 0;
    		fifo_dout_delay[0] <= 0; fifo_dout_delay[1] <= 0; fifo_dout_delay[2] <= 0;
    		fifo_dout_squared[0] <= 0; fifo_dout_squared[1] <= 0; fifo_dout_squared[2] <= 0;

    	end else begin
    		data_in_delay[0] <= data_in;
			data_in_delay[1] <= data_in_delay[0];
			data_in_delay[2] <= data_in_delay[1]; // delay is required to keep data in sync with DSP output

			data_in_squared[0] <= data_in*data_in;
			data_in_squared[1] <= data_in_squared[0];
			data_in_squared[2] <= data_in_squared[1]; // pipeline DSP output

    		if (fifo_data_valid) begin 
    			fifo_dout_delay[0] <= fifo_dout;
    			fifo_dout_delay[1] <= fifo_dout_delay[0];
    			fifo_dout_delay[2] <= fifo_dout_delay[1]; // delay is required to keep data in sync with DSP output

    			fifo_dout_squared[0] <= fifo_dout*fifo_dout;
    			fifo_dout_squared[1] <= fifo_dout_squared[0];
    			fifo_dout_squared[2] <= fifo_dout_squared[1]; // pipeline DSP output

    			rolling_sum <= rolling_sum + data_in_delay[2] - fifo_dout_delay[2];
    			rolling_squares_sum <= rolling_squares_sum + data_in_squared[2] - fifo_dout_squared[2];

    			mean_squared[0] <= (rolling_sum >> WINDOW_WIDTH) * (rolling_sum >> WINDOW_WIDTH);
    			mean_squared[1] <= mean_squared[0];
    			mean_squared[2] <= mean_squared[1];

    			mean_of_squares[0] <= (rolling_squares_sum >> WINDOW_WIDTH);
    			mean_of_squares[1] <= mean_of_squares[0];
    			mean_of_squares[2] <= mean_of_squares[1];

    			data_out <= mean_of_squares[2] - mean_squared[2];
    		end else begin
    			// just load up the sums
    			rolling_sum <= rolling_sum + data_in_delay[2];
    			rolling_squares_sum <= rolling_squares_sum + data_in_squared[2];
    		end
    	end
    end

    initial begin
    	$dumpfile("dump.vcd");
    	$dumpvars(0, variance);
  	end
endmodule
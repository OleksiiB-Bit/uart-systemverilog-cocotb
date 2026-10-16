module baud_gen #(
	parameter int CLK_FREQ = 50_000_000,
	parameter int BAUD_RATE = 115_200
)(
	input logic clk,
	input logic reset,
	output logic tick_baud_x16,
	output logic tick_baud
);

localparam int DIV_LIMIT_16X = CLK_FREQ / (BAUD_RATE * 16);
localparam int WIDTH_16X = $clog2(DIV_LIMIT_16X);
logic [WIDTH_16X - 1 : 0] counter_16x;
logic [3:0] counter_1x;
always_ff @(posedge clk or posedge reset) begin
	if (reset) begin
		counter_16x <= '0;
		counter_1x <= '0;
		tick_baud_x16 <= 1'b0;
		tick_baud <= 1'b0;
	end else begin
		tick_baud_x16 <= 0;
		tick_baud <= 0;
		if (counter_16x >= DIV_LIMIT_16X - 1) begin
			tick_baud_x16 <= 1'b1;
			counter_16x <= '0;
			if (counter_1x == 4'd15) begin
				counter_1x <= '0;
				tick_baud <= 1'b1;
			end else begin
				counter_1x <= counter_1x + 1'b1;
			end
		end else begin
			counter_16x <= counter_16x + 1'b1;
		end
	end
end

endmodule

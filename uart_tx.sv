module uart_tx(
	input logic clk,
	input logic reset,
	input logic tick,
	input logic tx_en,
	input logic [7:0] tx_din,
	output logic tx,
	output logic tx_ready
);

typedef enum logic [1:0] {
	IDLE,
	START,
	DATA,
	STOP
} state_t;

state_t state;
logic [7:0] data;
logic [2:0] bit_counter;

always_ff @(posedge clk or posedge reset) begin
	if (reset) begin
		state <= IDLE;
		data <= '0;
		bit_counter <= '0;
		tx <= 1'b1;
		tx_ready <= 1'b1;
	end else begin
		case (state)
			IDLE: begin
				tx<= 1'b1;
				tx_ready <= 1'b1;
				if (tx_en) begin
					data <= tx_din;
					bit_counter <= '0;
					tx_ready <= 1'b0;
					state <= START;
				end
			end
			START: begin
				tx <= 1'b0;
				tx_ready <= 1'b0;
				if (tick) begin
					tx <= data[0];
					state <= DATA;
				end
			end
			DATA: begin
				tx_ready <= 1'b0;
				if (tick) begin
					if (bit_counter == 3'd7) begin
						state <= STOP;
						tx <= 1'b1;
					end else begin
						bit_counter <= bit_counter + 1'b1;
						tx <= data[1];
						data <= {1'b0, data[7:1]};
					end
				end
			end
			STOP: begin
				tx <= 1'b1;
				tx_ready <= 1'b0;
				if (tick) begin
					tx_ready <= 1'b1;
					state <= IDLE;
				end
			end
			default: state <= IDLE;
		endcase
	end
end
endmodule

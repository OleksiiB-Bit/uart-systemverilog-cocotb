module uart_rx(
	input logic tick,
	input logic reset,
	input logic clk,
	input logic rx,
	output logic [7:0] rx_data,
	output logic rx_valid
);

typedef enum logic [1:0] {
	RX_IDLE,
	RX_START,
	RX_DATA,
	RX_STOP
} state_t;

logic rx_sync1, rx_sync2;
logic [7:0] data;
logic [3:0] sample_counter, bit_counter;
state_t state;

always_ff @(posedge clk or posedge reset) begin
	if (reset) begin
		rx_valid <= 1'b0;
		state <= RX_IDLE;
		rx_sync1 <= 1'b1;
		rx_sync2 <= 1'b1;
	end else begin
		rx_sync1 <= rx;
		rx_sync2 <= rx_sync1;
		rx_valid <= 1'b0;
		case (state)
			RX_IDLE: begin
				sample_counter <= '0;
				bit_counter <= '0;
				if (rx_sync2 == 1'b0) begin
					state <= RX_START;
				end
			end
			RX_START: begin
				if (tick) begin
					if (sample_counter == 4'd7) begin
						if (rx_sync2==1'b0) state <= RX_DATA;
						else state <= RX_IDLE;
						sample_counter <= '0;
					end else state <= RX_IDLE;
				end else sample_counter <= sample_counter + 1'b1;
			end
			RX_DATA: begin
				if (tick) begin
					if (sample_counter == 4'd15) begin
						sample_counter <= '0;
						data <= {rx_sync2, data[7:1]};
						if (bit_counter == 4'd7) state <= RX_STOP;
						else bit_counter <= bit_counter + 1'b1;
					end else begin
						sample_counter <= sample_counter + 1'b1;
					end
				end
			end
			RX_STOP: begin
				if (tick) begin
					if (sample_counter == 4'd15) begin
						sample_counter <= '0;
						if (rx_sync2) begin
							rx_data <= data;
							rx_valid <= 1'b1;
						end
						state <= RX_IDLE;
					end else sample_counter <= sample_counter + 1'b1;
				end
			end
			default: state <= RX_IDLE;
		endcase
	end
end

endmodule

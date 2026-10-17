module uart_top #(
	parameter int CLK_FREQ = 50_000_000,
	parameter int BAUD_RATE = 115_200
)(
	input logic clk,
	input logic reset,
	input logic tx_en,
	input logic [7:0] tx_din,
	input logic rx,
	output logic tx,
	output logic tx_ready,
	output logic [7:0] rx_data,
	output logic rx_valid
);

logic tick_baud_x16, tick_baud;

baud_gen #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) u_baud_gen (.tick_baud(tick_baud), .tick_baud_x16(tick_baud_x16), .clk(clk), .reset(reset));
uart_rx u_rx(.clk(clk), .reset(reset), .tick(tick_baud_x16), .rx(rx), .rx_data(rx_data), .rx_valid(rx_valid));
uart_tx u_tx(.clk(clk), .reset(reset), .tick(tick_baud), .tx_en(tx_en), .tx(tx), .tx_din(tx_din), .tx_ready(tx_ready));

endmodule

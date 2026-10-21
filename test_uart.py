import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, with_timeout
import random

async def connect_loopback(dut):
	"""Verbindet den TX-Ausgang direkt mit dem RX-Eingang in der Simulation."""
	while True:
		await RisingEdge(dut.clk)
		dut.rx.value = dut.tx.value

@cocotb.test()
async def test_uart_loopback(dut):
	"""Automatisierter Loopback-Test für den UART-Top-Controller."""
	# 1. Taktgenerator starten (50 MHz / 20 ns Periode)
	clock = Clock(dut.clk, 20, unit="ns")
	cocotb.start_soon(clock.start())

	# 2. Loopback-Verbindung im Hintergrund aktivieren
	cocotb.start_soon(connect_loopback(dut))

	# 3. Initialer Reset
	dut.reset.value = 1
	dut.tx_en.value = 0
	dut.tx_din.value = 0
	await Timer(100, unit="ns")
	dut.reset.value = 0
	await RisingEdge(dut.clk)

	assert dut.tx.value == 1, "Fehler: Die TX-Leitung muss im Leerlauf 1 sein!"

	# 4. Testarray mit 10 Bytes (feste Muster + Zufallsbytes)
	test_bytes = [0x55, 0xA5, 0x00, 0xFF, 0x41] + [random.randint(0, 255) for _ in range(5)]

	for byte_to_send in test_bytes:
	# Warten, bis der Sender bereit ist
		while dut.tx_ready.value != 1:
			await RisingEdge(dut.clk)
		# Sende-Impuls geben
		dut.tx_din.value = byte_to_send
		dut.tx_en.value = 1
		await RisingEdge(dut.clk)
		dut.tx_en.value = 0

		# Warten auf rx_valid vom Empfänger (Timeout 200 µs pro Byte)
		await with_timeout(RisingEdge(dut.rx_valid), 200, timeout_unit="us")
		received_byte = int(dut.rx_data.value)

		dut._log.info(f"Gesendet: 0x{byte_to_send:02X} | Empfangen: 0x{received_byte:02X}")
		assert received_byte == byte_to_send, f"Fehler! Gesendet: 0x{byte_to_send:02X}, Empfangen: 0x{received_byte:02X}"

	dut._log.info("Alle 10 Bytes wurden erfolgreich und fehlerfrei übertragen und empfangen!")

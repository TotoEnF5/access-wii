extends Node

signal sword_exited
signal sword_entered


@export var serial_port: String

var _serial: GdSerial


func vibrate(time_ms: float) -> void:
	_serial.writeline("VIBRATE")
	_serial.writeline(str(time_ms))


func _ready() -> void:
	print("Connecting to the Arduino on port " + serial_port + "...")
	
	_serial = GdSerial.new()
	_serial.set_port(serial_port)
	_serial.set_baud_rate(9600)

	if _serial.open():
		print("Connected to " + serial_port + "!")
	else:
		print("Failed to connect to " + serial_port + "!")
		
	vibrate(100)


func _process(_delta: float) -> void:
	if _serial.bytes_available() > 0:
		var message = _serial.readline()
		if message == "ON":
			sword_exited.emit()
		elif message == "OFF":
			sword_entered.emit()


func _exit_tree() -> void:
	_serial.close()

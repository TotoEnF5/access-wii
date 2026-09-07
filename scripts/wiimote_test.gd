extends Control


var thread: Thread # need this so the thread doesn't die at the end of _ready


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thread = Thread.new()
	thread.start(_connect_wiimotes_thread)


func _process(delta: float) -> void:
	for wiimote in GDWiimoteServer.get_connected_wiimotes():
		$Label2.text = str(wiimote.get_processed_accel())
		break


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player1_slash"):
		$Label.text = "player 1 pressed A"

	if event.is_action_pressed("player2_slash"):
		$Label.text = "player 2 pressed A"


func _connect_wiimotes_thread() -> void:
	GDWiimoteServer.initialize_connection(true)


func _on_button_pressed() -> void:
	GDWiimoteServer.finalize_connection()
	for wiimote in GDWiimoteServer.get_connected_wiimotes():
		wiimote.set_motion_processing(true)
		wiimote.set_motion_sensing(true)
	$Label.text = "connected!"


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_button_3_pressed() -> void:
	for wiimote in GDWiimoteServer.get_connected_wiimotes():
		wiimote.toggle_rumble()

extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Thread.new().start(_connect_wiimotes_thread)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player1_slash"):
		$Label.text = "player 1 pressed A"

	if event.is_action_pressed("player2_slash"):
		$Label.text = "player 2 pressed A"


func _connect_wiimotes_thread() -> void:
	GDWiimoteServer.initialize_connection(true)


func _on_button_pressed() -> void:
	GDWiimoteServer.finalize_connection()
	$Label.text = "connected!"

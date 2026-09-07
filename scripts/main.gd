extends Control


@export var min_time: float = 1.0
@export var max_time: float = 3.0

@onready var _color_rect = $ColorRect
@onready var _label = $Label
@onready var _timer = $Timer

var _waiting_for_input: bool = false


func _ready() -> void:
	_reset()


func _input(event: InputEvent) -> void:
	if not _waiting_for_input:
		return

	if event.is_action_pressed("player1_slash"):
		_label.text = "player 1 won"
		$Timer2.start()

	if event.is_action_pressed("player2_slash"):
		_label.text = "player 2 won"
		$Timer2.start()


func _reset() -> void:
	_waiting_for_input = false
	_color_rect.color = Color.BLUE
	_label.text = "wait.."
	_timer.wait_time = randf_range(min_time, max_time)
	_timer.start()


func _on_timer_timeout() -> void:
	_waiting_for_input = true
	_color_rect.color = Color.RED
	_label.text = "slash!"


func _on_timer_2_timeout() -> void:
	_reset()

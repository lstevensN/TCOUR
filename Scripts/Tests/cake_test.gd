extends Node

var game

@onready var _countdown_text : RichTextLabel = $Countdown/Canvas/CountdownText
@export var _countdown : float = 3
var _minigame_started : bool = false
var _go_timer : float = 1
var _game : PackedScene

func _ready() -> void:
	_game = load("res://Scenes/cake_minigame.tscn")
	game = _game.instantiate()
	game.game_started = false
	add_child(game)

func _process(delta: float) -> void:
	if not _minigame_started:
		_countdown -= delta * 1.5
		var count = ceili(_countdown)
		if count <= 0:
			_go_timer -= delta
			
			if _go_timer < 0:
				_minigame_started = true
				_countdown_text.text = ""
				game.game_started = true
			else:
				_countdown_text.text = "GO!"
		else:
			_countdown_text.text = str(ceili(_countdown))

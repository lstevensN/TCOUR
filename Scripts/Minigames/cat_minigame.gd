extends Node

# PRIVATE VARIABLES
var _player_power : float = 5
var _strength : float = 1
var _target_value : float = 60

var _resistance : float = 0
var _bars : Array = []

# UI ELEMENTS
@onready var left_bar = $Canvas/LeftBar
@onready var middle_bar = $Canvas/MiddleBar
@onready var right_bar = $Canvas/RightBar


# PRIVATE FUNCTIONS

func _ready() -> void:
	# Add bars to array
	_bars.append(left_bar)
	_bars.append(middle_bar)
	_bars.append(right_bar)
	
	# Set fill mode to FILL_BOTTOM_TO_TOP
	for bar in _bars: bar.fill_mode = 3

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_left_click"): for bar in _bars: bar.value += _player_power
	if event.is_action_pressed("game_right_click"): for bar in _bars: bar.value -= _player_power

func _process(delta: float) -> void:
	for bar in _bars:
		if bar.value < _target_value:
			var difference = absf(_target_value - bar.value)
			
			if difference < 10: _resistance = -20
			elif difference < 20: _resistance = -15
			elif difference < 30: _resistance = -10
			else: _resistance = -5
		else:
			var difference = absf(bar.value - _target_value)
			
			if difference < 10: _resistance = 20
			elif difference < 20: _resistance = 15
			elif difference < 30: _resistance = 10
			else: _resistance = 5
		
		if bar == left_bar: _strength = 1
		elif bar == middle_bar: _strength = 1.3
		elif bar == right_bar: _strength = 1.5
		
		bar.value += _resistance * _strength * delta

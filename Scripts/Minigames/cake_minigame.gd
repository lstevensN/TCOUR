extends Node

# PUBLIC VARIABLES
@export var bpm : float = 100
var clicked : bool = false
@export var game_started : bool = false
var game_timer : float = 0
var hit : bool = false
var hit_type : String = ""

# PRIVATE VARIABLES
var _game_sequence : Array = [
	[ "left", 4 ],
	[ "right", 4 ],
	[ "left", 1 ],
	[ "right", 1 ],
	[ "left", 1 ],
	[ "right", 1 ],
	[ "left", 2 ],
	[ "right", 2 ],
	[ "left", 1 ],
	[ "right", 1 ],
	[ "left", 1 ],
	[ "right", 1 ]
]
var _hit_handled : bool = false
var _current_segment : int = 0
var _miss_check : bool = false
var _segment_length_counter : int = 0

var _left_click_down : bool = false
var _right_click_down : bool = false

var _bpm_interval : float
var _click_time : float = 0
var _downbeat : float = 0
var _tick_done : bool = false

var _bpm_down_display_texture: CompressedTexture2D
var _bpm_up_display_texture: CompressedTexture2D

var _click_indicator_texture : CompressedTexture2D
var _neutral_indicator_texture : CompressedTexture2D

var _player_left : CompressedTexture2D
var _player_neutral : CompressedTexture2D
var _player_right : CompressedTexture2D
var _player_oops : CompressedTexture2D

# UI ELEMENTS
@onready var _bpm_display : TextureRect = $Canvas/BPMDisplay
@onready var _game_timer_display: RichTextLabel = $Canvas/GameTimer
@onready var _game_text : RichTextLabel = $Canvas/GameText
@onready var _hit_text : RichTextLabel = $Canvas/HitText
@onready var _left_indicator : TextureRect = $Canvas/LeftIndicator
@onready var _right_indicator : TextureRect = $Canvas/RightIndicator
@onready var _player : TextureRect = $Canvas/Player


# PRIVATE FUNCTIONS

func _ready() -> void:
	# Load textures
	_bpm_down_display_texture = load("res://Assets/placeholder_circle_white.png")
	_bpm_up_display_texture = load("res://Assets/placeholder_circle_black.png")
	_click_indicator_texture = load("res://Assets/click_indicator.png")
	_neutral_indicator_texture = load("res://Assets/neutral_click_indicator.png")
	_player_left = load("res://Assets/player_with_pin.png")
	_player_neutral = load("res://Assets/player.png")
	_player_right = load("res://Assets/player_with_bowl.png")
	_player_oops = load("res://Assets/player_oops.png")
	
	# Assign default textures
	_bpm_display.texture = _bpm_up_display_texture
	_left_indicator.texture = _neutral_indicator_texture
	_right_indicator.texture = _neutral_indicator_texture
	_player.texture = _player_neutral
	
	# Reset variables
	game_timer = 0
	hit = true
	hit_type = _game_sequence[_current_segment][0]
	_bpm_interval = 60 / bpm  # I don't know why, but this seems to work (really thought it'd be 60???)
	_tick_done = false
	_click_time = 0

func _input(event: InputEvent) -> void:
	if game_started:
		if event.is_action_pressed("game_left_click") and not _left_click_down: _handle_left_click()
		if event.is_action_pressed("game_right_click") and not _right_click_down: _handle_right_click()
		
		if event.is_action_released("game_left_click"): _left_click_down = false
		if event.is_action_released("game_right_click"): _right_click_down = false

func _process(delta: float) -> void:
	if game_started:
		# Game Timer
		game_timer += delta
		if game_timer < 10:
			_game_timer_display.text = '0' + str(floori(game_timer)) + ':' + str(floori((game_timer - floorf(game_timer)) * 100))
		else:
			_game_timer_display.text = str(floori(game_timer)) + ':' + str(floori((game_timer - floori(game_timer)) * 100))
		
		# Click Time
		if not clicked: _click_time += delta
		
		# BPM Display + Hit Check
		_downbeat = ((game_timer / _bpm_interval) - int(game_timer / _bpm_interval))
		
		if roundi(_downbeat) % 2 == 0:
			_bpm_display.texture = _bpm_down_display_texture
			hit = true
			_miss_check = false
		else:
			_bpm_display.texture = _bpm_up_display_texture
			_left_indicator.texture = _neutral_indicator_texture
			_right_indicator.texture = _neutral_indicator_texture
			hit = false
			_hit_handled = false
		 
		# Miss Check & Early Hit Validation
		if not _miss_check and not hit and _downbeat > 0.85:
			_miss_check = true
			
			if not clicked and hit_type != "none":
				_game_text.text = "Missed. . ."
				_game_text.modulate.a = 1
				_player.texture = _player_neutral
			
			hit_type = _game_sequence[_current_segment][0]
			_hit_text.text = hit_type
		
		_game_text.modulate.a -= delta * 2
		
		if _left_click_down or _right_click_down:
			_player.scale = Vector2(1.1, 1.1)
		else: _player.scale = Vector2(1, 1)
		
		if hit and not _hit_handled:
			_hit_handled = true
			
			clicked = false
			_click_time = 0
			
			if hit_type == "left":
				_left_indicator.texture = _click_indicator_texture
			elif hit_type == "right":
				_right_indicator.texture = _click_indicator_texture
			
			_segment_length_counter += 1
			if _segment_length_counter == _game_sequence[_current_segment][1]:
				_current_segment += 1
				_segment_length_counter = 0
			if _current_segment == _game_sequence.size(): _current_segment = 0

func _handle_left_click():
	_left_click_down = true
	
	if hit_type == "left" and not clicked:
		if not hit:
			if _downbeat > 0.9: _game_text.text = "Early. . ."
			else: _game_text.text = "Late. . ."
		else: _game_text.text = "Nice!"
		
		_player.texture = _player_left
	else:
		_game_text.text = "Oops!"
		_player.texture = _player_oops
	
	_game_text.modulate.a = 1
	
	clicked = true

func _handle_right_click():
	_right_click_down = true
	
	if hit_type == "right" and not clicked:
		if not hit:
			if _downbeat > 0.9: _game_text.text = "Early. . ."
			else: _game_text.text = "Late. . ."
		else: _game_text.text = "Nice!"
		
		_player.texture = _player_right
	else:
		_game_text.text = "Oops!"
		_player.texture = _player_oops
	
	_game_text.modulate.a = 1
	
	clicked = true

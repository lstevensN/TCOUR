extends Node

# PUBLIC VARIABLES
var current_dialogue : Array = ["", 1]
var playing_dialogue : bool = false

# PRIVATE VARIABLES
var _current_text : String = ""
var _dialogue_finished : bool = false
var _dialogue_index : int = 0
var _entry_finished : bool = false
var _entry_index : int = 0
var _key_down : bool = false
var _snap_to_end : bool = false

# UI ELEMENTS
@onready var _ui_canvas : CanvasLayer = $Canvas
@onready var _ui_dialogue : RichTextLabel = $Canvas/Container/Dialogue


# PRIVATE FUNCTIONS

func _ready() -> void:
	# Reset public variables
	current_dialogue = ["", 1]
	playing_dialogue = false
	
	# Reset private variables
	_current_text = ""
	_dialogue_finished = false
	_dialogue_index = 0
	_entry_index = 0
	_key_down = false
	_snap_to_end = false
	
	# Hide dialogue box
	_ui_canvas.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("progress_dialogue"):
		if not _key_down:
			_progress_dialogue()
		_key_down = true
	elif event.is_action_released("progress_dialogue"):
		_key_down = false

func _process(delta: float) -> void:
	if _current_text.length() < current_dialogue[0].length(): _entry_finished = false
	else: _entry_finished = true
	
	if not _entry_finished and Engine.get_process_frames() % ceili(Engine.get_frames_per_second() / current_dialogue[1]) == 0:
		if _snap_to_end: _current_text = current_dialogue[0]
		else: _current_text += current_dialogue[0][_current_text.length()]
		
		# Set dialogue display text
		_ui_dialogue.text = _current_text

func _progress_dialogue():
	if playing_dialogue:
		if not _dialogue_finished:
			if _entry_finished:
				current_dialogue = Globals.DIALOGUE[_dialogue_index][_entry_index]
				_current_text = ""
				_snap_to_end = false
				_entry_index += 1
		
				if _entry_index >= Globals.DIALOGUE[_dialogue_index].size():
					_entry_index = 0
					_dialogue_finished = true
			else: _snap_to_end = true
		elif not _entry_finished: _snap_to_end = true
		else:
			# Hide dialogue box
			if (_ui_canvas.visible): _ui_canvas.visible = false
			
			# Exit dialogue mode
			playing_dialogue = false


# PUBLIC FUNCTIONS

# Play given dialogue entry
func play(index: int):
	if not playing_dialogue and index < Globals.DIALOGUE.size():
		print("Playing dialogue entry #" + str(index))
		
		# Set dialogue entry
		_dialogue_index = index
		
		# Show dialogue box
		_ui_canvas.visible = true;
		
		# Clear dialogue text
		_ui_dialogue.text = ""
		current_dialogue = ["", 1]
		
		# Enter dialogue mode
		_dialogue_finished = false
		_entry_finished = true
		playing_dialogue = true
		_progress_dialogue()

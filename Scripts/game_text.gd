extends RichTextLabel

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	modulate.a -= delta

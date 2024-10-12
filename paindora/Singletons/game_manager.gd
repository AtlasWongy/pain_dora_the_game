extends Node

func _ready() -> void:
	SignalBus.player_died.connect(_on_player_death)
	
func _on_player_death():
	get_tree().paused = true

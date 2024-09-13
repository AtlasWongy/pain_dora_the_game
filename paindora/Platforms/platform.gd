extends Node2D
class_name Platform

signal spawn_next_platform

@export var visibility_notifier: VisibleOnScreenNotifier2D

func _ready() -> void:
	visibility_notifier.screen_exited.connect(_on_screen_exit)
	
func _on_screen_exit() -> void:
	spawn_next_platform.emit()

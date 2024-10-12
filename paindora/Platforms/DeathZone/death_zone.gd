extends Area2D
class_name DeathZone

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	if body is Player:
		SignalBus.player_died.emit()
	
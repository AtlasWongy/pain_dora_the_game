extends Area2D
class_name DeathZone

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	print("The body is: ", body.get_class())
	
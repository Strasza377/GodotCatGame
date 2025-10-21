extends Area2D
class_name Checkpoint

signal checkpoint_reached(cp:Checkpoint)

func _on_body_entered(body):
	if body is Player:
		checkpoint_reached.emit(self)
		body_entered.disconnect(_on_body_entered)

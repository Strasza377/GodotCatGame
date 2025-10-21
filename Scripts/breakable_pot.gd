extends Area2D
class_name Pot

@onready var sprite = $Sprite2D

@export var enemiesToDistract: Array[Enemy]

func become_broken():
	sprite.frame = 1
	for enemy in enemiesToDistract:
		enemy.distract(global_position)
	body_entered.disconnect(_on_body_entered)


func _on_body_entered(body):
	become_broken()

func reset():
	sprite.frame = 0
	body_entered.connect(_on_body_entered)

extends Node2D

class_name Level

signal end_of_level_reached

@export var checkpoints: Array[Checkpoint]
@export var resetters: Array[Resetter]
@export var enemies: Array[Enemy]
@export var pots: Array[Pot]
@export var player: Player
@export var resetTimer:Timer

var currentCheckpoint: Checkpoint = null

var numMeows: int = 0
var numDetected: int = 0

var checkpointReached: bool:
	get:
		return currentCheckpoint != null

func _ready():
	for cp in checkpoints:
		cp.checkpoint_reached.connect(checkpoint_reached)
	for resetter in resetters:
		resetter.resetter_triggered.connect(resetter_hit)
	resetTimer.wait_time = 0.5
	player.playerDetected.connect(_on_player_detected)
	player.meow.connect(_on_player_meowed)
	

func checkpoint_reached(cp:Checkpoint):
	print("checkpoint reached!")
	currentCheckpoint = cp
	cp.checkpoint_reached.disconnect(checkpoint_reached)

func resetter_hit():
	reset_level()

func _on_player_detected():
	numDetected += 1
	resetTimer.start()
	await resetTimer.timeout
	reset_level()

func _on_player_meowed():
	numMeows += 1
	for enemy in enemies:
		enemy.reset(true)
	for pot in pots:
		pot.reset()
	resetTimer.start()
	await resetTimer.timeout
	player.reset_complete()
	
	
func reset_level():
	if checkpointReached:
		player.reset(currentCheckpoint.global_position)
	else:
		player.reset()
	for enemy in enemies:
		enemy.reset()
	for pot in pots:
		pot.reset()

func _on_end_of_level_body_entered(body):
	print("level end reached")
	end_of_level_reached.emit()
	player.playerDetected.disconnect(_on_player_detected)
	player.meow.disconnect(_on_player_meowed)

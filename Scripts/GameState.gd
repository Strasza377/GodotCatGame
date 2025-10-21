extends Node2D

@export var levels: Array[String]

signal game_completed(meows:int, detects:int)

var currentLevelIndex: int = 0
var currentLevelScene
var currentLevel: Level

var numMeows: int = 0
var numDetected: int = 0

func _ready():
	load_level()
	setup_new_level()
	
func load_level():
	currentLevelScene = load(levels[currentLevelIndex])
	currentLevel = currentLevelScene.instantiate()
	add_child(currentLevel)

func unload_level():
	remove_child(currentLevel)
	currentLevel.queue_free()
	
func move_to_next_level():
	currentLevel.end_of_level_reached.disconnect(move_to_next_level)
	numMeows += currentLevel.numMeows
	numDetected += currentLevel.numDetected
	unload_level()
	currentLevelIndex += 1
	if currentLevelIndex >= levels.size():
		game_completed.emit(numMeows, numDetected)
		get_tree().paused = true
		return
	load_level()
	setup_new_level()
	
func setup_new_level():
	currentLevel.end_of_level_reached.connect(move_to_next_level)


func _on_canvas_layer_help_opened(opened):
	get_tree().paused = opened

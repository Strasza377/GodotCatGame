extends CanvasLayer

signal help_opened(opened: bool)

@onready var helpScreen = $HelpScreen
@onready var endScreen = $EndScreen
@onready var stats = $EndScreen/Stats
@onready var helpText = $Control/HelpText

func _ready():
	helpScreen.visible = false
	endScreen.visible = false

func _process(delta):
	if Input.is_action_just_pressed("help"):
		helpScreen.visible = !helpScreen.visible
		help_opened.emit(helpScreen.visible)
		if endScreen.visible:
			get_tree().quit()

func _on_game_state_game_completed(meows, detects):
	stats.text = "Number of Meows: " + str(meows) + "\nTimes Detected: " + str(detects)
	endScreen.visible = true
	helpText.visible = false

func _on_button_button_up():
	get_tree().quit()

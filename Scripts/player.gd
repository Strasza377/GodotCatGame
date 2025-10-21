extends CharacterBody2D

class_name Player

signal playerDetected
signal meow

@export var speed:int = 50
@export var sprintMultiplier:float = 2
@export var maxStamina:int = 300

#onready variables
@onready var animationTree = $AnimationTree
@onready var animationPlayer = $AnimationPlayer
@onready var collisionShape = $CollisionShape2D
@onready var audioStreamPlayer = $AudioStreamPlayer2D
@onready var sprintCooldown = $SprintCooldown

#scene references
var stateMachine:AnimationNodeStateMachinePlayback

#resources
var meowSound = preload("res://Resources/meow.wav")

#class variables
var startingPosition:Vector2
var moveDirection:Vector2
var previousVelocity:Vector2
var beenDetected:bool = false #todo combine?
var resetting:bool = false
var sprinting:bool = false
var sprintCooldownStarted:bool = false

var _stamina: int
var stamina: int:
	get:
		return _stamina
	set(value):
		_stamina = min(value, maxStamina)

#HACK adding sprint has really shown a need for a state machine
var canSprint: bool:
	get:
		return stamina == maxStamina

func _ready():
	startingPosition = global_position
	stateMachine = animationTree["parameters/playback"]
	stateMachine.start("Idle")
	audioStreamPlayer.stream = meowSound
	stamina = maxStamina
	
func getInput():
	moveDirection = Input.get_vector("move_left", "move_right","move_up","move_down")
	if canSprint && Input.is_action_pressed("sprint"):
		sprinting = true
		sprintCooldownStarted = false
	if Input.is_action_just_released("sprint"):
		sprinting = false
		sprintCooldownStarted = true

func updateVelocity():
	previousVelocity = velocity
	var speedMultiplier = 1
	if sprinting:
		speedMultiplier = sprintMultiplier
		stamina -= 2
		if stamina <= 0:
			sprinting = false
	elif sprintCooldownStarted:
		stamina += 4 #todo probably should handle this elsewhere, but w/e
	print("stamina = " + str(stamina) + "sprinting = " + str(sprinting))
	velocity = moveDirection * (speed * speedMultiplier)
	move_and_slide()
	
func updateAnimation():
	if velocity.length() == 0:
		animationTree.set("parameters/Idle/blend_position", previousVelocity)
		stateMachine.travel("Idle")
		return
	
	if sprinting:
		animationTree.set("parameters/Run/blend_position", velocity)
		stateMachine.travel("Run")
	else:
		animationTree.set("parameters/Walk/blend_position", velocity)
		stateMachine.travel("Walk")

#function is setup to attempt to mimic how it would look if these core behaviours
#were handled by separate components
func _physics_process(delta):
	if beenDetected || resetting:
		return
	getInput()
	updateVelocity()
	updateAnimation()

func _process(delta):
	if !beenDetected && !resetting && Input.is_action_just_pressed("meow"):
		meowed()

func meowed():
	audioStreamPlayer.play()
	resetting = true
	collisionShape.disabled = true
	meow.emit()

func detected():
	print_debug("Detected!")
	beenDetected = true
	collisionShape.disabled = true
	sprinting = false
	sprintCooldownStarted = true
	playerDetected.emit()
	
func reset(restartPos: Vector2 = startingPosition):
	stateMachine.stop()
	animationPlayer.play("RESET")
	global_position = restartPos
	beenDetected = false
	#process the movement back to initial position before re-enabling collision
	#this will prevent a frame of overlap before the reset fully finishes
	await get_tree().process_frame
	collisionShape.disabled = false


func reset_complete():
	collisionShape.disabled = false
	resetting = false

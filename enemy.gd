extends CharacterBody2D

class_name Enemy

@export var flip: bool
@export var patrol: bool
@export var resetOnDetection: bool = false
@export var patrolDelay: float = 1.5
@export var speed: int = 25
@export var flipDuration: float = 3

@onready var animationPlayer = $AnimationPlayer
@onready var vision = $RayCast2D
@onready var timer = $Timer
@onready var patrolDestination = $PatrolDestination
@onready var distractionDestination = $DistractionDestination
@onready var audioStream = $AudioStreamPlayer2D
@onready var alertSprite = $AlertSprite
@onready var collisionShape = $CollisionShape2D

var alertSound = preload("res://Resources/Alert.wav")

var startingPosition: Vector2
var initialVisionPoint: Vector2
var patrolStartPosition: Vector2
var patrolEndPosition: Vector2
var distractionDest: Vector2
var moveCutoff = 0.5
var distracted = false
var globalVisionTargetPosition: Vector2
var finalVisionTargetPosition: Vector2
var visionMagnitude: int
var detected = false

func _ready():
	startingPosition = global_position
	initialVisionPoint = vision.target_position
	distractionDest = distractionDestination.global_position
	if patrol:
		patrolStartPosition = global_position
		patrolEndPosition = patrolDestination.global_position
	if flip:
		timer.wait_time = flipDuration
		timer.start()
	flip_animation()
	audioStream.stream = alertSound
	alertSprite.visible = false
	visionMagnitude = max(abs(vision.target_position.x), abs(vision.target_position.y))

func _process(delta):
	if flip && timer.time_left <= 0:
		vision.target_position.x *= -1
		vision.target_position.y *= -1
		flip_animation()
		timer.start()

func flip_animation():
	if vision.target_position.x > 0:
		animationPlayer.play("idle_right")
	elif vision.target_position.x < 0:
		animationPlayer.play("idle_left")
	elif vision.target_position.y < 0:
		animationPlayer.play("idle_up")
	else:
		animationPlayer.play("idle_down")

func change_direction():
	if patrolDelay > 0:
		timer.wait_time = patrolDelay
		timer.start()
		await timer.timeout
	var tempEnd = patrolEndPosition
	patrolEndPosition = patrolStartPosition
	patrolStartPosition = tempEnd
	
func update_velocity():
	#Idealy these would be separate states instead of an if statement,
	#but that is for a non-prototype
	if distracted:
		var moveDirection = (distractionDest - global_position)
		if moveDirection.length() < moveCutoff:
			global_position = distractionDest
			velocity = Vector2.ZERO
			globalVisionTargetPosition = to_global(finalVisionTargetPosition)
			flip_animation()
		else:
			velocity = moveDirection.normalized() * speed
		return
	if patrol:
		var moveDirection = (patrolEndPosition - global_position)
		if moveDirection.length() < moveCutoff && timer.time_left <= 0:
			change_direction()
		velocity = moveDirection.normalized() * speed

func update_vision():
	if distracted:
		vision.target_position = to_local(globalVisionTargetPosition)

func _physics_process(delta):
	if detected:
		return
	update_velocity()
	move_and_slide()
	var collision = get_last_slide_collision()
	if collision != null:
		var target:Player = collision.get_collider() as Player
		if target != null:
			print("collision detection")
			print("detected " + str(detected))
			player_detected(target)
	update_vision()
	if vision.is_colliding():
		var target:Player = vision.get_collider() as Player
		if target != null:
			print("vision detection")
			print("detected " + str(detected))
			player_detected(target)
	
func player_detected(target: Player):
	detected = true
	target.detected()
	audioStream.play()
	alertSprite.visible = true
	vision.enabled = false
	collisionShape.disabled = true

func distract(distractTarget:Vector2):
	if distracted == true:
		return
	distracted = true
	var direction: Vector2 = distractTarget - distractionDest
	direction = direction.normalized() * visionMagnitude
	finalVisionTargetPosition = direction
	globalVisionTargetPosition = distractionDest
	flip_animation()

func reset(fullReset:bool = false):
	timer.stop()
	collisionShape.disabled = false
	detected = false
	alertSprite.visible = false
	vision.enabled = true
	
	if fullReset:
		velocity = Vector2.ZERO
		distracted = false
		global_position = startingPosition
		vision.target_position = initialVisionPoint
		if flip:
			timer.wait_time = flipDuration
			timer.start()
			flip_animation()


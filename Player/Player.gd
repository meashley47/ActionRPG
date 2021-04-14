extends KinematicBody2D

const PlayerHurtSound = preload("res://PlayerHurtSound.tscn")

const MAX_SPEED = 130
const ACCELERATION = 120
const FRICTION = 900
const ROLL_SPEED = 125

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var directionFromMovement = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree["parameters/playback"]
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			if Input.is_action_just_pressed("attack"):
				state = ATTACK
			if Input.is_action_just_pressed("roll") && velocity != Vector2.ZERO:
				state = ROLL
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
			
func move_state(delta):
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# Up is negative, down is positive
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normalize so that diagonals aren't faster than moving along an axis
	inputVector = inputVector.normalized()
	
	#Accelerate
	if inputVector != Vector2.ZERO:
		# We save the inputVector here, so that it's based on which direction we were
		# most recently moving. Otherwise, animations would always face left by default
		directionFromMovement = inputVector
		swordHitbox.knockbackVector = directionFromMovement
		animationTree.set("parameters/Run/blend_position", directionFromMovement)
		animationState.travel("Run")
		velocity = velocity.move_toward(inputVector * MAX_SPEED, ACCELERATION * delta)
	#Decelerate
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationTree.set("parameters/Idle/blend_position", directionFromMovement)
		animationState.travel("Idle")

	move()

func attack_state():
	velocity = Vector2.ZERO
	animationTree.set("parameters/Attack/blend_position", directionFromMovement)
	animationState.travel("Attack")

func roll_state():
	animationTree.set("parameters/Roll/blend_position", directionFromMovement)
	animationState.travel("Roll")
	velocity = directionFromMovement * ROLL_SPEED
	move()

func move():
	velocity = move_and_slide(velocity)

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity *= 0.8
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(1.0)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

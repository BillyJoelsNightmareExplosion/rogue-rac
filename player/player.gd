extends CharacterBody3D

@onready var world = get_tree().root.get_children()[0]
@onready var head = $Head


const WALK_SPEED = 5.0
const RUN_SPEED = 10.0
const TURN_INTERP_FAC = 0.1
const JUMP_VELOCITY = 4.5

@export var LOOK_SENSITVITY = 0.1
@export var MAX_HEAD_TURN = 30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum MoveStates {
	WALK,
	SPRINT,
	COMBAT
}

var move_state = MoveStates.WALK
var speed = WALK_SPEED
var erosion_momentum = 0.9

var look_pos_last = Vector3(0,0,-1)

func _input(event):
	if event.is_action_pressed("attack"):
		move_state = MoveStates.COMBAT
		print("attack")
	elif event.is_action_pressed("sprint"):
		move_state = MoveStates.SPRINT

	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY  * 0.5))
#        head.rotation_degrees.y = clamp(head.rotation_degrees.y, -1 * MAX_HEAD_TURN, MAX_HEAD_TURN)
#        rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY))
#        # code for up/down look
#
#        head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_dir = Vector3(input_dir.x, 0, input_dir.y)

	# slows instantly, TODO fix
	speed = RUN_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED


	# var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction = (transform.basis * input_dir).normalized()
	var forward_vector = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	
	if direction:
		velocity.x = clamp(velocity.x * erosion_momentum + direction.x, -1 * speed, speed)
		velocity.z = clamp(velocity.z * erosion_momentum + direction.z, -1 * speed, speed)
	
		if move_state != MoveStates.COMBAT:
			var alignmentFactor = (forward_vector.dot(direction) - 1) / -2
			# (alignmentFactor * 0.3) + 0.1 the less aligned the new and old direction are,
			#  the faster we want to turn - long live Squirreling Away
			# print(direction)
			$debug_sphere.position = input_dir
			$body_collision.look_at($debug_sphere.global_position)
		else:
			$body_collision.look_at(global_position + Vector3.FORWARD)
		# $CollisionShape3D.look_at(forward_vector)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()




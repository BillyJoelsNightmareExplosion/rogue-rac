extends CharacterBody3D

@onready var world = get_tree().root.get_children()[0]
@onready var head = $Head

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var LOOK_SENSITVITY = 0.1
@export var MAX_HEAD_TURN = 30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
    #get mouse input for camera rotation
    if event is InputEventMouseMotion:
        head.rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY))
        head.rotation_degrees.y = clamp(head.rotation_degrees.y, -1 * MAX_HEAD_TURN, MAX_HEAD_TURN)
        rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY) * 0.5)
        # code for up/down look
        
        head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

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

    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED 
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    rotation_degrees.y = lerp(rotation_degrees.y, head.rotation_degrees.y, abs(direction.z))

    print("body: ", rotation_degrees.y," head: ", head.rotation_degrees.y," velo: ", velocity.z)


    move_and_slide()

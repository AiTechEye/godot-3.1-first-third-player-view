extends KinematicBody

var direction = Vector3()
var velocity = Vector3()

var gravity = -27
var jump_height = 10
var walk_speed = 10

var cam_mode = 1

var fpv_camera_angle = 0
var fpv_mouse_sensitivity = 0.3
var tpv_camera_speed = 0.001


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$player_mesh.visible = false
	OS.set_window_position(Vector2(0,0))


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		if cam_mode == 1:
# == First player view
			rotate_y(deg2rad(-event.relative.x * fpv_mouse_sensitivity))
			var change = -event.relative.y * fpv_mouse_sensitivity
			if change + fpv_camera_angle < 90 and change + fpv_camera_angle > -90:
				$head/Camera.rotate_x(deg2rad(change))
				fpv_camera_angle += change
		elif cam_mode == 2:
# == Third player view
			rotate_y(-event.relative.x * tpv_camera_speed)
			$head/tpv.rotate_x(-event.relative.y * tpv_camera_speed)

	
	
func _process(delta):
# == tps
	if Input.is_key_pressed(KEY_G) and cam_mode == 2:
			cam_mode = 1
			$head/Camera.current = true
			$head/tpv/Camera.current = false
			$player_mesh.visible = false
	if Input.is_key_pressed(KEY_F) and cam_mode == 1:
# == fps
			cam_mode = 2
			$head/Camera.current = false
			$head/tpv/Camera.current = true
			$player_mesh.visible = true
# == walking
	direction = Vector3()
	var aim = $head/Camera.get_global_transform().basis
	if Input.is_key_pressed(KEY_W):
		direction -= aim.z
	if Input.is_key_pressed(KEY_S):
		direction += aim.z
	if Input.is_key_pressed(KEY_A):
		direction -= aim.x
	if Input.is_key_pressed(KEY_D):
		direction += aim.x
	direction = direction.normalized()
	velocity.y += gravity * delta
	var tv = velocity
	tv = velocity.linear_interpolate(direction * walk_speed,6 * delta)
	velocity.x = tv.x
	velocity.z = tv.z
	velocity = move_and_slide(velocity,Vector3(0,1,0))
# == jumping
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		velocity.y = jump_height
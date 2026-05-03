extends Camera3D
class_name FollowCamera

## Smooth follow camera for top-down view
## Follows player with offset and smooth interpolation

@export_node_path("Node3D") var target_path: NodePath
@export var follow_speed: float = 3.0
@export var camera_offset: Vector3 = Vector3(0, 12, 12)
@export var look_ahead: float = 1.2
@export var min_pitch_deg: float = -65.0
@export var max_pitch_deg: float = -35.0
@export var deadzone_radius: float = 2.6

var target: Node3D
var target_position: Vector3

func _ready() -> void:
	if not target_path.is_empty():
		target = get_node_or_null(target_path) as Node3D
	if target == null:
		target = get_node_or_null("../Player") as Node3D
	if target:
		global_position = target.global_position + camera_offset
		look_at(target.global_position, Vector3.UP)

func _physics_process(delta: float) -> void:
	if not target:
		return

	# Keep player inside a center deadzone circle.
	# Camera moves only when player exits that radius.
	var offset_to_target: Vector3 = target.global_position - global_position
	offset_to_target.y = 0.0
	var distance: float = offset_to_target.length()
	if distance <= deadzone_radius:
		look_at(target.global_position, Vector3.UP)
		rotation_degrees.x = clamp(rotation_degrees.x, min_pitch_deg, max_pitch_deg)
		return

	# Calculate target position with look-ahead
	var player_velocity: Vector3 = Vector3.ZERO
	if target is CharacterBody3D:
		player_velocity = target.velocity

	var look_offset: Vector3 = player_velocity.normalized() * look_ahead
	look_offset.y = 0.0
	target_position = target.global_position + camera_offset + look_offset

	# Smooth follow
	var lerp_weight: float = clamp(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(target_position, lerp_weight)

	# Always look at player
	look_at(target.global_position, Vector3.UP)
	rotation_degrees.x = clamp(rotation_degrees.x, min_pitch_deg, max_pitch_deg)

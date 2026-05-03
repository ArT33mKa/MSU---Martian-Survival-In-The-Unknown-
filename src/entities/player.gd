extends CharacterBody3D

## Point-and-Click movement controller with NavMesh

@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var stopping_distance: float = 0.08

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visual: Node3D = $Visual

var target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false
var last_move_direction: Vector3 = Vector3.FORWARD
var fixed_y: float = 0.0
var body_bottom_offset: float = 0.0

func _ready() -> void:
	print("Player initialized at: ", global_position)
	fixed_y = global_position.y
	_calculate_body_bottom_offset()
	_update_ground_snap_height()
	global_position.y = fixed_y
	_align_visual_to_collider_bottom()

	# Configure NavigationAgent
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = stopping_distance
	nav_agent.max_speed = move_speed
	nav_agent.avoidance_enabled = false

	# Wait for navigation to be ready
	call_deferred("_setup_navigation")

func _setup_navigation() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	_snap_spawn_to_platform()
	nav_agent.target_position = global_position
	print("Navigation ready")

func _physics_process(delta: float) -> void:
	if not is_moving:
		_update_ground_snap_height()
		if abs(global_position.y - fixed_y) > 0.001:
			global_position.y = fixed_y
		velocity = Vector3.ZERO
		return

	# Stable top-down movement in XZ plane.
	var to_target: Vector3 = target_position - global_position
	to_target.y = 0.0
	var distance_to_target: float = to_target.length()
	if distance_to_target <= stopping_distance:
		global_position = Vector3(target_position.x, fixed_y, target_position.z)
		velocity = Vector3.ZERO
		is_moving = false
		return

	var direction: Vector3 = to_target.normalized()

	# Move
	velocity = direction * move_speed
	velocity.y = 0.0

	# Rotate towards movement direction
	if direction.length() > 0.1:
		last_move_direction = direction
		var target_angle: float = atan2(direction.x, direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_angle, rotation_speed * delta)
	else:
		var keep_angle: float = atan2(last_move_direction.x, last_move_direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, keep_angle, rotation_speed * delta)

	move_and_slide()

	# Keep player locked on top of ground/platform.
	_update_ground_snap_height()
	if abs(global_position.y - fixed_y) > 0.001:
		global_position.y = fixed_y

func move_to(target: Vector3) -> void:
	"""Move player to target position"""
	target_position = target
	nav_agent.target_position = target
	is_moving = true
	print("Moving to: ", target)

func _calculate_body_bottom_offset() -> void:
	var collision_shape: CollisionShape3D = $CollisionShape3D
	if collision_shape == null:
		body_bottom_offset = 0.0
		return
	var capsule: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	if capsule == null:
		body_bottom_offset = 0.0
		return
	# Capsule total half-height = height/2 + radius.
	body_bottom_offset = collision_shape.position.y - (capsule.height * 0.5 + capsule.radius)

func _update_ground_snap_height() -> void:
	var world_3d: World3D = get_world_3d()
	if world_3d == null:
		return
	var space_state: PhysicsDirectSpaceState3D = world_3d.direct_space_state
	if space_state == null:
		return

	var ray_from: Vector3 = global_position + Vector3(0.0, 5.0, 0.0)
	var ray_to: Vector3 = global_position + Vector3(0.0, -20.0, 0.0)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	query.collide_with_areas = false
	query.collision_mask = 1
	query.exclude = [self]

	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return
	var ground_y: float = (result.position as Vector3).y
	fixed_y = ground_y - body_bottom_offset

func _align_visual_to_collider_bottom() -> void:
	if visual == null:
		return

	var mesh_nodes: Array[Node] = visual.find_children("*", "MeshInstance3D", true, false)
	if mesh_nodes.is_empty():
		return

	var visual_min_y_world: float = INF
	for node in mesh_nodes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance == null:
			continue
		var local_aabb: AABB = mesh_instance.get_aabb()
		var bottom_world: Vector3 = mesh_instance.to_global(local_aabb.position)
		var top_world: Vector3 = mesh_instance.to_global(local_aabb.position + Vector3(0.0, local_aabb.size.y, 0.0))
		visual_min_y_world = min(visual_min_y_world, min(bottom_world.y, top_world.y))

	if visual_min_y_world == INF:
		return

	# Collider bottom is where character should visually touch the ground.
	var collider_bottom_world_y: float = global_position.y + body_bottom_offset
	var correction: float = collider_bottom_world_y - visual_min_y_world
	if abs(correction) > 0.001:
		visual.global_position.y += correction

func _snap_spawn_to_platform() -> void:
	# Retry a few physics frames in case world/collision is not ready on first frame.
	for _i in 6:
		_update_ground_snap_height()
		if abs(global_position.y - fixed_y) > 0.001:
			global_position.y = fixed_y
		await get_tree().physics_frame

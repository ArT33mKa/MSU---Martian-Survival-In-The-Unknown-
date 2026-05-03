extends Control

## Main scene controller for MSU

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var viewport_container: SubViewportContainer = $SubViewportContainer
@onready var player: Node = $SubViewportContainer/SubViewport/Player
var click_indicator_scene: PackedScene = preload("res://src/entities/click_indicator.tscn")

func _ready() -> void:
	# Wait for viewport to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	print("=== MSU: Martian Survival In The Unknown ===")
	print("PS1 Retro Renderer: ACTIVE")
	print("SubViewport Resolution: ", viewport.size)
	print("SubViewport own_world_3d: ", viewport.own_world_3d)
	print("SubViewport world in _ready: ", viewport.get_world_3d() != null)

	# Use linear filtering for smoother, non-pixelated image.
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click(event.position)

func _handle_click(screen_mouse_pos: Vector2) -> void:
	# Ignore clicks outside the render container
	if not viewport_container.get_global_rect().has_point(screen_mouse_pos):
		return

	# Convert mouse position from container-space to SubViewport-space
	var local_mouse_pos: Vector2 = viewport_container.get_local_mouse_position()
	var container_size: Vector2 = viewport_container.size
	if container_size.x <= 0.0 or container_size.y <= 0.0:
		return
	var viewport_scale: Vector2 = Vector2(viewport.size) / container_size
	var mouse_pos: Vector2 = local_mouse_pos * viewport_scale

	# Get camera from SubViewport
	var cam: Camera3D = viewport.get_camera_3d()
	if not cam:
		print("Camera not found")
		return

	# Use camera world to ensure we raycast inside correct 3D world
	var world_3d: World3D = cam.get_world_3d()
	if not world_3d:
		print("World3D not ready (camera world is null)")
		return

	# Raycast from camera to find ground position
	var from: Vector3 = cam.project_ray_origin(mouse_pos)
	var direction: Vector3 = cam.project_ray_normal(mouse_pos)
	var to: Vector3 = from + direction * 1000.0

	# Get physics space from SubViewport's world
	var space_state: PhysicsDirectSpaceState3D = world_3d.direct_space_state
	if not space_state:
		print("Physics space not ready")
		return

	# Create raycast query
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Only hit ground (layer 1)

	# Perform raycast
	var result: Dictionary = space_state.intersect_ray(query)

	if result.is_empty():
		print("No ground clicked")
		return

	# Move player to clicked position
	var hit_pos: Vector3 = result.position
	_spawn_click_indicator(hit_pos)
	if player.has_method("move_to"):
		player.call("move_to", hit_pos)
	else:
		print("Player is missing move_to()")
	print("Clicked at: ", hit_pos)

func _spawn_click_indicator(click_world_pos: Vector3) -> void:
	if click_indicator_scene == null:
		return
	var indicator: Node3D = click_indicator_scene.instantiate() as Node3D
	if indicator == null:
		return
	viewport.add_child(indicator)
	indicator.global_position = click_world_pos + Vector3(0.0, 0.03, 0.0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

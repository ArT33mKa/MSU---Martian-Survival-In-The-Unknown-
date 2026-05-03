extends Node3D
class_name ClickIndicator

## Visual indicator for click position
## Shows where player clicked with fade-out animation

@export var lifetime: float = 1.0
@export var fade_speed: float = 2.0
@export var pulse_speed: float = 8.0
@export var max_scale: float = 1.5

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var time_alive: float = 0.0
var initial_scale: Vector3

func _ready() -> void:
	initial_scale = scale

	# Start fade-out timer
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	timer.start()

func _process(delta: float) -> void:
	time_alive += delta

	# Pulse animation
	var pulse: float = 1.0 + sin(time_alive * pulse_speed) * 0.2
	scale = initial_scale * pulse

	# Fade out
	var alpha: float = 1.0 - (time_alive / lifetime)
	alpha = clamp(alpha, 0.0, 1.0)

	if mesh_instance and mesh_instance.material_override:
		mesh_instance.material_override.albedo_color.a = alpha

func _on_lifetime_expired() -> void:
	queue_free()

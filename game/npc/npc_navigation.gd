extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var healthbar_3d: Healthbar3D = $Healthbar3D

@export var speed: float = 5.0
@export var health: float = 20:
	set(new_value):
		health = new_value
		if(healthbar_3d): healthbar_3d.health = health

var heal_timer: Timer

func _ready():
	healthbar_3d.init_health(health)
	heal_timer = Timer.new()
	add_child(heal_timer)
	heal_timer.timeout.connect(heal)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-10, 10)
		random_position.z = randf_range(-10, 10)
		navigation_agent_3d.target_position = random_position

func _physics_process(_delta: float) -> void:
	if(navigation_agent_3d.is_navigation_finished()): return
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	velocity = direction * speed
	move_and_slide()


func _on_hurtbox_hurt_by(hitbox: HitBox) -> void:
	health -= hitbox.damage
	healthbar_3d.health = health
	heal_timer.start(5)

func heal():
	health = 20

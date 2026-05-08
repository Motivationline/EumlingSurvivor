@tool
extends Decal

@export var target: Node3D
#@export_range(0.0, 1.0, 0.01) var charge: float:
	#get:
		#return texture_rect.get_instance_shader_parameter("charge")
	#set(value):
		#print_debug("set charge")
		#set_instance_shader_parameter("charge", value)


@onready var sub_viewport: SubViewport = $SubViewport
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $SubViewport/TextureRect

var viewport_dirty: bool = true; # TODO: add a dirty mechanism to only update the decal texture when necessary
var decal_texture: ImageTexture

func _ready() -> void:
	decal_texture = ImageTexture.create_from_image(sub_viewport.get_texture().get_image());
	texture_albedo = decal_texture
	
func _process(delta: float) -> void:
	if target:
		var target_direction = global_position.direction_to(target.global_position)
		var target_angle = atan2(target_direction.x, target_direction.z) - PI
		var weight = 1 - exp(-5.0 * delta)
		global_rotation.y = lerp_angle(global_rotation.y, target_angle, weight)
	
	if decal_texture and viewport_dirty: 
		decal_texture.set_image(sub_viewport.get_texture().get_image()) 
		#sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE;
		#viewport_dirty = false;
	
	if texture_rect:
		texture_rect.set_instance_shader_parameter("decal_size", Vector2(size.x, size.z))
		
#func set_instance_shader_parameter(name: StringName, value: Variant):
	#if texture_rect:
		#texture_rect.set_instance_shader_parameter(name, value)
		#viewport_dirty = true;

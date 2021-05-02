extends Node2D

# Global variables:

# these are where obstacle texture resources are loaded to and from
const obstacle_texture_path := "res://generation/grays_obstacle_texture.png"
const obstacle_texture_data_path := "res://generation/grays_obstacle_texture_data.json"

# holds current obstacle texture user
var current_obstacle_texture_user = null

# saves off obstacle texture things
var obstacle_texture_image
var obstacle_texture_data

func _ready():
	# Generate obstacle texture
	$GenerateObstacleTexture.generate_obstacle_texture(
		[$GrayBlocks],
		obstacle_texture_path,
		obstacle_texture_data_path
	)
	# Initialize obstacle texture users
	obstacle_texture_image = load(obstacle_texture_path)
	obstacle_texture_data = $GenerateObstacleTexture.unpack_texture_info(obstacle_texture_data_path)
	$ObstacleTexturePlayer.init(obstacle_texture_image, obstacle_texture_data, 8000.0, 1000.0, -PI / 2.0)
	$ObstacleTextureBurst.init(obstacle_texture_image, obstacle_texture_data, 1000.0, 712)
	$ObstacleTextureBlood.init(obstacle_texture_image, obstacle_texture_data, 1000.0)
	$ObstacleTextureBlood.set_emitting(false)
	current_obstacle_texture_user = $ObstacleTexturePlayer
	# Initialize UI
	$UI/OptionButton.connect("item_selected", self, "on_item_selected")
	
func _physics_process(delta):
	# Move current obstacle texture user to mouse position
	if null != current_obstacle_texture_user:
		current_obstacle_texture_user.set_global_position(get_global_mouse_position())
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# On mouse click restart current obstacle texture user
			if null != current_obstacle_texture_user:
				current_obstacle_texture_user.restart()
			
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			# Quit when escape key pressed
			get_tree().quit()
			
func on_item_selected(item_idx:int):
	var current_text = $UI/OptionButton.get_item_text(item_idx)
	$ObstacleTextureBlood.set_emitting(false)
	match current_text:
		"Player":
			current_obstacle_texture_user = $ObstacleTexturePlayer
		"Burst":
			current_obstacle_texture_user = $ObstacleTextureBurst
		"Blood":
			current_obstacle_texture_user = $ObstacleTextureBlood

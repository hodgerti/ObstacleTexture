extends Node2D

###############################################################################
# API
###############################################################################

# Create obstacle texture for given list of tilemaps
func generate_obstacle_texture(tilemaps:Array, texture_path:String, data_path:String, global_cell_size:int=32, parent_pos:Vector2=Vector2(0, 0)):
	obstacles_max_extents = null
	obstacles_min_extents = null
	# find all of the obstacle tiles
	var obstacles = _generate_obstacles(tilemaps, parent_pos, global_cell_size)
	# generate texture out of obstacles
	_generate_texture(obstacles, texture_path, data_path, global_cell_size)
	
# This function packs meta data about an obstacle texture into a json file
func pack_texture_info(path:String, width:int, height:int, block_sz:int, origin:Vector2):
	var f_out = File.new()
	f_out.open(path, File.WRITE)
	var data = {
		'w':var2str(width), 
		'h':var2str(height), 
		'b':var2str(block_sz), 
		'o':var2str(origin)
		}
	f_out.store_line(to_json(data))
	f_out.close()

# This function unpacks meta data about an obstacle texture into a json file
func unpack_texture_info(path:String):
	var f_in = File.new()
	f_in.open(path, File.READ)
	var raw_data = parse_json(f_in.get_line())
	var data = {'w':int(), 'h':int(), 'b':int(), 'o':Vector2()}
	data['w'] = int(raw_data['w'])
	data['h'] = int(raw_data['h'])
	data['b'] = int(raw_data['b'])
	data['o'] = str2var(raw_data['o'])
	f_in.close()
	return data

###############################################################################
# Global Variables
###############################################################################

# These are used to track the size of the texture,
# and are generated while generating obstacles
var obstacles_max_extents = null
var obstacles_min_extents = null

###############################################################################
# Helper Functions
###############################################################################

# Accumulate all collision tilemaps into obstacles array
func _generate_obstacles(tilemaps:Array, parent_pos:Vector2, global_cell_size:int) -> Array:
	var obstacles = []
	var global_cell_size_v2 = Vector2(global_cell_size, global_cell_size)
	var map_offset = parent_pos / global_cell_size_v2
	for tilemap in tilemaps:
		# if tilemap and environment
		if tilemap is TileMap:
			var cell_size = tilemap.get_cell_size()
			var cell_size_comp = (cell_size / global_cell_size_v2).round()
			var tilemap_offset = tilemap.get_position() / global_cell_size_v2
			for cell in tilemap.get_used_cells():
				# Do not add the cell if does not have a collider
				if 0 != tilemap.get_tileset().tile_get_shape_count(tilemap.get_cell(cell.x, cell.y)):
					var world_cell_position = (cell * cell_size) + tilemap_offset + map_offset
					var local_cell_position = (world_cell_position / global_cell_size_v2).round()
					for ydx in range(0, cell_size_comp.y):
						for xdx in range(0, cell_size_comp.x):
							var new_obst_pos = local_cell_position + Vector2(ydx, xdx)
							
							# update obstacles extents
							# min regions
							if obstacles_min_extents == null:
								obstacles_min_extents = new_obst_pos
							obstacles_min_extents.x = min(obstacles_min_extents.x, new_obst_pos.x)
							obstacles_min_extents.y = min(obstacles_min_extents.y, new_obst_pos.y)
							# max regions
							if obstacles_max_extents == null:
								obstacles_max_extents = new_obst_pos
							obstacles_max_extents.x = max(obstacles_max_extents.x, new_obst_pos.x)
							obstacles_max_extents.y = max(obstacles_max_extents.y, new_obst_pos.y)
				
							obstacles.append(new_obst_pos)

	obstacles.sort_custom(self, "compare_vector2")
	return obstacles

# Pack obstacles into an image
func _generate_texture(obstacles:Array, image_path:String, data_path:String, global_cell_size:int):
	# make blank texture array
	var bitfield_sz = int(8)
	var tex_arr:PoolByteArray
	var width = 1 + int(obstacles_max_extents.x - obstacles_min_extents.x)
	var height = 1 + int(obstacles_max_extents.y - obstacles_min_extents.y)
	var tex_arr_sz = width * height
	tex_arr.resize(tex_arr_sz)
	for idx in range(tex_arr_sz):
		tex_arr.set(idx, 0)
	# process each obstacle into texture array
	for obst in obstacles:
		var adj_obst = obst - obstacles_min_extents
		var obst_idx = int(adj_obst.x + adj_obst.y * width)
		tex_arr[obst_idx] = 0xff
	# shove texture array into texture
	var tex_img = Image.new()
	tex_img.create_from_data(width, height, false, Image.FORMAT_L8, tex_arr)
	# export texture array
	tex_img.save_png(image_path)
	# export data
	pack_texture_info(data_path, width, height, global_cell_size, obstacles_min_extents)

# This helper function sorts two Vector2's as if they existed on a OGL texture
func _compare_vector2(v_a, v_b):
	if v_a.x < v_b.x:
		return true
	elif v_a.x == v_b.x:
		if v_a.y < v_b.y:
			return true
		else:
			return false
	else:
		return false
	


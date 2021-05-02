extends Particles2D

# This function initializes the particle shader
func init(obstacle_texture:Texture, obstacle_texture_data:Dictionary, gravity:float):
	# obstacle texture stuff
	process_material.set_shader_param("tex_origin", obstacle_texture_data['o'])
	process_material.set_shader_param("block_sz", obstacle_texture_data['b'])
	process_material.set_shader_param("obstacle_tex", obstacle_texture)
	# physics
	process_material.set_shader_param("gravity", gravity)
	# animation stuff
	process_material.set_shader_param("amount", int(amount))

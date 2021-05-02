extends Particles2D

# This function initializes the particle shader
func init(obstacle_texture:Texture, obstacle_data:Dictionary, gravity:float, speed:float, angle:float):
	# the basics
	process_material.set_shader_param("gravity", float(gravity))
	process_material.set_shader_param("initial_angle", float(angle))
	process_material.set_shader_param("speed", float(speed))
	# obstacle texture stuff
	process_material.set_shader_param("tex_origin", obstacle_data['o'])
	process_material.set_shader_param("block_sz", obstacle_data['b'])
	process_material.set_shader_param("obstacle_tex", obstacle_texture)

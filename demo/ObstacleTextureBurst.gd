extends Particles2D

# This function initializes the particle shader
func init(obstacle_texture:Texture, obstacle_data:Dictionary, speed:float, particle_count:int):
	# set number of particles that will burst
	amount = particle_count
	# the basics of bursting
	process_material.set_shader_param("amount", particle_count)
	process_material.set_shader_param("speed", speed)
	# obstacle texture stuff
	process_material.set_shader_param("tex_origin", obstacle_data['o'])
	process_material.set_shader_param("block_sz", obstacle_data['b'])
	process_material.set_shader_param("obstacle_tex", obstacle_texture)

shader_type particles;

// particle firing stuff
uniform float gravity = 4000.0f;

// sprite stuff
uniform int amount = 1;
uniform int sprite_count;
uniform int sprite_count_split;

// obstacle texture stuff
uniform sampler2D obstacle_tex : hint_black;
uniform int block_sz;
uniform vec2 tex_origin;


float rand_from_seed(in uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex()
{
	// reset
	if (RESTART) 
	{
		// zero start time
		CUSTOM.y = 0.0f;
		
		// translate because of non-local coords
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;

		// initialize velocty
		VELOCITY.xy = vec2(0.0);
	} 
	else 
	{
		// increment time
		CUSTOM.y += DELTA;
	
		// Apply gravity:
		VELOCITY.y += gravity * DELTA;
		
		// Check if inside square this frame
		// get pos
		ivec2 world_pos;
		world_pos.x = int(TRANSFORM[3].x);
		world_pos.y = int(TRANSFORM[3].y);
		
		// get byte
		ivec2 obst_pos_st = (world_pos / block_sz) - ivec2(int(tex_origin.x), int(tex_origin.y));
		vec4 texel = texelFetch(obstacle_tex, obst_pos_st, 0);
		bool non_obstacle = floatBitsToUint(texel.r) != uint(0x00);
		
		// check result
		if (true == non_obstacle) 
		{
			// When we collide, stop moving and then work on playing blood animation:
			VELOCITY.xy = vec2(0.0f);
			CUSTOM.z = 3.0f;
		}
		else
		{
			CUSTOM.z = 0.0f;
		}
	
		// get frame number
		float time = CUSTOM.y;  // CUSTOM.y is time
		float frame_time = LIFETIME / float(sprite_count / sprite_count_split);
		float frame_idx = time / frame_time;
		CUSTOM.z += floor(frame_idx);  // CUSTOM.z is frame number
	}
}
shader_type particles;

// particle firing stuff
const float spread = 2.0 * 3.14;  // Spread is whole circle
uniform int amount;
uniform float speed;

// obstacle texture stuff
uniform sampler2D obstacle_tex : hint_black;
uniform int block_sz;
uniform vec2 tex_origin;

vec2 ang2vec(float a) {
	return vec2(cos(a), sin(a));
}

mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
	mat4 resm;
	resm[0] = vec4(oc * axis.x * axis.x + c, oc * axis.x * axis.y + axis.z * s, oc * axis.z * axis.x - axis.y * s, 0.0);
	resm[1] = vec4(oc * axis.x * axis.y - axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z + axis.x * s, 0.0);
	resm[2] = vec4(oc * axis.z * axis.x + axis.y * s, oc * axis.y * axis.z - axis.x * s, oc * axis.z * axis.z + c, 0.0);
	resm[3] = vec4(0.0, 0.0, 0.0, 1.0);
	
	return resm;
}

void vertex()
{
	// This would store the data that will be passed to the fragment shader indicating collision or nah
	COLOR.a = 1.0;
	
	// reset
	if (RESTART) {
		// calculate trajectory based on a full circle
		float increment = spread / float(amount);
		float idx_angle = ((float(INDEX) - float(amount)/2.0) * increment);
		vec2 firing_direction = ang2vec(idx_angle);
		// translate because of non-local coords
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
		// rotate based on this particles trajectory from center of emission
		TRANSFORM *= rotationMatrix(vec3(0.0, 0.0, 1.0), idx_angle);
		// apply velocty
		VELOCITY.xy = firing_direction * speed;
	} else {
		// check if inside square next frame
		// get pos
		ivec2 world_pos;
		world_pos.x = int(TRANSFORM[3].x) + int(VELOCITY.x * DELTA);
		world_pos.y = int(TRANSFORM[3].y) + int(VELOCITY.y * DELTA);
		
		// get byte for this world coordinate from obstacle texture
		ivec2 obst_pos_st = (world_pos / block_sz) - ivec2(int(tex_origin.x), int(tex_origin.y));
		vec4 texel = texelFetch(obstacle_tex, obst_pos_st, 0);
		bool non_obstacle = floatBitsToUint(texel.r) != uint(0x00);
		// check if byte is an obstacle
		if (non_obstacle) {
			// stop emission if inside square next frame (this looks better than stopping when we are in the obstacle since textures usually overlap obstacles)
			ACTIVE = false;
		}
	}
}

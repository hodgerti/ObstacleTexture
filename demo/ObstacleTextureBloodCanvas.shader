shader_type canvas_item;

varying float sprite_idx;

uniform int sprite_width;
uniform int sprite_height;
	

void vertex()
{
	// pass thru index to fragment shader
	sprite_idx = INSTANCE_CUSTOM.z;
	
	// scale down size
	vec2 sprite_size = vec2(float(sprite_width), float(sprite_height));
	vec2 sprite_sheet_size = 1.0f / TEXTURE_PIXEL_SIZE;
	vec2 dxdy_sprite_size = sprite_size / sprite_sheet_size;
	VERTEX.xy *= dxdy_sprite_size;
}

void fragment()
{
	vec2 sprite_size = vec2(float(sprite_width), float(sprite_height));
	ivec2 i_sprite_sheet_size = textureSize(TEXTURE, 0);
	vec2 sprite_sheet_size = vec2(float(i_sprite_sheet_size.x), float(i_sprite_sheet_size.y));
    // Normalize sprite size (0.0-1.0)
	vec2 dxdy_sprite_size = sprite_size / sprite_sheet_size;
    // Figure out number of tile cols of sprite sheet
    float sprite_sheet_cols = sprite_sheet_size.x / sprite_size.x;
    // From linear index to row/col pair
    float sprite_sheet_col = mod(sprite_idx, sprite_sheet_cols);
    float sprite_sheet_row = floor(sprite_idx / sprite_sheet_cols);
    // Finally to UV texture coordinates
    vec2 uv_sprite = vec2(dxdy_sprite_size.x * UV.x + sprite_sheet_col * dxdy_sprite_size.x, 
	                      1.0 - dxdy_sprite_size.y - sprite_sheet_row * dxdy_sprite_size.y + dxdy_sprite_size.y * UV.y);
    COLOR = texture(TEXTURE, uv_sprite);

}
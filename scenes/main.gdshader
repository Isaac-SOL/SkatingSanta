shader_type canvas_item;

uniform sampler2D mask_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//vec2 mask_uv = UV;
	//vec4 mask = texture(mask_texture, mask_uv);
	vec4 object_color2 = texture(mask_texture, UV);
	vec4 object_color = texture(TEXTURE, UV);
    COLOR = vec4(object_color2.rgb+object_color.rgb, .5);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

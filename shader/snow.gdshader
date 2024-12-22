shader_type canvas_item;

uniform float layers: hint_range(10.0, 200.0, 0.1) = 50.0;
uniform float depth: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float density: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float speed: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float wind: hint_range(-2.0, 2.0, 0.01) = 0.0;

void fragment() {
	vec2 uv = -UV;
	vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
	uv.x *= resolution.x / resolution.y;
	float time = TIME * speed;
	vec3 color = vec3(0.0);
	//for (float 1 = 0.0; i * depth);
}


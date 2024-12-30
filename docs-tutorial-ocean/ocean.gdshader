shader_type spatial;
render_mode specular_toon;

uniform sampler2D surface_noise;
uniform sampler2D surface_noise_normal;
uniform float height_scalar = 0.1;

varying vec2 tex_position;
varying vec2 wave_direction;
varying vec2 wave_normal;

void vertex() {
	
	tex_position = (VERTEX.xz - TIME * 0.05) / 3.0;
	wave_direction = vec2(sin(TIME + VERTEX.x * 4.0), cos(TIME + VERTEX.z * 3.0));
	wave_normal = vec2(1.0 - abs(sin(TIME + VERTEX.x * 4.0)), -sin(TIME + VERTEX.z * 3.0));
	VERTEX.y += (wave_direction.x + wave_direction.y) * height_scalar;
	VERTEX.y += texture(surface_noise, tex_position).x * height_scalar;
}

void fragment() {
	
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	METALLIC = 0.01;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	RIM = 0.2;
	ALBEDO = vec3(0.01,0.03,0.05) + 0.1 * fresnel;
	NORMAL_MAP = texture(surface_noise_normal, tex_position).rgb;
	NORMAL_MAP.xy += wave_normal * height_scalar;
	NORMAL_MAP = normalize(NORMAL_MAP);
	//ALBEDO = NORMAL_MAP;
}
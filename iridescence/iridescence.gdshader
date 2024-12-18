shader_type spatial;
render_mode specular_toon;

uniform sampler2D noise_texture;
uniform vec3 base_colour : source_color;
uniform float iridescent;

// https://github.com/paddy-exe/ShaderFunction-Extras
vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
	return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}

vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	METALLIC = 0.85;
	ROUGHNESS = 0.01;
	RIM = 0.2;
	NORMAL_MAP = texture(noise_texture, UV).rgb;
	ALBEDO = base_colour;
	
	vec3 col_hsv = rgb_to_hsv(base_colour);
	float edgeness = NORMAL.x;
	float dot_prod = (pow((1.0 - dot(NORMAL, VIEW)) * 0.5 + 0.5, 5.0) * edgeness);
	//dot_prod = dot(NORMAL, VIEW);
	//dot_prod = edgeness;
	col_hsv.x += dot_prod * iridescent / 360.0;
	ALBEDO = hsv_to_rgb(col_hsv);
	//ALBEDO = vec3(dot_prod, dot_prod, dot_prod) / 2.0 + 0.5;
	//if (abs(dot_prod) < 0.001) {
		//ALBEDO = vec3(1.0, 0, 0);
	//}
	//ALBEDO = NORMAL_MAP;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

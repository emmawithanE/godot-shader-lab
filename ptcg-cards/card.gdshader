shader_type spatial;

const float max_normal = 0.342;

const vec2 card_dimensions = vec2(0.25,0.35);

uniform sampler2D layers[3] : source_color;
uniform vec2 offset[3];
uniform vec2 scale[3];
uniform float depth[3];

varying vec2 mesh_vert;

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
	mesh_vert = VERTEX.xy * vec2(1,-1);
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 scaled_norm = NORMAL.xy / max_normal / 2.0;
	vec2 shifted_norm = scaled_norm + 0.5;
	ALBEDO = vec3(shifted_norm,0);
	
	vec3 colour = vec3(0);
	
	colour = texture(
			layers[0],
			(
				(mesh_vert + offset[0])
				* scale[0]
				+ (shifted_norm * depth[0] / 10.0 * vec2(1,-1))
			)
		).rgb;
	
	// We replace this entirely if we are on the edge!
	if ((card_dimensions.x - abs(mesh_vert.x * 2.0) <= 0.02 
	|| card_dimensions.y - abs(mesh_vert.y * 2.0) <= 0.02)) {
		colour = vec3(0.5);
		float contours = mesh_vert.y;
		contours += mesh_vert.x * 1.5;
		contours *= 500.0;
		
		float sin_distortion = mesh_vert.x;
		sin_distortion -= mesh_vert.y * 1.5;
		contours += sin(sin_distortion * 300.0) * 2.5;
		
		float colourness = pow(sin(contours), 2.0);
		colour = vec3(colourness);
		
		
		
		
		
		float hue = 0.0;
		float sat = 1.0;
		float val = 0.2;
		
		float hue_contours = contours; 
		hue_contours /= 6.0;
		hue_contours += length(
			shifted_norm
			*vec2(6.0,3.0)
			);
		hue = sin(hue_contours) * 0.5 + 0.5;
		
		float sat_contours = contours;
		
		sat_contours = sin(sat_contours);
		sat_contours = pow(sat_contours, 3.0);
		sat_contours += 0.5;
		sat_contours = clamp(sat_contours, 0.0, 1.0);
		sat = sat_contours;
		sat *= 0.8;
		//colour = vec3(sat);
		
		val += sat * 0.4;
		
		colour = hsv_to_rgb(vec3(hue,sat,val));
	}
	
	
	for (int i = 1; i < layers.length(); i++) {
		
		vec4 layer_col = texture(
			layers[i],
			(
				(mesh_vert + offset[i])
				* scale[i]
				+ (shifted_norm * depth[i] / 10.0 * vec2(1,-1))
			)
		);
		
		colour = mix(colour, layer_col.rgb, layer_col.a);
	}
	
	ROUGHNESS = 1.0 - texture(
		layers[2],
		(
			(mesh_vert + offset[2])
			* scale[2]
			+ (shifted_norm * depth[2] / 10.0 * vec2(1,-1))
		)
	).a;
	
	//ALBEDO = vec3(ROUGHNESS);
	
	METALLIC = 0.2 + (1.0 - ROUGHNESS) * 0.4;
	
	ALBEDO = colour;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

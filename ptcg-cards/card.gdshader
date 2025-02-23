shader_type spatial;

const float max_normal = 0.342;

uniform sampler2D layers[1];
uniform vec2 offset[1];
uniform vec2 scale[1];
uniform float depth[1];

varying vec2 mesh_vert;

void vertex() {
	mesh_vert = VERTEX.xy;
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 scaled_norm = normalize(NORMAL.xy) / max_normal / 2.0;
	vec2 shifted_norm = scaled_norm + 0.5;
	ALBEDO = vec3(shifted_norm,0);
	
	vec3 colour = vec3(0);
	
	for (int i = 0; i < layers.length(); i++) {
		
		vec4 layer_col = texture(
			layers[i],
			(
				(mesh_vert + offset[i])
				* scale[i]
				+ shifted_norm * depth[i] / 10.0
			)
		);
		
		colour = mix(colour, layer_col.rgb, layer_col.a);
	}
	
	ALBEDO = colour;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

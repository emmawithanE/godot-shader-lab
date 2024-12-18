shader_type spatial;

uniform sampler2D card_texture;
uniform int card : hint_range(0, 12, 1);
uniform int suit : hint_range(0, 3, 1);

varying vec2 vertex_val;
uniform vec2 ext_dimensions;

void vertex() {
	vertex_val = VERTEX.xy * vec2(1,-1); // not really sure why this needs to be flipped in y but w/e
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 card_relative_point = vec2((vertex_val.x / ext_dimensions.x + float(card) + 0.5) / 13.0, (vertex_val.y / (ext_dimensions.y) + float(suit) + 0.5) / 4.0);
	ALBEDO = texture(card_texture, card_relative_point).rgb;
	
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

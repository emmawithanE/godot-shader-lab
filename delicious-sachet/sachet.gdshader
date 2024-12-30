shader_type spatial;
varying vec2 vert;

uniform float radius;
uniform sampler2D colour_edge_ramp;
uniform sampler2D noise;
//uniform sampler2D threshold_texture;

uniform vec3 dark_colour : source_color;
uniform vec3 light_colour : source_color;
uniform sampler2D small_bubble_noise;
uniform sampler2D large_bubble_noise; 

uniform float low_mid_1 : hint_range(0.0, 1.0, 0.01);
uniform float low_mid_2 : hint_range(0.0, 1.0, 0.01);
uniform float mid_high_1 : hint_range(0.0, 1.0, 0.01);
uniform float mid_high_2 : hint_range(0.0, 1.0, 0.01);


void vertex() {
	vert = VERTEX.xz;
}

void fragment() {
	float dist = length(vert);
	
	if (dist > radius) {
		ALPHA = 0.0;
	}
	else {
		vec3 area_type_colour = mix(vec3(0.05), vec3(1.0), texture(noise, vert * vec2(0.25)).r);
		//area_type_colour = step(area_type_colour, vec3(0.6));
		area_type_colour *= texture(colour_edge_ramp, vec2(dist * 0.99 / radius, 0)).r;
		
		//area_type_colour = texture(threshold_texture, vec2(area_type_colour.r * 0.98 + 0.01, 0.0)).rgb;
		
		vec3 out_colour = area_type_colour;
		
		float low_scalar = (1.0 - smoothstep(low_mid_1, low_mid_2, area_type_colour.r));
		float high_scalar = smoothstep(mid_high_1, mid_high_2, area_type_colour.r);
		float mid_scalar = 1.0 - (low_scalar + high_scalar);
		
		vec3 high = dark_colour * high_scalar; 
		vec3 mid = mix(dark_colour, light_colour, texture(small_bubble_noise, vert).r) * mid_scalar;
		vec3 low = mix(dark_colour, light_colour, texture(large_bubble_noise, vert).r) * low_scalar;
		
		//high = vec3(high_scalar,0,0);
		//mid = vec3(0,mid_scalar,0);
		//low = vec3(0,0,low_scalar);
		
		out_colour = high + mid + low;
		ALBEDO = out_colour;
	}
	
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

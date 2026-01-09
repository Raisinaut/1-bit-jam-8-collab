shader_type canvas_item;

uniform vec3 flash_color : source_color = vec3(1, 1, 1);
uniform float flash_amount = 0.0;


void fragment() {
	// FLASH //
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 new_color = previous_color;
	vec4 flash_with_transparency = vec4(flash_color, previous_color.a);

	if (flash_amount > 0.0) {
		new_color = mix(previous_color, flash_with_transparency, flash_amount);
	}
	COLOR = new_color;
}
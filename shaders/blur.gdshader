shader_type canvas_item;

/// Desenfoque de caja (box blur) 5×5.
/// blur_strength = 0.0  → imagen nítida.
/// blur_strength = 6.0  → desenfoque fuerte (usado en el intro).
uniform float blur_strength : hint_range(0.0, 10.0) = 0.0;

void fragment() {
	if (blur_strength < 0.01) {
		COLOR = texture(TEXTURE, UV);
	} else {
		vec4  result       = vec4(0.0);
		float total_weight = 0.0;
		vec2  pixel        = TEXTURE_PIXEL_SIZE * blur_strength;

		for (int x = -2; x <= 2; x++) {
			for (int y = -2; y <= 2; y++) {
				result       += texture(TEXTURE, UV + vec2(float(x), float(y)) * pixel);
				total_weight += 1.0;
			}
		}

		COLOR = result / total_weight;
	}
}

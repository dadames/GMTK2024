shader_type canvas_item;

uniform float fadeSpeed: hint_range(0.1, 10, 0.1);

void fragment() {
	float fadeAmount = clamp(sin(TIME * fadeSpeed) + 0.5, 0.0, 1.0);
	COLOR.a *= fadeAmount;
}

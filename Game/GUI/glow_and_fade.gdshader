shader_type canvas_item;

uniform float fadeSpeed: hint_range(0.1, 10, 0.1);

void fragment() {
	float fadeAmount = sin(TIME * fadeSpeed) + 0.5;
	COLOR.a *= fadeAmount;
}

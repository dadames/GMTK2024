shader_type canvas_item;


uniform sampler2D noiseTexture;
uniform float fadeSpeed = 1;



void fragment() {
	float noiseMult = texture(noiseTexture, UV).r;


	COLOR.a = COLOR.a - (0.1 * noiseMult * (sin(TIME * fadeSpeed)));
}
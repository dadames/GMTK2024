shader_type canvas_item;


uniform float max_line_width = 10.0;
uniform float min_line_width = 5.0;
uniform float freq = 1.0;
uniform float block_size = 20.0;
uniform vec4 color: source_color = vec4(0,0,0,1);

const int ang_res = 16;

void vertex() {
	VERTEX += sign(VERTEX) * max_line_width; // replace sign(VERTEX) by (sign(VERTEX) * 2.0 - 1.0) if not Centered
}

float hash(vec2 p, float s) {
	return fract(35.1 * sin(dot(vec3(112.3, 459.2, 753.2), vec3(p, s))));
}

float noise(vec2 p, float s) {
	vec2 d = vec2(0, 1);
	vec2 b = floor(p);
	vec2 f = fract(p);
	return mix(
		mix(hash(b + d.xx, s), hash(b + d.yx, s), f.x),
		mix(hash(b + d.xy, s), hash(b + d.yy, s), f.x), f.y);
}

float get_line_width(vec2 p, float s) {
	p /= block_size;
	float w = 0.0;
	float intensity = 1.0;
	for (int i = 0; i < 3; i++) {
		w = mix(w, noise(p, s), intensity);
		p /= 2.0;
		intensity /= 2.0;
	}
	
	return mix(max_line_width, min_line_width, w);
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
	for (float i = -ceil(max_line_width); i <= ceil(max_line_width); i++) {
		float x = abs(i) > max_line_width ? max_line_width * sign(i) : i;
		float offset;
		
		offset = floor(sqrt(pow(max_line_width + 0.5, 2) - x * x));
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0)) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	float alpha = 0.0;
	float timeStep = floor(TIME * freq);
	vec2 scale = TEXTURE_PIXEL_SIZE;
	scale *= get_line_width(UV / TEXTURE_PIXEL_SIZE, timeStep);
	for (int i = 0; i < ang_res; i++) {
		float angle = 2.0 * PI * float(i) / float(ang_res);
		vec2 disp = scale * vec2(cos(angle), sin(angle));
		alpha += texture(TEXTURE, UV + disp).a;
	}
	
	
	vec2 uv = UV;
	vec2 image_top_left = floor(uv);
	vec2 image_bottom_right = image_top_left + vec2(1.0);
	vec2 texture_pixel_size = vec2(1.0) / (TEXTURE_PIXEL_SIZE + vec2(max_line_width * 2.0));
	uv = (uv - texture_pixel_size * max_line_width) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;
	if (uv != clamp(uv, image_top_left, image_bottom_right)) {
		COLOR.a = 0.0;
	} else {
		COLOR = texture(TEXTURE, uv);
	}
	
	//if ((alpha > 0.0) && (texture(TEXTURE, uv).a < 0.1)) {
		//COLOR = color;
	//}
	//else {
		//COLOR = texture(TEXTURE, UV);
	//}
	
	if (COLOR.a > 0.0 && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
		if (texture(TEXTURE, uv).a < 0.1){
			COLOR = color;
		}
		else {
			COLOR = texture(TEXTURE, UV);
		}
	}
}
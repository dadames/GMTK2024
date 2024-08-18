shader_type canvas_item;


uniform float max_line_width = 10.0;
uniform float min_line_width = 5.0;
uniform float freq = 1.0;
uniform float block_size = 20.0;
uniform vec4 outline_colour: source_color = vec4(0,0,0,1);
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
const int ang_res = 16;


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

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(max_line_width); i <= ceil(max_line_width); i++) {
		float x = abs(i) > max_line_width ? max_line_width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = max_line_width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(max_line_width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = max_line_width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
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
	vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(max_line_width * 2.0));
	uv = (uv - texture_pixel_size * max_line_width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
	
	COLOR = texture(TEXTURE, uv);
	
	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(UV, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR.rgb = inside ? mix(COLOR.rgb, outline_colour.rgb, outline_colour.a) : outline_colour.rgb;
		COLOR.a += (1.0 - COLOR.a) * outline_colour.a;
	}
	if ((alpha > 0.0) && (texture(TEXTURE, UV).a < 0.1)) {
		COLOR = outline_colour;
	}
}




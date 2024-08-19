shader_type canvas_item;

uniform sampler2D tex;
uniform float speed;
uniform float intensity;
uniform vec4 color : source_color;
uniform float thickness = 0.05;


float sample(in vec2 st){
	return texture(tex, st).a;
}

void fragment(){
	float t = TIME*speed;
	vec2 px = vec2(500.0) / vec2(textureSize(tex, 0)) * vec2(thickness);
	float neighbor = 
		sample(UV+px*vec2( 1.,  0.))+
		sample(UV+px*vec2( 0.,  1.))+
		sample(UV+px*vec2(-1.,  0.))+
		sample(UV+px*vec2( 0., -1.));
	float center = sample(UV)*4.;
	float edge = clamp(neighbor-center, 0., 1.0);
	if (UV.x < thickness || UV.y < thickness || UV.x > 1.0 - thickness || UV.y > 1.0 - thickness){
		if (COLOR.a > 0.0){
			edge = 1.0;
		}
	}
	float lit = dot(UV-vec2(.5), vec2(cos(t), sin(t)))-t;
	lit = mod(lit, 1.);
	lit = pow(lit, 12.);
	
	
	COLOR = vec4(color.rgb*vec3(intensity), edge*lit);
}
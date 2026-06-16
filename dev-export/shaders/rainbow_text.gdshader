shader_type canvas_item;

uniform float speed : hint_range(0.5, 4.0) = 1.5;
uniform float scale : hint_range(0.5, 4.0) = 2.0;

void fragment() {
    float t = TIME * speed;
    float x = UV.x * scale + t;
    vec3 col;
    float seg = mod(x, 6.0);
    if (seg < 1.0) col = mix(vec3(0.91, 0.27, 0.23), vec3(0.96, 0.65, 0.14), seg);
    else if (seg < 2.0) col = mix(vec3(0.96, 0.65, 0.14), vec3(1.0, 0.84, 0.0), seg - 1.0);
    else if (seg < 3.0) col = mix(vec3(1.0, 0.84, 0.0), vec3(0.43, 0.77, 0.19), seg - 2.0);
    else if (seg < 4.0) col = mix(vec3(0.43, 0.77, 0.19), vec3(0.29, 0.62, 0.85), seg - 3.0);
    else if (seg < 5.0) col = mix(vec3(0.29, 0.62, 0.85), vec3(0.48, 0.38, 1.0), seg - 4.0);
    else col = mix(vec3(0.48, 0.38, 1.0), vec3(0.91, 0.27, 0.23), seg - 5.0);
    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(col, tex.a * COLOR.a);
}

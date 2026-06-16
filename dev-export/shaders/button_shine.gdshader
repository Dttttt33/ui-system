shader_type canvas_item;

uniform vec4 color_base : source_color = vec4(0.431, 0.773, 0.192, 1.0);
uniform float shine_height : hint_range(0.0, 0.6) = 0.38;
uniform float shine_opacity : hint_range(0.0, 1.0) = 0.45;

void fragment() {
    vec2 uv = UV;

    // Top shine highlight
    float shine_factor = 1.0 - smoothstep(0.0, shine_height, uv.y);
    float shine_curve = smoothstep(0.1, 0.5, uv.x) * (1.0 - smoothstep(0.5, 0.9, uv.x));

    vec3 base = color_base.rgb;
    vec3 shiny = mix(base, vec3(1.0), shine_factor * shine_opacity * shine_curve);

    COLOR = vec4(shiny, color_base.a);
}

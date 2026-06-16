shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.96, 0.65, 0.14, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float pulse_speed : hint_range(0.5, 4.0) = 1.2;
uniform float edge_width : hint_range(0.0, 0.3) = 0.15;

void fragment() {
    vec2 uv = UV;
    float dist_left = uv.x;
    float dist_right = 1.0 - uv.x;
    float dist_top = uv.y;
    float dist_bottom = 1.0 - uv.y;
    float min_dist = min(min(dist_left, dist_right), min(dist_top, dist_bottom));
    float edge = smoothstep(edge_width, 0.0, min_dist);
    float pulse = (sin(TIME * pulse_speed * 6.2832) * 0.5 + 0.5);
    float alpha = edge * intensity * (0.3 + 0.7 * pulse);
    COLOR = vec4(glow_color.rgb, alpha);
}

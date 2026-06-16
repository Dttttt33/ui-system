shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.96, 0.65, 0.14, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.35;
uniform float pulse_speed : hint_range(0.5, 4.0) = 1.4;
uniform int direction : hint_range(0, 3) = 0;

void fragment() {
    float edge = 0.0;
    if (direction == 0) edge = 1.0 - UV.x;
    else if (direction == 1) edge = UV.x;
    else if (direction == 2) edge = 1.0 - UV.y;
    else edge = UV.y;
    edge = smoothstep(0.65, 0.0, edge);
    float pulse = sin(TIME * pulse_speed * 6.2832) * 0.5 + 0.5;
    float alpha = edge * intensity * (0.3 + 0.7 * pulse);
    COLOR = vec4(glow_color.rgb, alpha);
}

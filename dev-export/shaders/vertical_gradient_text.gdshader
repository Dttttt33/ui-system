shader_type canvas_item;

// Static top-to-bottom gradient (green → amber → red)
// Used for "GREAT JOB!" victory message in EndPanel
uniform vec4 color_top : source_color = vec4(0.43, 0.77, 0.19, 1.0);    // green #6EC531
uniform vec4 color_mid : source_color = vec4(0.96, 0.65, 0.14, 1.0);    // amber #F5A623
uniform vec4 color_bottom : source_color = vec4(0.91, 0.27, 0.23, 1.0); // red #E8453A
uniform float mid_point : hint_range(0.2, 0.8) = 0.6;

void fragment() {
    float y = UV.y;
    vec3 col;
    if (y < mid_point) {
        col = mix(color_top.rgb, color_mid.rgb, y / mid_point);
    } else {
        col = mix(color_mid.rgb, color_bottom.rgb, (y - mid_point) / (1.0 - mid_point));
    }
    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(col, tex.a * COLOR.a);
}

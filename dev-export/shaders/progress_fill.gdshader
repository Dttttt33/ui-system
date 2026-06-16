shader_type canvas_item;

uniform vec4 color_start : source_color = vec4(0.431, 0.773, 0.192, 1.0); // green
uniform vec4 color_end : source_color = vec4(0.722, 0.898, 0.294, 1.0); // yellow-green
uniform vec4 color_full_start : source_color = vec4(0.961, 0.722, 0.0, 1.0); // gold start
uniform vec4 color_full_end : source_color = vec4(1.0, 0.843, 0.0, 1.0); // gold end
uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform bool is_full = false;
uniform float shine_height : hint_range(0.0, 0.5) = 0.3;
uniform float shine_opacity : hint_range(0.0, 1.0) = 0.45;

void fragment() {
    vec2 uv = UV;

    // Only show fill up to progress
    if (uv.x > progress) {
        COLOR = vec4(0.0);
        return;
    }

    // Gradient color
    vec4 fill_start = is_full ? color_full_start : color_start;
    vec4 fill_end = is_full ? color_full_end : color_end;
    vec4 base = mix(fill_start, fill_end, uv.x / max(progress, 0.001));

    // Top shine strip
    float shine_factor = 1.0 - smoothstep(0.0, shine_height, uv.y);
    vec4 shine = vec4(1.0, 1.0, 1.0, shine_opacity * shine_factor);

    COLOR = vec4(mix(base.rgb, vec3(1.0), shine.a * shine_opacity), 1.0);
}

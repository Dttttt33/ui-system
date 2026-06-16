shader_type canvas_item;

// Three-stop gradient: green → yellow → orange (matches HTML)
uniform vec4 color_start : source_color = vec4(0.494, 0.859, 0.400, 1.0);  // #7edb66
uniform vec4 color_mid : source_color = vec4(1.0, 0.878, 0.392, 1.0);      // #ffe064
uniform vec4 color_end : source_color = vec4(1.0, 0.620, 0.216, 1.0);      // #ff9e37
uniform vec4 color_full_start : source_color = vec4(0.961, 0.722, 0.0, 1.0);
uniform vec4 color_full_end : source_color = vec4(1.0, 0.843, 0.0, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform bool is_full = false;
uniform float shine_height : hint_range(0.0, 0.5) = 0.3;
uniform float shine_opacity : hint_range(0.0, 1.0) = 0.45;

void fragment() {
    vec2 uv = UV;

    if (uv.x > progress) {
        COLOR = vec4(0.0);
        return;
    }

    float t = uv.x / max(progress, 0.001);
    vec4 base;

    if (is_full) {
        base = mix(color_full_start, color_full_end, t);
    } else {
        // Three-stop: start → mid at 50%, mid → end at 100%
        if (t < 0.5) {
            base = mix(color_start, color_mid, t * 2.0);
        } else {
            base = mix(color_mid, color_end, (t - 0.5) * 2.0);
        }
    }

    // Top shine strip
    float shine_factor = 1.0 - smoothstep(0.0, shine_height, uv.y);
    COLOR = vec4(mix(base.rgb, vec3(1.0), shine_factor * shine_opacity), 1.0);
}

shader_type canvas_item;

uniform vec4 color_main : source_color = vec4(0.431, 0.773, 0.192, 1.0); // #6EC531
uniform vec4 color_dark : source_color = vec4(0.290, 0.608, 0.118, 1.0); // #4A9B1E
uniform vec4 color_deep : source_color = vec4(0.169, 0.369, 0.063, 1.0); // #2B5E10
uniform vec2 highlight_pos = vec2(0.38, 0.28);
uniform float highlight_size : hint_range(0.0, 1.0) = 0.35;
uniform float border_width : hint_range(0.0, 0.1) = 0.04;
uniform float bottom_shadow : hint_range(0.0, 0.2) = 0.09;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);
    float dist_center = distance(uv, center);

    // Border
    float outer_radius = 0.5 - border_width;
    if (dist_center > outer_radius) {
        if (dist_center > 0.5) {
            COLOR = vec4(0.0);
        } else {
            COLOR = color_deep;
        }
        return;
    }

    // Bottom shadow bar
    if (uv.y > (1.0 - bottom_shadow - border_width) && dist_center < outer_radius) {
        float shadow_blend = smoothstep(1.0 - bottom_shadow - border_width, 1.0 - border_width, uv.y);
        vec4 sphere_color = mix(color_main, color_dark, shadow_blend);
        COLOR = mix(sphere_color, color_deep, shadow_blend * 0.6);
        return;
    }

    // Radial gradient sphere
    float dist_highlight = distance(uv, highlight_pos);
    float highlight_factor = 1.0 - smoothstep(0.0, highlight_size, dist_highlight);

    // Base gradient: main at top-center, dark at bottom
    float vertical_factor = smoothstep(0.2, 0.9, uv.y);
    vec4 base_color = mix(color_main, color_dark, vertical_factor);

    // Highlight (bright spot)
    vec4 highlight_color = vec4(1.0, 1.0, 1.0, 0.5);
    vec4 final_color = mix(base_color, highlight_color, highlight_factor * 0.6);

    // Darken bottom hemisphere
    float bottom_darken = smoothstep(0.5, 1.0, uv.y);
    final_color = mix(final_color, color_deep, bottom_darken * 0.4);

    // Inset bottom darkening
    float inset_factor = smoothstep(0.6, 0.95, uv.y);
    final_color.rgb *= (1.0 - inset_factor * 0.35);

    COLOR = final_color;
}

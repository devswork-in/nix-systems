// Night light shader for Niri
// Uses standard color temperature approximation for ~3500K-4000K
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // niri_sample_render_element is the correct function for window-rule shaders
    vec4 color = niri_sample_render_element(fragCoord);
    
    // Applying a warmer tint:
    // Red: 100%
    // Green: ~80%
    // Blue: ~60%
    color.rgb *= vec3(1.0, 0.8, 0.6);
    
    fragColor = color;
}

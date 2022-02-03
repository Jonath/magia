#version 400 core

out vec4 fragColor;
in vec2 texCoords;

uniform sampler2D screenTexture;
uniform float gamma;

void main() {
    vec4 fragment = texture(screenTexture, texCoords);
    fragColor.rgb = pow(fragment.rgb, vec3(1.0f / gamma));
}
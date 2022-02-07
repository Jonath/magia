#version 400 core

out vec4 fragColor;
in vec3 texCoord;

uniform samplerCube skybox;
uniform float gamma;

void main() {  
    vec4 fragment = texture(skybox, texCoord);
    fragColor.rgb = pow(fragment.rgb, vec3(gamma));
}
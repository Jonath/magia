#version 400

out vec4 FragColor;

in vec3 color;
in vec2 texCoord;

uniform sampler2D tex0;

void main() {
    FragColor = texture(tex0, texCoord);
}
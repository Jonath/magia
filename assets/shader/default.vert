#version 400

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec3 iColor;
layout (location = 2) in vec2 iTexCoord;

out vec3 color;
out vec2 texCoord;

uniform mat4 camMatrix;

void main() {
    gl_Position = camMatrix * vec4(iPos, 1.0);
    color = iColor;
    texCoord = iTexCoord;
}
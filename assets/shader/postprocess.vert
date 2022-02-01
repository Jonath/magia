#version 400 core

layout (location = 0) in vec2 iPos;
layout (location = 1) in vec2 iTexCoords;

out vec2 texCoords;

void main() {
    gl_Position = vec4(iPos, 0.0, 1.0);
    texCoords = iTexCoords;
}
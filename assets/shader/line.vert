#version 400 core

layout (location = 0) in vec3 iPos;

uniform mat4 model;
uniform mat4 camMatrix;

void main() {
    gl_Position = camMatrix * model * vec4(iPos, 1.0);
}
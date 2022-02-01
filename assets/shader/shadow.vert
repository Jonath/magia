#version 400 core

layout (location = 0) in vec3 iPos;

uniform mat4 lightProjection;
uniform mat4 model;

void main() {
    gl_Position = lightProjection * model * vec4(iPos, 1.0);
}
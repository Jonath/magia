#version 400 core

layout (location = 0) in vec3 iPos;

out vec3 currentPos;

uniform mat4 camMatrix;
uniform mat4 model;
uniform mat4 translation;
uniform mat4 rotation;
uniform mat4 scale;

void main() {
    currentPos = vec3(model * translation * rotation * scale * vec4(iPos, 1.0));
    gl_Position = camMatrix * vec4(currentPos, 1.0);
}
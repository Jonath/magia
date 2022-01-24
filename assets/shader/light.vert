#version 400

layout (location = 0) in vec3 iPos;

out vec3 currentPos;

uniform mat4 model;
uniform mat4 camMatrix;

void main() {
    currentPos = vec3(model * vec4(iPos, 1.0));
    gl_Position = camMatrix * vec4(currentPos, 1.0);
}
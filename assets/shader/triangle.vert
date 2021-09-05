#version 400

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec3 iColor;

out vec3 color;

uniform float scale;

void main() {
    gl_Position = vec4(iPos.x + iPos.x * scale, iPos.y + iPos.y * scale, iPos.z + iPos.z * scale, 1.0);
    color = iColor;
}
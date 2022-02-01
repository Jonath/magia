#version 400 core

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec3 iNormal;
layout (location = 2) in vec3 iColor;
layout (location = 3) in vec2 iTexCoord;
layout (location = 4) in mat4 iInstanceMatrix;

out vec3 currentPos;
out vec3 normal;
out vec3 color;
out vec2 texCoord;

uniform mat4 camMatrix;
uniform mat4 model;

void main() {
    currentPos = vec3(iInstanceMatrix * model * vec4(iPos, 1.0));
    normal = iNormal;
    color = iColor;
    texCoord = iTexCoord;

    gl_Position = camMatrix * vec4(currentPos, 1.0);
}
#version 400

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec3 iColor;
layout (location = 2) in vec2 iTexCoord;
layout (location = 3) in vec3 iNormal;

out vec3 color;
out vec2 texCoord;
out vec3 normal;
out vec3 currentPos;

uniform mat4 camMatrix;
uniform mat4 model;

void main() {
    currentPos = vec3(model * vec4(iPos, 1.0));
    gl_Position = camMatrix * vec4(currentPos, 1.0);
    color = iColor;
    texCoord = iTexCoord;
    normal = iNormal;
}
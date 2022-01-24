#version 400

layout (location = 0) in vec3 iPos;
layout (location = 1) in vec3 iNormal;
layout (location = 2) in vec3 iColor;
layout (location = 3) in vec2 iTexCoord;

out vec3 currentPos;
out vec3 normal;
out vec3 color;
out vec2 texCoord;

uniform mat4 camMatrix;
uniform mat4 model;
uniform mat4 translation;
uniform mat4 rotation;
uniform mat4 scale;

void main() {
    currentPos = vec3(model * vec4(iPos, 1.0));
    normal = iNormal;
    color = iColor;
    texCoord = iTexCoord;

    gl_Position = camMatrix * vec4(currentPos, 1.0);
}
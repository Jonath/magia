#version 400 core

layout (location = 0) in vec3 iPos;

out vec3 texCoord;

uniform mat4 projection;
uniform mat4 view;

void main() {
    // Apply projection and view matrix
    vec4 currentPos = projection * view * vec4(iPos, 1.0f);

    // Having z equal to w will always result in a depth of 1
    gl_Position = vec4(currentPos.x, currentPos.y, currentPos.w, currentPos.w);

    // We want to flip the z axis due to the different coordinate systems (left hand vs right hand)
    texCoord = vec3(iPos.x, iPos.y, -iPos.z);
}
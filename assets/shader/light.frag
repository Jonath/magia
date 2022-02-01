#version 400 core

out vec4 fragColor;

uniform vec4 lightColor;

void main() {
    fragColor = lightColor;
}
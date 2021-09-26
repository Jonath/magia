#version 400

out vec4 FragColor;

in vec3 color;
in vec2 texCoord;
in vec3 normal;
in vec3 currentPos;

uniform sampler2D tex0;
uniform sampler2D tex1;

uniform vec4 lightColor;
uniform vec3 lightPos;
uniform vec3 camPos;

void main() {
    vec3 normal = normalize(normal);
    vec3 lightDir = normalize(lightPos - currentPos);

    float ambient = 0.20f;
    float diffuse = max(dot(normal, lightDir), 0.0f);

    vec3 viewDir = normalize(camPos - currentPos);
    vec3 reflectionDir = reflect(-lightDir, normal);
    float specAmount = pow(max(dot(viewDir, reflectionDir), 0.0f), 16);
    float specular = specAmount * 0.50f;

    FragColor = (texture(tex0, texCoord) * (diffuse + ambient) + texture(tex1, texCoord).r * specular) * lightColor;
    FragColor.a = 1.0f;
}
#version 400 core

out vec4 fragColor;

in vec3 currentPos;
in vec3 normal;
in vec3 color;
in vec2 texCoords;
in vec4 fragLightPosition;

uniform sampler2D backgroundTexture;
uniform sampler2D rTexture;
uniform sampler2D gTexture;
uniform sampler2D bTexture;
uniform sampler2D blendMap;

uniform vec4 lightColor;
uniform vec3 lightPos;
uniform vec3 camPos;

vec4 directionalLight(vec4 textureColor) {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(normal);
    vec3 lightDirection = normalize(lightPos);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Combining lightings, keeping alpha
    vec4 lightColor = (textureColor * (diffuse + ambient)) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

void main() {
    vec4 blendMapColor = texture(blendMap, texCoords);

    float backTextureAmount = 1 - (blendMapColor.r + blendMapColor.g + blendMapColor.b);
    vec4 backgroundTextureColor = texture(backgroundTexture, texCoords) * backTextureAmount;
    vec4 rTextureColor = texture(rTexture, texCoords) * blendMapColor.r;
    vec4 gTextureColor = texture(gTexture, texCoords) * blendMapColor.g;
    vec4 bTextureColor = texture(bTexture, texCoords) * blendMapColor.b;

    vec4 totalColor = backgroundTextureColor + rTextureColor + gTextureColor + bTextureColor;

    fragColor = directionalLight(totalColor);
}
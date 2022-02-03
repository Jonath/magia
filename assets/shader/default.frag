#version 400 core

out vec4 fragColor;

in vec3 currentPos;
in vec3 normal;
in vec3 color;
in vec2 texCoords;
in vec4 fragLightPosition;

uniform sampler2D diffuse0;
uniform sampler2D specular0;
uniform sampler2D shadowMap;

uniform vec4 lightColor;
uniform vec3 lightPos;
uniform vec3 camPos;

vec4 pointLight() {
    // Intensity
    vec3 lightVector = lightPos - currentPos;
    float lightDistance = length(lightVector);
    float a = 3.0f;
    float b = 0.7f;
    float intensity = 1.0f / (a * lightDistance * lightDistance + b * lightDistance + 1.0f);

    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(normal);
    vec3 lightDirection = normalize(lightVector);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Specular lighting
    float specular = 0.0f;
	if (diffuse != 0.0f) {
        vec3 viewDirection = normalize(camPos - currentPos);
        vec3 halfwayVector = normalize(viewDirection + lightDirection);

        float specAmount = pow(max(dot(normal, halfwayVector), 0.0f), 16);
        float specular = specAmount * 0.50f;
    }

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, texCoords) * (diffuse * intensity + ambient) + texture(specular0, texCoords).r * specular * intensity) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

vec4 directionalLight() {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(normal);
    vec3 lightDirection = normalize(lightPos);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Specular lighting
    float specular = 0.0f;
    if (diffuse != 0.0f) {
        vec3 viewDirection = normalize(camPos - currentPos);
        vec3 halfwayVector = normalize(viewDirection + lightDirection);

        float specAmount = pow(max(dot(normal, halfwayVector), 0.0f), 16);
        specular = specAmount * 0.50f;
    }

    // Discard alpha
    if (texture(diffuse0, texCoords).a < 0.1f) {
        discard;
    }

    float noShadow = 1.0f;
    vec3 lightCoords = fragLightPosition.xyz / fragLightPosition.w;

    if (lightCoords.z <= 1.0f) {
        lightCoords = (lightCoords + 1.0f) / 2.0f;

        float closestDepth = texture(shadowMap, lightCoords.xy).r;
        float currentDepth = lightCoords.z;

        float bias = 0.005f;
        if (currentDepth > closestDepth + bias) {
            noShadow = 0.0f;
        }
    }

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, texCoords) * (diffuse * noShadow + ambient) + texture(specular0, texCoords).r * specular * noShadow) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

vec4 spotLight() {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(normal);
    vec3 lightDirection = normalize(lightPos - currentPos);
    float diffuse = max(dot(normal, lightDirection), 0.0f);

    // Specular lighting
    float specular = 0.0f;
	if (diffuse != 0.0f) {
        vec3 viewDirection = normalize(camPos - currentPos);
        vec3 halfwayVector = normalize(viewDirection + lightDirection);

        float specAmount = pow(max(dot(normal, halfwayVector), 0.0f), 16);
        float specular = specAmount * 0.50f;
    }

    // Cone angle
    float outerCone = 0.90f; // ~25 degrees
    float innerCone = 0.95f; // ~18 degrees
    float angle = dot(vec3(0.0f, -1.0f, 0.0f), -lightDirection);
    float intensity = clamp((angle - outerCone) / (innerCone - outerCone), 0.0f, 1.0f);

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, texCoords) * (diffuse * intensity + ambient) + texture(specular0, texCoords).r * specular * intensity) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

float near = 0.1f;
float far = 100.0f;

float linearizeDepth(float depth) {
	return (2.0 * near * far) / (far + near - (depth * 2.0 - 1.0) * (far - near));
}

float logisticDepth(float depth, float steepness, float offset) {
	float zValue = linearizeDepth(depth);
	return (1.0 / (1.0 + exp(-steepness * (zValue - offset))));
}

// Fog
// float depth = logisticDepth(gl_FragCoord.z, 0.5, 5.0);
// fragColor = directionalLight() * (1.0 - depth) + vec4(depth * vec3(0.85, 0.85, 0.90), 1.0);

void main() {
    fragColor = directionalLight();
}
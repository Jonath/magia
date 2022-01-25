#version 400

out vec4 FragColor;

in vec3 currentPos;
in vec3 normal;
in vec3 color;
in vec2 texCoord;

uniform sampler2D diffuse0;
uniform sampler2D specular0;

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
    vec3 lightDir = normalize(lightVector);
    float diffuse = max(dot(normal, lightDir), 0.0f);

    // Specular lighting
    vec3 viewDir = normalize(camPos - currentPos);
    vec3 reflectionDir = reflect(-lightDir, normal);
    float specAmount = pow(max(dot(viewDir, reflectionDir), 0.0f), 16);
    float specular = specAmount * 0.50f;

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, texCoord) * (diffuse * intensity + ambient) + texture(specular0, texCoord).r * specular * intensity) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

vec4 directionalLight() {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(normal);
    vec3 lightDir = normalize(vec3(1.0f, 1.0f, 0.0f)); // Direction of light (opposite)
    float diffuse = max(dot(normal, lightDir), 0.0f);

    // Specular lighting
    vec3 viewDir = normalize(camPos - currentPos);
    vec3 reflectionDir = reflect(-lightDir, normal);
    float specAmount = pow(max(dot(viewDir, reflectionDir), 0.0f), 16);
    float specular = specAmount * 0.50f;

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, texCoord) * (diffuse + ambient) + texture(specular0, texCoord).r * specular) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

vec4 spotLight() {
    // Ambient lighting
    float ambient = 0.20f;

    // Diffuse lighting
    vec3 normal = normalize(normal);
    vec3 lightDir = normalize(lightPos - currentPos);
    float diffuse = max(dot(normal, lightDir), 0.0f);

    // Specular lighting
    vec3 viewDir = normalize(camPos - currentPos);
    vec3 reflectionDir = reflect(-lightDir, normal);
    float specAmount = pow(max(dot(viewDir, reflectionDir), 0.0f), 16);
    float specular = specAmount * 0.50f;

    // Cone angle
    float outerCone = 0.90f; // ~25 degrees
    float innerCone = 0.95f; // ~18 degrees
    float angle = dot(vec3(0.0f, -1.0f, 0.0f), -lightDir);
    float intensity = clamp((angle - outerCone) / (innerCone - outerCone), 0.0f, 1.0f);

    // Combining lightings, keeping alpha
    vec4 lightColor = (texture(diffuse0, texCoord) * (diffuse * intensity + ambient) + texture(specular0, texCoord).r * specular * intensity) * lightColor;
    lightColor.a = 1.0f;

    return lightColor;
}

float near = 0.1f;
float far = 100.0f;

float linearizeDepth(float depth) {
	return (2.0 * near * far) / (far + near - (depth * 2.0 - 1.0) * (far - near));
}

float logisticDepth(float depth, float steepness = 0.5f, float offset = 5.0f) {
	float zValue = linearizeDepth(depth);
	return (1 / (1 + exp(-steepness * (zValue - offset))));
}

void main() {
	float depth = logisticDepth(gl_FragCoord.z);
	FragColor = directionalLight() * (1.0f - depth) + vec4(depth * vec3(0.85f, 0.85f, 0.90f), 1.0f);
}
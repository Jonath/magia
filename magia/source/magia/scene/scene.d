module magia.scene.scene;

import gl3n.linalg;
import magia.common, magia.core, magia.render;
import magia.scene.entity;
import magia.shape.light;

private {
    Camera _camera, _defaultCamera;
    Entity3D[] _entities;
    LightInstance _globalLight;
    ShadowMap _shadowMap;
    Skybox _skybox;
    PostProcess _postProcess;
    Shader _defaultShader;
    Shader _lightShader;
    Shader _shadowShader;
}

void setCamera(Camera camera) {
    _camera = camera ? camera : _defaultCamera;
}

void setSkybox(Skybox skybox) {
    _skybox = skybox;
}

void setGlobalLight(LightInstance globalLight) {
    _globalLight = globalLight;
    _globalLight.setupShaders(_lightShader, _defaultShader);
}

Camera getCamera() {
    return _camera;
}

ShadowMap getShadowMap() {
    return _shadowMap;
}

void addEntity(Entity3D entity) {
    _entities ~= entity;
}

void initializeScene() {
    _defaultCamera = new Camera(screenWidth, screenHeight, Vec3f.zero);
    _camera = _defaultCamera;
    _shadowMap = new ShadowMap(vec3(0.0, 50.0, 0.0));
    _postProcess = new PostProcess(screenWidth, screenHeight);
    
    _defaultShader = new Shader("default.vert", "default.frag");
    _lightShader = new Shader("light.vert", "light.frag");
    _shadowShader = new Shader("shadow.vert", "shadow.frag");
}

void updateScene(float deltaTime) {
    _camera.update();

    if (getButtonDown(KeyButton.escape)) {
        stopApplication();
    }

    /// Contrôles temporaire subjectifs

    /// Speed at which the camera moves (uniform across all axis so far)
    const float speed = isButtonDown(KeyButton.leftShift) ? 1f : .1f;

    /// How well the speed of the camera scales up when it moves continuously
    const float sensitivity = .25f;

    /// Forward along X axis
    if (isButtonDown(KeyButton.a)) {
        _camera.position = _camera.position + (speed * -_camera.right);
    }

    /// Backwards along X axis
    if (isButtonDown(KeyButton.d)) {
        _camera.position = _camera.position + (speed * _camera.right);
    }

    /// Forward along Y axis
    if (isButtonDown(KeyButton.space)) {
        _camera.position = _camera.position + (speed * _camera.up);
    }

    /// Backwards along Y axis
    if (isButtonDown(KeyButton.leftControl)) {
        _camera.position = _camera.position + (speed * -_camera.up);
    }

    /// Forward along Z axis
    if (isButtonDown(KeyButton.w)) {
        _camera.position = _camera.position + (speed * _camera.forward);
    }

    /// Backwards along Z axis
    if (isButtonDown(KeyButton.s)) {
        _camera.position = _camera.position + (speed * -_camera.forward);
    }

    /// Look
    const Vec2f deltaPos = getRelativeMousePos();

    const float rotX = sensitivity * deltaPos.y;
    const float rotY = sensitivity * deltaPos.x;

    const vec3 newOrientation = rotate(_camera.forward, -rotX * degToRad, _camera.right);

    const float limitRotX = 5f * degToRad;

    const float angleUp = angle(newOrientation, _camera.up);
    const float angleDown = angle(newOrientation, -_camera.up);

    if (!(angleUp <= limitRotX || angleDown <= limitRotX)) {
        _camera.forward = newOrientation;
    }

    _camera.forward = rotate(_camera.forward, -rotY * degToRad, _camera.up);

    foreach(entity; _entities) {
        entity.update(deltaTime);
    }
}

void drawScene() {
    //_shadowMap.draw(_entities);

    _postProcess.prepare();

    if (_skybox) {
        _skybox.draw();
    }

    if (_globalLight) {
        _globalLight.draw(_lightShader);
    }

    foreach(entity; _entities) {
        entity.draw(_defaultShader);
    }

    _postProcess.draw();
    renderWindow();
}

/// @TODO: Bouger ça à un endroit plus approprié.
alias Quaternionf = Quaternion!(float);

/// @TODO: Bouger ça à un endroit plus approprié.
/// Rotates p around axis r by angle
vec3 rotate(vec3 p, float angle, vec3 r) {
    const float halfAngle = angle / 2;

    const float cosRot = cos(halfAngle);
    const float sinRot = sin(halfAngle);

    const Quaternionf q1 = Quaternionf(0f, p.x, p.y, p.z);
    const Quaternionf q2 = Quaternionf(cosRot, r.x * sinRot, r.y * sinRot, r.z * sinRot);
    const Quaternionf q3 = q2 * q1 * q2.conjugated;

    return vec3(q3.x, q3.y, q3.z);
}

/// @TODO: Bouger ça à un endroit plus approprié.
/// Returns the angle between two vectors
float angle(vec3 a, vec3 b) {
    return acos(dot(a.normalized, b.normalized));
}

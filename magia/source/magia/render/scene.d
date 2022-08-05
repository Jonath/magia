module magia.render.scene;

import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core, magia.render;
import magia.common.event;
import magia.shape.light;
import magia.shape.terrain;

alias Entities = Entity3D[];

private {
    // Camera, light
    Camera _camera;
    LightInstance _globalLight;

    // 3D entity containers
    Entities _entities;
    Entities[Model] _modelEntityMap;

    // Skybox
    Skybox _skybox;

    // Terrain
    Terrain _terrain;

    // Processing
    ShadowMap _shadowMap;
    PostProcess _postProcess;

    // Shaders
    Shader _defaultShader;
    Shader _lightShader;
    Shader _shadowShader;
    Shader _terrainShader;

    // Flags
    bool _showShadows = false;
}

void setCamera(Camera camera) {
    _camera = camera;
}

void setSkybox(Skybox skybox) {
    _skybox = skybox;
}

void setTerrain(Terrain terrain) {
    _terrain = terrain;
}

void setGlobalLight(LightInstance globalLight) {
    _globalLight = globalLight;
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
    _shadowMap = new ShadowMap();
    _postProcess = new PostProcess(screenWidth, screenHeight);
    
    _defaultShader = new Shader("default.vert", "default.frag");
    _lightShader = new Shader("light.vert", "light.frag");
    _shadowShader = new Shader("shadow.vert", "shadow.frag");
    _terrainShader = new Shader("terrain.vert", "terrain.frag");
}

void updateScene(float deltaTime) {
    if (!_camera) {
        return;
    }

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

    /// Show/hide shadows
    if (getButtonDown(KeyButton.r)) {
        _showShadows = !_showShadows;
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
    if (!_camera) {
        return;
    }

    // @TODO reference default shader and terrain shader together in a list "material shaders"
    _camera.passToShader(_defaultShader);
    _globalLight.setupShaders(_lightShader, _defaultShader);

    if (_showShadows) {
        _shadowMap.register(_entities, vec3(-20.0, -20.0, -20.0)); // _globalLight.transform.position
    } else {
        _shadowMap.clear();
    }

    _postProcess.prepare();

    // @TODO: post-processing should not apply
    if (_skybox) {
        _skybox.draw();
    }

    if (_globalLight) {
        _globalLight.draw(_lightShader);
    }

    _shadowMap.bind(_defaultShader);

    if (_terrain) {
        _terrain.draw(_defaultShader);
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

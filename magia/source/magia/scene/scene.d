module magia.scene.scene;

import magia.core, magia.render;

private {
    Camera _mainCamera, _defaultCamera;
}

void setCamera(Camera camera) {
    _mainCamera = camera ? camera : _defaultCamera;
}

Camera getCamera() {
    return _mainCamera;
}

void initializeScene() {
    _defaultCamera = new Camera(screenWidth, screenHeight, Vec3f.zero);
    _mainCamera = _defaultCamera;
}

void updateScene(float deltaTime) {
    _mainCamera.update();
}

void drawScene() {

}
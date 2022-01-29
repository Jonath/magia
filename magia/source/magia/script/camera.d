module magia.script.camera;

import gl3n.linalg;
import grimoire;

import magia.core, magia.render, magia.scene;

package(magia.script) void loadMagiaLibCamera(GrLibrary library) {
    GrType cameraType = library.addForeign("Camera");

    library.addFunction(&_camera, "Camera", [], [cameraType]);
    library.addFunction(&_setCamera0, "setCamera");
    library.addFunction(&_setCamera1, "setCamera", [cameraType]);
    library.addFunction(&_getCamera, "getCamera", [], [cameraType]);
    library.addFunction(&_setCameraPosition, "position", [cameraType, grReal, grReal, grReal]);
    library.addFunction(&_getCameraPosition, "position", [cameraType], [grReal, grReal, grReal]);
    library.addFunction(&_update, "update", [cameraType], []);
}

private void _camera(GrCall call) {
    Camera camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));
    call.setForeign(camera);
}

private void _setCamera0(GrCall) {
    setCamera(null);
}

private void _setCamera1(GrCall call) {
    Camera camera = call.getForeign!Camera(0);
    setCamera(camera);
}

private void _getCamera(GrCall call) {
    call.setForeign(getCamera());
}

private void _setCameraPosition(GrCall call) {
    Camera camera = call.getForeign!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.position(vec3(call.getReal(1), call.getReal(2), call.getReal(3)));
}

private void _getCameraPosition(GrCall call) {
    Camera camera = call.getForeign!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setReal(camera.position.x);
    call.setReal(camera.position.y);
    call.setReal(camera.position.z);
}

private void _update(GrCall call) {
    Camera camera = call.getForeign!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.update();
}

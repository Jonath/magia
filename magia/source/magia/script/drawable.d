module magia.script.drawable;

import grimoire;

import magia.core, magia.render, magia.shape;

package(magia.script) void loadMagiaLibDrawable(GrLibrary library) {
    GrType cameraType = library.addForeign("Camera");
    GrType drawableType = library.addForeign("Drawable3D");
    GrType lightType = library.addForeign("Light", [], "Drawable3D");
    GrType modelType = library.addForeign("Model", [], "Drawable3D");
    GrType pyramidType = library.addForeign("Pyramid", [], "Drawable3D");
    GrType quadType = library.addForeign("Quad", [], "Drawable3D");

    library.addPrimitive(&_camera1, "loadCamera", [], [cameraType]);
    library.addPrimitive(&_update, "update", [cameraType], []);
    library.addPrimitive(&_draw, "draw", [drawableType], []);
    library.addPrimitive(&_light1, "loadLight", [cameraType], [lightType]);
    library.addPrimitive(&_model1, "loadModel", [cameraType, lightType, grString], [modelType]);
    library.addPrimitive(&_quad1, "loadQuad", [cameraType, lightType], [quadType]);
    library.addPrimitive(&_pyramid1, "loadPyramid", [], [pyramidType]);
}

private void _update(GrCall call) {
    Camera camera = call.getForeign!Camera(0);
    camera.update();
}

private void _draw(GrCall call) {
    Drawable3D drawable = call.getForeign!Drawable3D(0);
    drawable.draw();
}

private void _camera1(GrCall call) {
    Camera camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));
    call.setForeign(camera);
}

private void _light1(GrCall call) {
    Light light = new Light(call.getForeign!Camera(0));
    call.setForeign(light);
}

private void _model1(GrCall call) {
    BasicModel model = new BasicModel(call.getForeign!Camera(0), call.getForeign!Light(1), call.getString(2));
    call.setForeign(model);
}

private void _quad1(GrCall call) {
    Quad quad = new Quad(call.getForeign!Camera(0), call.getForeign!Light(1));
    call.setForeign(quad);
}

private void _pyramid1(GrCall call) {
    Pyramid pyramid = new Pyramid();
    call.setForeign(pyramid);
}
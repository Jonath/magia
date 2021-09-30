module magia.script.shape;

import grimoire;

import magia.shape, magia.render;

package(magia.script) void loadMagiaLibShape(GrLibrary library) {
    GrType lightType = library.addForeign("Light", [], "Drawable");
    GrType quadType = library.addForeign("Quad", [], "Drawable");
    GrType pyramidType = library.addForeign("Pyramid", [], "Drawable");

    library.addPrimitive(&_light1, "light", [], [lightType]);
    library.addPrimitive(&_quad1, "quad", [], [quadType]);
    library.addPrimitive(&_pyramid1, "pyramid", [], [pyramidType]);
}

private void _light1(GrCall call) {
    Light light = new Light();
    call.setForeign(light);
}

private void _quad1(GrCall call) {
    Quad quad = new Quad();
    call.setForeign(quad);
}

private void _pyramid1(GrCall call) {
    Pyramid pyramid = new Pyramid();
    call.setForeign(pyramid);
}
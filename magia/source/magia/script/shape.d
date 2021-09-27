module magia.script.shape;

import grimoire;

import magia.shape, magia.render;

package(magia.script) void loadMagiaLibShape(GrLibrary library) {
    //GrType triangleType = library.addForeign("Triangle", [], "Drawable");
    //GrType quadType = library.addForeign("Quad", [], "Drawable");
    GrType pyramidType = library.addForeign("Pyramid", [], "Drawable");

    //library.addPrimitive(&_triangle1, "triangle", [], [triangleType]);
    //library.addPrimitive(&_quad1, "quad", [], [quadType]);
    library.addPrimitive(&_pyramid1, "pyramid", [], [pyramidType]);
}

/*private void _triangle1(GrCall call) {
    Triangle triangle = new Triangle();
    call.setForeign(triangle);
}

private void _quad1(GrCall call) {
    Quad quad = new Quad();
    call.setForeign(quad);
}*/

private void _pyramid1(GrCall call) {
    Pyramid pyramid = new Pyramid();
    call.setForeign(pyramid);
}
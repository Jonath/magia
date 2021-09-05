module magia.script.shape;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibShape(GrLibrary library) {
    GrType triangleType = library.addForeign("Triangle", [], "Drawable");
    GrType rectangleType = library.addForeign("Rectangle", [], "Drawable");
    GrType pyramidType = library.addForeign("Pyramid", [], "Drawable");

    library.addPrimitive(&_triangle1, "triangle", [], [triangleType]);
    library.addPrimitive(&_rectangle1, "rectangle", [], [rectangleType]);
    library.addPrimitive(&_pyramid1, "pyramid", [], [pyramidType]);
}

private void _triangle1(GrCall call) {
    Triangle triangle = new Triangle();
    call.setForeign(triangle);
}

private void _rectangle1(GrCall call) {
    Rectangle rectangle = new Rectangle();
    call.setForeign(rectangle);
}

private void _pyramid1(GrCall call) {
    Pyramid pyramid = new Pyramid();
    call.setForeign(pyramid);
}
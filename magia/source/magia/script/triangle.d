module magia.script.triangle;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibTriangle(GrLibrary library) {
    GrType triangleType = library.addForeign("Triangle", [], "Drawable");
    library.addPrimitive(&_triangle1, "triangle", [], [triangleType]);
}

private void _triangle1(GrCall call) {
    Triangle triangle = new Triangle();
    call.setForeign(triangle);
}
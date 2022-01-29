module magia.script.primitive;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibPrimitive(GrLibrary library) {
    GrType colorType = grGetClassType("Color");
    library.addFunction(&_rectangle1, "rectangle", [
            grReal, grReal, grReal, grReal
        ]);
    library.addFunction(&_rectangle2, "rectangle", [
            grReal, grReal, grReal, grReal, colorType
        ]);
    library.addFunction(&_rectangle3, "rectangle", [
            grReal, grReal, grReal, grReal, colorType, grReal
        ]);
}

private void _rectangle1(GrCall call) {
    drawFilledRect(Vec2f(call.getReal(0), call.getReal(1)),
        Vec2f(call.getReal(2), call.getReal(3)));
}

private void _rectangle2(GrCall call) {
    drawFilledRect(Vec2f(call.getReal(0), call.getReal(1)),
        Vec2f(call.getReal(2), call.getReal(3)), Color(call.getObject(4)));
}

private void _rectangle3(GrCall call) {
    drawFilledRect(Vec2f(call.getReal(0), call.getReal(1)),
        Vec2f(call.getReal(2), call.getReal(3)), Color(call.getObject(4)), call.getReal(5));
}

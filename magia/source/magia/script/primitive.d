module magia.script.primitive;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibPrimitive(GrLibrary library) {
    GrType colorType = grGetClassType("Color");
    library.addPrimitive(&_rectangle1, "rectangle", [
            grFloat, grFloat, grFloat, grFloat
            ]);
    library.addPrimitive(&_rectangle2, "rectangle", [
            grFloat, grFloat, grFloat, grFloat, colorType
            ]);
    library.addPrimitive(&_rectangle3, "rectangle", [
            grFloat, grFloat, grFloat, grFloat, colorType, grFloat
            ]);
}

private void _rectangle1(GrCall call) {
    drawFilledRect(Vec2f(call.getFloat(0), call.getFloat(1)),
            Vec2f(call.getFloat(2), call.getFloat(3)));
}

private void _rectangle2(GrCall call) {
    drawFilledRect(Vec2f(call.getFloat(0), call.getFloat(1)),
            Vec2f(call.getFloat(2), call.getFloat(3)), Color(call.getObject(4)));
}

private void _rectangle3(GrCall call) {
    drawFilledRect(Vec2f(call.getFloat(0), call.getFloat(1)),
            Vec2f(call.getFloat(2), call.getFloat(3)), Color(call.getObject(4)), call.getFloat(5));
}
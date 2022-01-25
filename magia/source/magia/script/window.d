module magia.script.window;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibWindow(GrLibrary library) {
    GrType colorType = grGetClassType("Color");
    library.addPrimitive(&_setColor1, "setColor", []);
    library.addPrimitive(&_setColor2, "setColor", [colorType]);
    library.addPrimitive(&_getColor, "getColor", [], [colorType]);
    library.addPrimitive(&_setAlpha1, "setAlpha", []);
    library.addPrimitive(&_setAlpha2, "setAlpha", [grReal]);
    library.addPrimitive(&_getAlpha, "getAlpha", [], [grReal]);
}

private void _setColor1(GrCall) {
    setBaseColor(Color.white);
}

private void _setColor2(GrCall call) {
    setBaseColor(Color(call.getObject(0)));
}

private void _getColor(GrCall call) {
    GrObject object = call.createObject("Color");
    Color color = getBaseColor();
    object.setReal("r", color.r);
    object.setReal("g", color.g);
    object.setReal("b", color.b);
    call.setObject(object);
}

private void _setAlpha1(GrCall) {
    setBaseAlpha(1f);
}

private void _setAlpha2(GrCall call) {
    setBaseAlpha(call.getReal(0));
}

private void _getAlpha(GrCall call) {
    call.setReal(getBaseAlpha());
}

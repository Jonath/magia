module magia.script.text;

import grimoire;

import magia.render;

package(magia.script) void loadMagiaLibText(GrLibrary library) {
    GrType fontType = library.addForeign("Font");
    GrType trueTypeFontType = library.addForeign("TrueTypeFont", [], "Font");
    GrType bitmapFontType = library.addForeign("BitmapFont", [], "Font");

    library.addPrimitive(&_trueTypeFont, "TrueTypeFont", [
            grString, grInt, grInt
            ], [trueTypeFontType]);

    library.addPrimitive(&_setFont1, "setFont", []);
    library.addPrimitive(&_setFont2, "setFont", [fontType]);
    library.addPrimitive(&_getFont, "getFont", [], [fontType]);

    library.addPrimitive(&_print1, "print", [grString, grFloat, grFloat]);
    library.addPrimitive(&_print2, "print", [
            grString, grFloat, grFloat, fontType
            ]);
}

private void _trueTypeFont(GrCall call) {
    TrueTypeFont font = new TrueTypeFont(call.getString(0), call.getInt(1), call.getInt(2));
    call.setForeign(font);
}

private void _setFont1(GrCall call) {
    setDefaultFont(null);
}

private void _setFont2(GrCall call) {
    setDefaultFont(call.getForeign!Font(0));
}

private void _getFont(GrCall call) {
    call.setForeign(getDefaultFont());
}

private void _print1(GrCall call) {
    drawText(call.getString(0), call.getFloat(1), call.getFloat(2));
}

private void _print2(GrCall call) {
    drawText(call.getString(0), call.getFloat(1), call.getFloat(2), call.getForeign!Font(3));
}

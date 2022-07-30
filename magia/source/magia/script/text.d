module magia.script.text;

import grimoire;
import gl3n.linalg;

import magia.render;

package(magia.script) void loadMagiaLibText(GrLibrary library) {
    GrType fontType = library.addForeign("Font");
    GrType trueTypeFontType = library.addForeign("TrueTypeFont", [], "Font");
    GrType bitmapFontType = library.addForeign("BitmapFont", [], "Font");

    library.addFunction(&_trueTypeFont, "TrueTypeFont", [
            grString, grInt, grInt
        ], [trueTypeFontType]);

    library.addFunction(&_setFont1, "setFont", []);
    library.addFunction(&_setFont2, "setFont", [fontType]);
    library.addFunction(&_getFont, "getFont", [], [fontType]);

    library.addFunction(&_print1, "print", [grString, grReal, grReal]);
    library.addFunction(&_print2, "print", [
            grString, grReal, grReal, fontType
        ]);
}

private void _trueTypeFont(GrCall call) {
    TrueTypeFont font = new TrueTypeFont(call.getString(0), call.getInt32(1), call.getInt32(2));
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
    drawText(mat4.identity, call.getString(0), call.getReal(1), call.getReal(2));
}

private void _print2(GrCall call) {
    drawText(mat4.identity, call.getString(0), call.getReal(1), call.getReal(2), call.getForeign!Font(3));
}

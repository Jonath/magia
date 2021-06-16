module magia.script.text;

import grimoire;

import magia.render;

package(magia.script) void loadMagiaLibText(GrLibrary library) {
    GrType fontType = library.addForeign("Font");
    GrType trueTypeFontType = library.addForeign("TrueTypeFont", [], "Font");
    GrType bitmapFontType = library.addForeign("BitmapFont", [], "Font");

    library.addPrimitive(&_trueTypeFont, "TrueTypeFont", ["p", "s", "o"],
            [grString, grInt, grInt], [trueTypeFontType]);
    library.addPrimitive(&_print1, "print", ["s", "x", "y"], [
            grString, grFloat, grFloat
            ]);
    library.addPrimitive(&_print2, "print", ["s", "x", "y", "f"], [
            grString, grFloat, grFloat, fontType
            ]);
}

private void _trueTypeFont(GrCall call) {
    TrueTypeFont font = new TrueTypeFont(call.getString("p"), call.getInt("s"), call.getInt("o"));
    call.setUserData(font);
}

private void _print1(GrCall call) {
    drawText(call.getString("s"), call.getFloat("x"), call.getFloat("y"));
}

private void _print2(GrCall call) {
    drawText(call.getString("s"), call.getFloat("x"), call.getFloat("y"),
            call.getUserData!Font("f"));
}

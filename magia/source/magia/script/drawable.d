module magia.script.drawable;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibDrawable(GrLibrary library) {
    GrType drawableType = library.addForeign("Drawable");
    library.addPrimitive(&_draw, "draw", [drawableType, grFloat, grFloat], []);
}

private void _draw(GrCall call) {
    Drawable drawable = call.getForeign!Drawable(0);
    if(!drawable) {
        call.raise("NullError");
        return;
    }
    drawable.draw(Vec2f(call.getFloat(1), call.getFloat(2)));
}
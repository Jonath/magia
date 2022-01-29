module magia.script.sprite;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibSprite(GrLibrary library) {
    GrType spriteType = library.addForeign("Sprite", [], "Drawable");
    GrType textureType = grGetForeignType("Texture");

    library.addFunction(&_sprite1, "Sprite", [textureType], [spriteType]);
    library.addFunction(&_sprite2, "Sprite", [
            textureType, grInt, grInt, grInt, grInt
        ], [spriteType]);

    library.addFunction(&_setClip, "setClip", [
            spriteType, grInt, grInt, grInt, grInt
        ]);
    library.addFunction(&_getClip, "getClip", [], [
            spriteType, grInt, grInt, grInt, grInt
        ]);

    library.addFunction(&_getWidth, "getWidth", [spriteType], [grReal]);
    library.addFunction(&_getHeight, "getHeight", [spriteType], [grReal]);
    library.addFunction(&_getHeight, "getSize", [spriteType], [grReal, grReal]);
}

private void _sprite1(GrCall call) {
    Sprite sprite = new Sprite(call.getForeign!Texture(0));
    call.setForeign(sprite);
}

private void _sprite2(GrCall call) {
    Sprite sprite = new Sprite(call.getForeign!Texture(0),
        Vec4i(call.getInt32(1), call.getInt32(2), call.getInt32(3), call.getInt32(4)));
    call.setForeign(sprite);
}

private void _setClip(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    sprite.clip = Vec4i(call.getInt32(1), call.getInt32(2), call.getInt32(3), call.getInt32(4));
}

private void _getClip(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }

    call.setInt(sprite.clip.x);
    call.setInt(sprite.clip.y);
    call.setInt(sprite.clip.z);
    call.setInt(sprite.clip.w);
}

private void _getWidth(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setReal(sprite.size.x);
}

private void _getHeight(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setReal(sprite.size.y);
}

private void _getSize(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setReal(sprite.size.x);
    call.setReal(sprite.size.y);
}

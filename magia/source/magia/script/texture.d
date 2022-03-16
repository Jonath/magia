module magia.script.texture;

import grimoire;

import magia.render;

package(magia.script) void loadMagiaLibTexture(GrLibrary library) {
    /+GrType textureType = library.addForeign("Texture");

    library.addFunction(&_texture, "Texture", [grString], [textureType]);

    library.addFunction(&_getWidth, "getWidth", [textureType], [grInt]);
    library.addFunction(&_getHeight, "getHeight", [textureType], [grInt]);
    library.addFunction(&_getHeight, "getSize", [textureType], [grInt, grInt]);+/
}
/+
private void _texture(GrCall call) {
    Texture texture = new Texture(call.getString(0));
    call.setForeign(texture);
}

private void _getWidth(GrCall call) {
    Texture texture = call.getForeign!Texture(0);
    if (!texture) {
        call.raise("NullError");
        return;
    }
    call.getInt(texture.width);
}

private void _getHeight(GrCall call) {
    Texture texture = call.getForeign!Texture(0);
    if (!texture) {
        call.raise("NullError");
        return;
    }
    call.getInt(texture.height);
}

private void _getSize(GrCall call) {
    Texture texture = call.getForeign!Texture(0);
    if (!texture) {
        call.raise("NullError");
        return;
    }
    call.getInt(texture.width);
    call.getInt(texture.height);
}
+/
module magia.script.loader;

import grimoire;

import magia.script.window, magia.script.drawable, magia.script.texture,
magia.script.primitive, magia.script.sprite, magia.script.text;

/// Loads all sub libraries
GrLibrary loadMagiaLibrary() {
    GrLibrary library = new GrLibrary;
    loadMagiaLibWindow(library);
    loadMagiaLibDrawable(library);
    loadMagiaLibTexture(library);
    loadMagiaLibPrimitive(library);
    loadMagiaLibSprite(library);
    loadMagiaLibText(library);
    return library;
}

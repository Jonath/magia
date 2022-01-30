module magia.script.loader;

import grimoire;

import magia.script.window, magia.script.camera, magia.script.drawable, magia.script.texture,
magia.script.primitive, magia.script.sprite, magia.script.text, magia.script.vec2, magia.script.vec3;
import magia.script.color;

/// Loads all sub libraries
GrLibrary loadMagiaLibrary() {
    GrLibrary library = new GrLibrary;
    loadMagiaLibWindow(library);
    loadMagiaLibCamera(library);
    loadMagiaLibDrawable(library);
    loadMagiaLibTexture(library);
    loadMagiaLibPrimitive(library);
    loadMagiaLibSprite(library);
    loadMagiaLibText(library);
    loadMagiaLibVec2(library);
    loadMagiaLibVec3(library);
    loadMagiaLibColor(library);
    return library;
}

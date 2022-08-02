module magia.script.loader;

import grimoire;

import magia.script.common;
import magia.script.window;
import magia.script.camera;
import magia.script.drawable;
import magia.script.texture;
import magia.script.primitive;
import magia.script.sprite;
import magia.script.text;
import magia.script.vec2;
import magia.script.vec3;
import magia.script.color;
import magia.script.ui;

/// Loads all sub libraries
GrLibrary loadMagiaLibrary() {
    GrLibrary library = new GrLibrary;
    loadMagiaLibCommon(library);
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
    loadMagiaLibUI(library);
    return library;
}

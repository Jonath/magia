module magia.script.loader;

import grimoire;

import magia.script.text;

GrLibrary loadMagiaLibrary() {
    GrLibrary library = new GrLibrary;
    loadMagiaLibText(library);
    return library;
}
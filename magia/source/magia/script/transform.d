module magia.script.transform;

import grimoire;

import gl3n.linalg;

package(magia.script) void loadMagiaLibTransform(GrLibrary library) {
    GrType transformType = library.addForeign("Transform");

    library.addFunction(&_position, "position", [transformType], [grReal, grReal, grReal]);
    library.addFunction(&_rotation1, "rotation", [transformType], [grReal, grReal, grReal]);
    library.addFunction(&_rotation2, "rotation", [transformType], [grReal, grReal, grReal]);
    library.addFunction(&_scale, "scale", [transformType], [grReal, grReal, grReal]);
}

private void _position(GrCall call) {
}

private void _rotation1(GrCall call) {
}

private void _rotation2(GrCall call) {
}

private void _scale(GrCall call) {
}
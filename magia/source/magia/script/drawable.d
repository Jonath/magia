module magia.script.drawable;

import grimoire;

import gl3n.linalg;

import magia.core, magia.render, magia.shape;

import std.stdio;

package(magia.script) void loadMagiaLibDrawable(GrLibrary library) {
    GrType vec3Type = library.addClass("vec3", ["x", "y", "z"], [grReal, grReal, grReal]);
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grReal, grReal, grReal, grReal]);

    GrType drawableType = library.addForeign("Drawable3D");
    GrType lightType = library.addForeign("Light", [], "Drawable3D");
    GrType modelType = library.addForeign("Model", [], "Drawable3D");
    GrType quadType = library.addForeign("Quad", [], "Drawable3D");

    library.addPrimitive(&_vec3, "vec3", [grReal, grReal, grReal], [vec3Type]);
    library.addPrimitive(&_quat, "quat", [grReal, grReal, grReal, grReal], [quatType]);
    library.addPrimitive(&_position, "position", [drawableType, vec3Type], []);
    library.addPrimitive(&_draw, "draw", [drawableType], []);
    library.addPrimitive(&_light1, "loadLight", [], [lightType]);
    library.addPrimitive(&_model1, "loadModel", [
            lightType, grString
        ], [modelType]);
    library.addPrimitive(&_quad1, "loadQuad", [lightType], [
            quadType
        ]);
}

private void _vec3(GrCall call) {
    GrObject v = call.createObject("vec3");
    v.setReal("x", call.getReal(0));
    v.setReal("y", call.getReal(0));
    v.setReal("z", call.getReal(0));
    call.setObject(v);
}

private void _quat(GrCall call) {
    GrObject q = call.createObject("quat");
    q.setReal("w", call.getReal(0));
    q.setReal("x", call.getReal(0));
    q.setReal("y", call.getReal(0));
    q.setReal("z", call.getReal(0));
    call.setObject(q);
}

private void _draw(GrCall call) {
    Drawable3D drawable = call.getForeign!Drawable3D(0);
    drawable.draw();
}

private void _position(GrCall call) {
    Drawable3D drawable = call.getForeign!Drawable3D(0);
    GrObject position = call.getObject(1);
    writeln("Set light x: ", position.getReal("x"));
    writeln("Set light y: ", position.getReal("y"));
    writeln("Set light z: ", position.getReal("z"));
    drawable.transform.position = vec3(position.getReal("x"), position.getReal("y"), position.getReal("z"));
}

private void _light1(GrCall call) {
    Light light = new Light();
    call.setForeign(light);
}

private void _model1(GrCall call) {
    BasicModel model = new BasicModel(call.getForeign!Light(0), call.getString(
            1));
    call.setForeign(model);
}

private void _quad1(GrCall call) {
    Quad quad = new Quad(call.getForeign!Light(0));
    call.setForeign(quad);
}
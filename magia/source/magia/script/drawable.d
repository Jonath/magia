module magia.script.drawable;

import grimoire;

import gl3n.linalg;

import magia.core, magia.render, magia.shape;

import std.stdio;

package(magia.script) void loadMagiaLibDrawable(GrLibrary library) {
    GrType vec3Type = library.addClass("vec3", ["x", "y", "z"], [grReal, grReal, grReal]);
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grReal, grReal, grReal, grReal]);

    GrType entityType = library.addForeign("Entity");
    GrType lightType = library.addForeign("Light", [], "Entity");
    GrType modelType = library.addForeign("Model", [], "Entity");
    GrType quadType = library.addForeign("Quad", [], "Entity");

    library.addPrimitive(&_vec3, "vec3", [grReal, grReal, grReal], [vec3Type]);
    library.addPrimitive(&_quat, "quat", [grReal, grReal, grReal, grReal], [quatType]);
    library.addPrimitive(&_position1, "position", [entityType, grReal, grReal, grReal], []);
    library.addPrimitive(&_draw1, "draw", [entityType], []);
    library.addPrimitive(&_light1, "loadLight", [], [lightType]);
    library.addPrimitive(&_model1, "loadModel", [grString, lightType], [modelType]);
    library.addPrimitive(&_quad1, "loadQuad", [lightType], [quadType]);
}

private void _vec3(GrCall call) {
    GrObject v = call.createObject("vec3");
    v.setReal("x", call.getReal(0));
    v.setReal("y", call.getReal(1));
    v.setReal("z", call.getReal(2));
    call.setObject(v);
}

private void _quat(GrCall call) {
    GrObject q = call.createObject("quat");
    q.setReal("w", call.getReal(0));
    q.setReal("x", call.getReal(1));
    q.setReal("y", call.getReal(2));
    q.setReal("z", call.getReal(3));
    call.setObject(q);
}

private void _position1(GrCall call) {
    Instance3D instance = call.getForeign!Instance3D(0);
    instance.transform.position = vec3(call.getReal(1), call.getReal(2), call.getReal(3));
}

private void _draw1(GrCall call) {
    Drawable3D drawable = call.getForeign!Drawable3D(0);
    drawable.draw();
}

private void _light1(GrCall call) {
    LightGroup lightGroup = new LightGroup();
    LightInstance lightInstance = new LightInstance(lightGroup);
    call.setForeign(lightInstance);
}

private void _model1(GrCall call) {
    ModelGroup modelGroup = new ModelGroup(call.getString(0)); // @TODO, check model group not already loaded (hashmap?)
    ModelInstance modelInstance = new ModelInstance(modelGroup, call.getForeign!LightInstance(1));
    call.setForeign(modelInstance);
}

private void _quad1(GrCall call) {
    QuadGroup quadGroup = new QuadGroup();
    QuadInstance quadInstance = new QuadInstance(quadGroup, call.getForeign!LightInstance(0));
    call.setForeign(quadInstance);
}
module magia.script.drawable;

import grimoire;

import gl3n.linalg;

import magia.core, magia.render, magia.shape, magia.scene;

import std.stdio;

/// Dirty
class MatWrapper {
    /// As heck
    mat4 matrix;

    /// Constructor
    this(mat4 matrix_) {
        matrix = matrix_;
    }
}

package(magia.script) void loadMagiaLibDrawable(GrLibrary library) {
    GrType vec3Type = grGetClassType("vec3");
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grReal, grReal, grReal, grReal]);
    GrType mat4Type = library.addForeign("mat4");

    GrType entityType = library.addForeign("Entity");
    GrType lightType = library.addForeign("Light", [], "Entity");
    GrType modelType = library.addForeign("Model", [], "Entity");
    GrType quadType = library.addForeign("Quad", [], "Entity");
    GrType skyboxType = library.addForeign("Skybox", [], "Entity");
    GrType lightEnumType = library.addEnum("LightKind", ["DIRECTIONAL", "POINT", "SPOT"]);

    library.addFunction(&_quat, "quat", [grReal, grReal, grReal, grReal], [quatType]);
    library.addFunction(&_position1, "position", [entityType, grReal, grReal, grReal], []);
    library.addFunction(&_position2, "position", [entityType, vec3Type], []);
    library.addFunction(&_scale1, "scale", [entityType, grReal, grReal, grReal], []);
    library.addFunction(&_scale2, "scale", [entityType, vec3Type], []);
    library.addFunction(&_packInstanceMatrix, "packInstanceMatrix", [vec3Type, quatType, vec3Type], [mat4Type]);
    library.addFunction(&_light, "loadLight", [lightEnumType], [lightType]);
    library.addFunction(&_model1, "loadModel", [grString], [modelType]);
    library.addFunction(&_model2, "loadModel", [grString, grInt, grArray(mat4Type)], [modelType]);
    library.addFunction(&_quad, "loadQuad", [], [quadType]);
    library.addFunction(&_skybox, "loadSkybox", [], [skyboxType]);
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

private void _position2(GrCall call) {
    Instance3D instance = call.getForeign!Instance3D(0);
    GrObject position = call.getObject(1);
    instance.transform.position = vec3(position.getReal("x"), position.getReal("y"), position.getReal("z"));
}

private void _scale1(GrCall call) {
    Instance3D instance = call.getForeign!Instance3D(0);
    instance.transform.position = vec3(call.getReal(1), call.getReal(2), call.getReal(3));
}

private void _scale2(GrCall call) {
    Instance3D instance = call.getForeign!Instance3D(0);
    GrObject scale = call.getObject(1);
    instance.transform.scale = vec3(scale.getReal("x"), scale.getReal("y"), scale.getReal("z"));
}

private void _packInstanceMatrix(GrCall call) {
    GrObject positionObj = call.getObject(0);
    GrObject rotationObj = call.getObject(1);
    GrObject scaleObj = call.getObject(2);

    vec3 position = vec3(positionObj.getReal("x"), positionObj.getReal("y"), positionObj.getReal("z"));
    quat rotation = quat(rotationObj.getReal("w"), rotationObj.getReal("x"), rotationObj.getReal("y"), rotationObj.getReal("z"));
    vec3 scale = vec3(scaleObj.getReal("x"), scaleObj.getReal("y"), scaleObj.getReal("z"));
    mat4 instanceMatrix = combineModel(position, rotation, scale);

    MatWrapper wrapper = new MatWrapper(instanceMatrix);
    call.setForeign(wrapper);
}

private void _light(GrCall call) {
    LightInstance lightInstance = new LightInstance(call.getEnum!LightType(0));
    call.setForeign(lightInstance);
    setGlobalLight(lightInstance);
}

private void _model1(GrCall call) {
    ModelInstance modelInstance = new ModelInstance(call.getString(0));
    call.setForeign(modelInstance);
    addEntity(modelInstance);
}

private void _model2(GrCall call) { 
    const GrArray!MatWrapper grMat4Array = call.getArray!MatWrapper(2);
    const MatWrapper[] mat4Array = grMat4Array.data;

    mat4[] matrices;
    foreach (const MatWrapper matWrapper; mat4Array) {
        matrices ~= matWrapper.matrix;
    }

    ModelInstance modelInstance = new ModelInstance(call.getString(0), call.getInt32(1), matrices);
    call.setForeign(modelInstance);
    addEntity(modelInstance);
}

private void _quad(GrCall call) {
    QuadInstance quadInstance = new QuadInstance();
    call.setForeign(quadInstance);
    addEntity(quadInstance);
}

private void _skybox(GrCall call) {
    Skybox skybox = new Skybox(getCamera());
    call.setForeign(skybox);
    setSkybox(skybox);
}
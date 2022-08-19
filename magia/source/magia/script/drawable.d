module magia.script.drawable;

import grimoire;

import gl3n.linalg;

import magia.core, magia.render, magia.shape;

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
    GrType lineType = library.addForeign("Line", [], "Entity");
    GrType quadType = library.addForeign("Quad", [], "Entity");
    GrType sphereType = library.addForeign("Sphere", [], "Entity");
    GrType skyboxType = library.addForeign("Skybox", [], "Entity");
    GrType terrainType = library.addForeign("Terrain", [], "Entity");

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
    library.addFunction(&_sphere, "loadSphere", [grInt, grReal, vec3Type, grInt, grReal, grReal, grReal, grReal], [sphereType]);
    library.addFunction(&_line, "loadLine", [vec3Type, vec3Type, vec3Type], [lineType]);
    library.addFunction(&_skybox, "loadSkybox", [], [skyboxType]);
    library.addFunction(&_terrain, "loadTerrain", [grInt, grInt, grInt, grInt, grInt, grInt], [terrainType]);
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

private void _line(GrCall call) {
    GrObject startObj = call.getObject(0);
    GrObject endObj = call.getObject(1);
    GrObject colorObj = call.getObject(2);

    const vec3 start = vec3(startObj.getReal("x"), startObj.getReal("y"), startObj.getReal("z"));
    const vec3 end = vec3(endObj.getReal("x"), endObj.getReal("y"), endObj.getReal("z"));
    const vec3 color = vec3(colorObj.getReal("x"), colorObj.getReal("y"), colorObj.getReal("z"));

    Line line = new Line(start, end, color);
    call.setForeign(line);
    addLine(line);
}

private void _quad(GrCall call) {
    QuadInstance quadInstance = new QuadInstance();
    call.setForeign(quadInstance);
    addEntity(quadInstance);
}

private void _sphere(GrCall call) {
    const int resolution = call.getInt32(0);
    const float radius = call.getReal(1);

    GrObject offset = call.getObject(2);
    const vec3 noiseOffset = vec3(offset.getReal("x"), offset.getReal("y"), offset.getReal("z"));

    const int nbLayers = call.getInt32(3);
    const float strength = call.getReal(4);
    const float roughness = call.getReal(5);
    const float persistence = call.getReal(6);
    const float minHeight = call.getReal(7);

    Sphere sphere = new Sphere(resolution, radius, noiseOffset, nbLayers, strength, roughness, persistence, minHeight);
    call.setForeign(sphere);
    addEntity(sphere);
}

private void _skybox(GrCall call) {
    Skybox skybox = new Skybox(getCamera());
    call.setForeign(skybox);
    setSkybox(skybox);
}

private void _terrain(GrCall call) {
    const int gridX = call.getInt32(0);
    const int gridZ = call.getInt32(1);
    const int sizeX = call.getInt32(2);
    const int sizeZ = call.getInt32(3);
    const int nbVertices = call.getInt32(4);
    const int tiling = call.getInt32(5);

    Terrain terrain = new Terrain(vec2(gridX, gridZ), vec2(sizeX, sizeZ), nbVertices, tiling);
    call.setForeign(terrain);
    setTerrain(terrain);
}
module magia.shape.model;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.transform;
import magia.core.vec3;
import magia.render.entity;
import magia.render.model;
import magia.render.shader;
import magia.render.shadow;
import magia.render.window;
import magia.shape.light;

/// Instance of a **Model** to render
final class ModelInstance : Entity3D {
    private {
        Model _model;
    }

    /// Constructor
    this(string fileName, uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        transform = Transform.identity;
        _model = new Model(fileName, instances, instanceMatrices);
    }
    
    /// Render the model
    void draw(Shader shader) {
        _model.draw(shader, transform);
    }
}
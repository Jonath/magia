module magia.shape.model;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.instance;
import magia.core.transform;
import magia.core.vec3;
import magia.render.drawable;
import magia.render.model;
import magia.render.shader;
import magia.render.window;
import magia.shape.light;

/// Packs a 3D object model and shader (@TODO defer load to another layer, so that we only load once even if several shaders are applied)
final class ModelGroup {
    private {
        Model _model;
        Shader _shader;
    }

    /// Constructor
    this(string fileName, uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        _model = new Model(fileName, instances, instanceMatrices);
        _shader = new Shader("default.vert", "default.frag");
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Setup light before a draw call
    void setupLight(LightInstance lightInstance) {
        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         lightInstance.color.x,
                                         lightInstance.color.y,
                                         lightInstance.color.z,
                                         lightInstance.color.w);
        glUniform3f(glGetUniformLocation(_shader.id, "lightPos"),
                                         lightInstance.transform.position.x,
                                         lightInstance.transform.position.y,
                                         lightInstance.transform.position.z);
    }

    /// Draw the model somewhere with its current shader parameters
    void draw(const Transform transform) {
        _model.draw(_shader, transform);
    }
}

/// Instance of a **Model** to render
final class ModelInstance : Instance3D, Drawable3D {
    private {
        ModelGroup _modelGroup;
        LightInstance _lightInstance;
    }

    /// Constructor
    this(ModelGroup modelGroup, LightInstance lightInstance) {
        transform = Transform.identity;
        _modelGroup = modelGroup;
        _lightInstance = lightInstance;
    }
    
    /// Render the model
    void draw() {
        _modelGroup.setupLight(_lightInstance);
        _modelGroup.draw(transform);
    }
}
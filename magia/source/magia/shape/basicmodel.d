module magia.shape.basicmodel;

import bindbc.opengl;

import magia.core.transform;
import magia.core.vec3;
import magia.render.drawable;
import magia.render.model;
import magia.render.shader;
import magia.render.window;
import magia.shape.light;

/// Renders a **Pyramid** with its own properties.
final class BasicModel : Drawable3D {
    private {
        Model _model;
        Shader _shader;
    }

    /// Constructor
    this(Light light, string fileName) {
        transform = Transform.identity;
        _model = new Model(fileName);
        _shader = new Shader("default.vert", "default.frag");

        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         light.color.x, light.color.y, light.color.z, light.color.w);
        glUniform3f(glGetUniformLocation(_shader.id, "lightPos"),
                                         light.transform.position.x, light.transform.position.y, light.transform.position.z);
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Render the model
    override void draw() {
        _model.draw(_shader);
    }
}
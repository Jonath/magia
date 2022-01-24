module magia.shape.basicmodel;

import bindbc.opengl;

import magia.core.vec3;
import magia.render.camera;
import magia.render.drawable;
import magia.render.light;
import magia.render.model;
import magia.render.shader;
import magia.render.window;

/// Renders a **Pyramid** with its own properties.
final class BasicModel : Drawable3D {
    private {
        Camera _camera;
        Shader _shader;
        Model _model;
    }

    /// Constructor
    this(Camera camera, Light light, string fileName) {
        _camera = camera;
        _shader = new Shader("default.vert", "default.frag");
        _model = new Model(fileName);

        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         light.color.x, light.color.y, light.color.z, light.color.w);
        glUniform3f(glGetUniformLocation(_shader.id, "lightPos"),
                                         light.position.x, light.position.y, light.position.z);
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Render the model
    override void draw() {
        _model.draw(_shader, _camera);
    }
}
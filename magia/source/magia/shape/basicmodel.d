module magia.shape.basicmodel;

import magia.core.vec3;
import magia.render.camera;
import magia.render.drawable;
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
    this(string fileName) {
        _camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));
        _shader = new Shader("default.vert", "default.frag");
        _model = new Model(fileName);
    }

    /// Render the model
    override void draw() {
        _model.draw(_shader, _camera);
    }
}
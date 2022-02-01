module magia.shape.skybox;

import magia.render.skybox;
import magia.scene.scene;
import magia.scene.entity;

/// Packs a skybox
final class SkyboxGroup {
    private {
        Skybox _skybox;
    }

    /// Constructor
    this() {
        _skybox = new Skybox(getCamera());
    }

    /// Render the skybox
    void draw() {
        _skybox.draw();
    }
}

/// Instance of a **Skybox** to render
final class SkyboxInstance : Entity3D {
    private {
        SkyboxGroup _skyboxGroup;
    }

    /// Constructor
    this(SkyboxGroup skyboxGroup) {
        _skyboxGroup = skyboxGroup;
    }
    
    /// Render the model
    void draw() {
        _skyboxGroup.draw();
    }
}
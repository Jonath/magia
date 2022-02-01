module magia.render.shadow;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.transform;
import magia.render.fbo;
import magia.render.mesh; // @TODO move renderable declaration
import magia.render.shader;
import magia.render.texture;
import magia.render.window;

/// Class holding shadow map data
class ShadowMap {
    private {
        uint _width;
        uint _height;
        
        FBO _FBO;
        Texture _texture;
        Shader _shader;
    }

    /// Initialize the shadow map
    this(vec3 lightPosition) {
        _width = 2048;
        _height = 2048;

        float size = 35.0f;
        float near = 0.1f;
        float far = 75.0f;

        _texture = new Texture(_width, _height);

        _FBO = new FBO();
        _FBO.attachTexture(_texture);
        _FBO.unbind();

        mat4 orthographicProjection = mat4.orthographic(-size, size, -size, size, near, far);
        mat4 lightView = mat4.look_at(lightPosition, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
        mat4 lightProjection = orthographicProjection * lightView;

        _shader = new Shader("shadow.vert", "shadow.frag");
        _shader.activate();
        glUniformMatrix4fv(glGetUniformLocation(_shader.id, "lightProjection"), 1, GL_FALSE, lightProjection.value_ptr);
    }

    /// Draw the shadows onto a given model/mesh
    void draw(Renderable renderable, Transform transform) {
        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, _width, _height);

        _FBO.bind();
        glClear(GL_DEPTH_BUFFER_BIT);
        renderable.draw(_shader, transform);
        _FBO.unbind();

        //resetViewport();
    }
}
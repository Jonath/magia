module magia.render.shadow;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.transform;
import magia.render.entity;
import magia.render.fbo;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.window;

/// Class holding shadow map data
class ShadowMap {
    private {
        uint _width;
        uint _height;

        FBO _FBO;
        Shader _shader;

        mat4 _lightProjection;
    }

    /// Initialize the shadow map
    this() {
        _width = 2048;
        _height = 2048;

        _FBO = new FBO(FBOType.Shadowmap, _width, _height);
        FBO.check("shadow");
        FBO.unbindRead();
        FBO.unbindDraw();
        FBO.unbind();

        _shader = new Shader("shadow.vert", "shadow.frag");
    }

    /// Save the shadows of each entity into an FBO
    void register(Entity3D[] _entities, vec3 lightPosition) {
        float size = 35.0f;
        float near = 0.1f;
        float far = 75.0f;

        mat4 orthographicProjection = mat4.orthographic(-size, size, -size, size, near, far);
        mat4 lightView = mat4.look_at(lightPosition, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
        _lightProjection = orthographicProjection * lightView;

        _shader.activate();
        glUniformMatrix4fv(glGetUniformLocation(_shader.id, "lightProjection"), 1, GL_FALSE, _lightProjection.value_ptr);

        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, _width, _height);

        _FBO.bind();
        glClear(GL_DEPTH_BUFFER_BIT);

        foreach(entity; _entities) {
            entity.draw(_shader);
        }

        glDrawArrays(GL_TRIANGLES, 0, 6);
        FBO.unbind();
        resetViewport();
    }

    void bind(Shader shader) {
        shader.activate();
        glUniformMatrix4fv(glGetUniformLocation(shader.id, "lightProjection"), 1, GL_FALSE, _lightProjection.value_ptr);

        GLuint slot = 2;
        _FBO.bindTexture(slot);
        glUniform1i(glGetUniformLocation(shader.id, "shadowMap"), slot);
    }

    void clear() {
        glEnable(GL_DEPTH_TEST);
        glViewport(0, 0, _width, _height);

        _FBO.bind();
        glClear(GL_DEPTH_BUFFER_BIT);
        FBO.unbind();
        resetViewport();
    }
}
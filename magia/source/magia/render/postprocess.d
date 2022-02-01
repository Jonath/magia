module magia.render.postprocess;

import bindbc.opengl;

import magia.render.shader;
import magia.render.vao;
import magia.render.vbo;
import magia.render.fbo;
import magia.render.rbo;

class PostProcess {
    private {
        VAO _VAO;
        FBO _FBO;
        Shader _shader;
    }

    this(uint width, uint height) {
        float[] rectangleVertices = [
            // Coords     // Texture coords
            1.0f, -1.0f,    1.0f, 0.0f,
            -1.0f, -1.0f,    0.0f, 0.0f,
            -1.0f,  1.0f,    0.0f, 1.0f,

            1.0f,  1.0f,    1.0f, 1.0f,
            1.0f, -1.0f,    1.0f, 0.0f,
            -1.0f,  1.0f,    0.0f, 1.0f,
        ];

        VBO VBO_ = new VBO(rectangleVertices);

        _VAO = new VAO();
        _VAO.linkAttributes(VBO_, 0, 2, GL_FLOAT, 4 * float.sizeof, null);
        _VAO.linkAttributes(VBO_, 1, 2, GL_FLOAT, 4 * float.sizeof, cast(void*)(2 * float.sizeof));

        _FBO = new FBO(width, height);
        RBO RBO_ = new RBO(width, height);
        RBO_.attachFBO();
        _FBO.unbind();

        _shader = new Shader("postprocess.vert", "postprocess.frag");
        _shader.activate();
        glUniform1i(glGetUniformLocation(_FBO.id, "screenTexture"), 0);
    }

    void prepare() {
        _FBO.bind();
        glEnable(GL_DEPTH_TEST);
        _FBO.unbind();
    }

    void draw() {
        _shader.activate();
        _VAO.bind();
        glDisable(GL_DEPTH_TEST);
        _FBO.bindTexture();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}
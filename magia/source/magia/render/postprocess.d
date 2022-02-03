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

        _shader = new Shader("postprocess.vert", "postprocess.frag");
        _shader.activate();
        glUniform1i(glGetUniformLocation(_shader.id, "screenTexture"), 0);

        _VAO = new VAO();
        _VAO.bind();

        VBO VBO_ = new VBO(rectangleVertices);

        _VAO.linkAttributes(VBO_, 0, 2, GL_FLOAT, 4 * float.sizeof, null);
        _VAO.linkAttributes(VBO_, 1, 2, GL_FLOAT, 4 * float.sizeof, cast(void*)(2 * float.sizeof));

        _FBO = new FBO(FBOType.Postprocess, width, height);
        RBO RBO_ = new RBO(width, height);
        RBO_.attachFBO();
        _FBO.unbind();
    }

    void prepare() {
        // Bind frame buffer
        _FBO.bind();

        // Clear back buffer and depth buffer
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Enable depth testing
        glEnable(GL_DEPTH_TEST);
    }

    void draw() {
        // Unbind frame buffer
        _FBO.unbind();

        // Draw the frame buffer rectangle
        _shader.activate();
        _VAO.bind();
        glDisable(GL_DEPTH_TEST); // Prevents the frame buffer from being discarded
        _FBO.bindTexture();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}
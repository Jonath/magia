module magia.render.postprocess;

import std.math;
import bindbc.opengl;

import magia.core.color;
import magia.render.shader;
import magia.render.vao;
import magia.render.vbo;
import magia.render.fbo;
import magia.render.rbo;

// Controls the gamma function
static float gamma = 2.2f;

// Background color
static Color bgColor = Color(.08f, .10f, .13f);

// Number of samples
static uint nbSamples = 8;

class PostProcess {
    private {
        uint _width;
        uint _height;

        VAO _VAO;
        FBO _postProcessFBO;
        FBO _multiSampleFBO;
        Shader _shader;
    }

    this(uint width, uint height) {
        _width = width;
        _height = height;

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
        glUniform1f(glGetUniformLocation(_shader.id, "gamma"), gamma);

        _VAO = new VAO();
        _VAO.bind();

        VBO VBO_ = new VBO(rectangleVertices);

        _VAO.linkAttributes(VBO_, 0, 2, GL_FLOAT, 4 * float.sizeof, null);
        _VAO.linkAttributes(VBO_, 1, 2, GL_FLOAT, 4 * float.sizeof, cast(void*)(2 * float.sizeof));

        _multiSampleFBO = new FBO(FBOType.Multisample, _width, _height, nbSamples);
        RBO RBO_ = new RBO(_width, _height, nbSamples);
        RBO_.attachFBO();
        FBO.check("multisample");

        _postProcessFBO = new FBO(FBOType.Postprocess, _width, _height);
        FBO.check("postprocess");
    }

    void prepare() {
        // Bind frame buffer
        _multiSampleFBO.bind();

        // Adjust clear color depending on gamma
	    glClearColor(pow(bgColor.r, gamma), pow(bgColor.g, gamma), pow(bgColor.b, gamma), 1.0f);

        // Clear back buffer and depth buffer
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Enable depth testing
        glEnable(GL_DEPTH_TEST);
    }

    void draw() {
        // Make it so the multisampling FBO is read while the post-processing FBO is drawn
        _multiSampleFBO.bindRead();
        _postProcessFBO.bindDraw();

        // Conclude the multisampling and copy it to the post-processing FBO
        FBO.blit(_width, _height);

        // Unbind frame buffer
        FBO.unbind();

        // Draw the frame buffer rectangle
        _shader.activate();
        _VAO.bind();
        glDisable(GL_DEPTH_TEST); // Prevents the frame buffer from being discarded
        _postProcessFBO.bindTexture();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}
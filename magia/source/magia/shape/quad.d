module magia.shape.quad;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;
import magia.render.window, magia.render.drawable, magia.render.camera;
import magia.render.vao, magia.render.vbo, magia.render.ebo, magia.render.shader, magia.render.texture;

/// Renders a **Quad** with its own properties.
/*final class Quad : Drawable {
    private {
        VAO _VAO, _lightVAO;
        VBO _VBO, _lightVBO;
        EBO _EBO, _lightEBO;

        Camera  _camera;
        Shader  _shaderProgram, _lightShader;
        Texture _texture, _specularTexture;
        GLuint  _scaleId;

        GLuint[] _indices, _lightIndices;

        mat4 _lightModel;

        float _rotation;
    }

    /// Constructor
    this() {
        _shaderProgram = new Shader("default.vert", "default.frag");

        // Quad vertices
        GLfloat[] vertices = [
            //     COORDINATES     /        COLORS        /    TexCoord    /       NORMALS     //
	        -1.0f, 0.0f,  1.0f,		0.0f, 0.0f, 0.0f,		0.0f, 0.0f,		0.0f, 1.0f, 0.0f,
	        -1.0f, 0.0f, -1.0f,		0.0f, 0.0f, 0.0f,		0.0f, 1.0f,		0.0f, 1.0f, 0.0f,
	         1.0f, 0.0f, -1.0f,		0.0f, 0.0f, 0.0f,		1.0f, 1.0f,		0.0f, 1.0f, 0.0f,
	         1.0f, 0.0f,  1.0f,		0.0f, 0.0f, 0.0f,		1.0f, 0.0f,		0.0f, 1.0f, 0.0f
        ];

        // Quad indices
        _indices = [
            0, 1, 2,
            0, 2, 3
        ];

        // Quad light vertices
        GLfloat[] lightVertices = [
            //  COORDINATES
            -0.1f, -0.1f,  0.1f,
            -0.1f, -0.1f, -0.1f,
             0.1f, -0.1f, -0.1f,
             0.1f, -0.1f,  0.1f,
            -0.1f,  0.1f,  0.1f,
            -0.1f,  0.1f, -0.1f,
             0.1f,  0.1f, -0.1f,
             0.1f,  0.1f,  0.1f
        ];

        // Quad light indices
        _lightIndices = [
            0, 1, 2,
            0, 2, 3,
            0, 4, 7,
            0, 7, 3,
            3, 7, 6,
            3, 6, 2,
            2, 6, 5,
            2, 5, 1,
            1, 5, 4,
            1, 4, 0,
            4, 5, 6,
            4, 6, 7
        ];

        _VAO = new VAO();
        _VAO.bind();

        _VBO = new VBO(vertices);
        _EBO = new EBO(_indices);

        _VAO.linkAttributes(_VBO, 0, 3, GL_FLOAT, 11 * float.sizeof, null);
        _VAO.linkAttributes(_VBO, 1, 3, GL_FLOAT, 11 * float.sizeof, cast(void *)(3 * float.sizeof));
        _VAO.linkAttributes(_VBO, 2, 2, GL_FLOAT, 11 * float.sizeof, cast(void *)(6 * float.sizeof));
        _VAO.linkAttributes(_VBO, 3, 3, GL_FLOAT, 11 * float.sizeof, cast(void *)(8 * float.sizeof));

        _VBO.unbind();
        _VAO.unbind();
        _EBO.unbind();

        _lightShader = new Shader("light.vert", "light.frag");

        _lightVAO = new VAO();
        _lightVAO.bind();

        _lightVBO = new VBO(lightVertices);
        _lightEBO = new EBO(_lightIndices);

        _lightVAO.linkAttributes(_lightVBO, 0, 3, GL_FLOAT, 3 * float.sizeof, null);

        _lightVAO.unbind();
        _lightVBO.unbind();
        _lightEBO.unbind();

        vec4 lightColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        vec3 lightPos = vec3(0.5f, 0.5f, 0.5f);
        _lightModel = mat4.identity;
        _lightModel = _lightModel.translate(lightPos);

        vec3 quadPos = vec3(0.0f, 0.0f, 0.0f);
	    mat4 quadModel = mat4.identity;
	    quadModel = quadModel.translate(quadPos);

        _lightShader.activate();
        glUniformMatrix4fv(glGetUniformLocation(_lightShader.id, "model"), 1, GL_TRUE, _lightModel.value_ptr);
        glUniform4f(glGetUniformLocation(_lightShader.id, "lightColor"),
                                         lightColor.x, lightColor.y, lightColor.z, lightColor.w);

        _shaderProgram.activate();
        glUniformMatrix4fv(glGetUniformLocation(_shaderProgram.id, "model"), 1, GL_TRUE, quadModel.value_ptr);
        glUniform4f(glGetUniformLocation(_shaderProgram.id, "lightColor"),
                                         lightColor.x, lightColor.y, lightColor.z, lightColor.w);
        glUniform3f(glGetUniformLocation(_shaderProgram.id, "lightPos"),
                                         lightPos.x, lightPos.y, lightPos.z);

        _camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));

        _texture = new Texture("planks.png", GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE);
        _texture.forwardToShader(_shaderProgram, "tex0", 0);

        _specularTexture = new Texture("planksSpec.png", GL_TEXTURE_2D, 1, GL_RED, GL_UNSIGNED_BYTE);
        _specularTexture.forwardToShader(_shaderProgram, "tex1", 1);
    }

    /// Unload
    void unload() {
        _VAO.remove();
        _VBO.remove();
        _EBO.remove();
        _lightVAO.remove();
        _lightVBO.remove();
        _lightEBO.remove();
        _texture.remove();
        _specularTexture.remove();
        _shaderProgram.remove();
        _lightShader.remove();
    }

    /// Render the quad
    override void draw(const Vec2f position) {
        _camera.processInputs();
        _camera.updateMatrix(45f, 0.1f, 100f);

        _shaderProgram.activate();
        _camera.passToShader(_shaderProgram, "camMatrix");
        glUniform3f(glGetUniformLocation(_shaderProgram.id, "camPos"),
                    _camera.position.x, _camera.position.x, _camera.position.z);

        glUniform1f(_scaleId, 1f);
        _texture.bind();
        _specularTexture.bind();
        _VAO.bind();
        glDrawElements(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null);

        _lightShader.activate();
        _camera.passToShader(_lightShader, "camMatrix");
        _lightVAO.bind();
        glDrawElements(GL_TRIANGLES, cast(int) _lightIndices.length, GL_UNSIGNED_INT, null);
    }
}*/
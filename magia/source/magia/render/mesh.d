module magia.render.mesh;

import std.conv;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.transform;
import magia.render.vao;
import magia.render.vbo;
import magia.render.ebo;
import magia.render.camera;
import magia.render.texture;
import magia.render.scene;
import magia.render.shader;
import magia.render.vertex;

/// Interface for renderable objects
interface Renderable {
    /// Render on screen
    void draw(Shader shader, Transform transform);
}

/// Class handling mesh data and draw call
final class Mesh : Renderable {
    private {
        Vertex[] _vertices;
        GLuint[] _indices;
        Texture[] _textures;

        VAO _VAO;
        VBO _VBO;
        EBO _EBO;

        uint _instances;
        VBO _instanceVBO;

        bool _traceDeep = false;
    }

    /// Constructor
    this(Vertex[] vertices, GLuint[] indices, Texture[] textures = null,
         uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        _vertices = vertices;
        _indices = indices;
        _instances = instances;

        if (textures) {
            _textures = textures;
        }

        // Generate and bind VAO
        _VAO = new VAO();
        _VAO.bind();

        // Transpose all matrices to pass them onto the VAO properly
        for (int i = 0; i < instanceMatrices.length; ++i) {
            instanceMatrices[i].transpose();
        }

        // Generate VBOs
        _instanceVBO = new VBO(instanceMatrices);
        _VBO = new VBO(_vertices);

        // Generate EBO
        _EBO = new EBO(_indices);

        // Link main VBO attributes
        _VAO.linkAttributes(_VBO, 0, 3, GL_FLOAT, Vertex.sizeof, null);
        _VAO.linkAttributes(_VBO, 1, 3, GL_FLOAT, Vertex.sizeof, cast(void*)(3 * float.sizeof));
        _VAO.linkAttributes(_VBO, 2, 3, GL_FLOAT, Vertex.sizeof, cast(void*)(6 * float.sizeof));
        _VAO.linkAttributes(_VBO, 3, 2, GL_FLOAT, Vertex.sizeof, cast(void*)(9 * float.sizeof));

        // Link instance VBO attributes
        _VAO.linkAttributes(_instanceVBO, 4, 4, GL_FLOAT, mat4.sizeof, null);
        _VAO.linkAttributes(_instanceVBO, 5, 4, GL_FLOAT, mat4.sizeof, cast(void*)(1 * vec4.sizeof));
        _VAO.linkAttributes(_instanceVBO, 6, 4, GL_FLOAT, mat4.sizeof, cast(void*)(2 * vec4.sizeof));
        _VAO.linkAttributes(_instanceVBO, 7, 4, GL_FLOAT, mat4.sizeof, cast(void*)(3 * vec4.sizeof));
        glVertexAttribDivisor(4, 1);
        glVertexAttribDivisor(5, 1);
        glVertexAttribDivisor(6, 1);
        glVertexAttribDivisor(7, 1);

        // Unbind all objects
        VAO.unbind();
        VBO.unbind();
        EBO.unbind();
    }

    /// Draw call
    void draw(Shader shader, Transform transform = Transform.identity) {
        shader.activate();
        _VAO.bind();

        uint nbDiffuseTextures = 0;
        uint nbSpecularTextures = 0;

        uint textureId = 0;
        foreach (Texture texture; _textures) {
            const string type = texture.type;

            uint num;
            if (type == "diffuse") {
                ++nbDiffuseTextures;
                num = nbDiffuseTextures;
            }
            else if ("specular") {
                ++nbSpecularTextures;
                num = nbSpecularTextures;
            }

            texture.forwardToShader(shader, type ~ to!string(num), textureId);
            texture.bind();
            ++textureId;
        }

        Camera camera = getCamera();
        glUniform3f(glGetUniformLocation(shader.id, "camPos"),
            camera.position.x, camera.position.x, camera.position.z);
        camera.passToShader(shader, "camMatrix");

        if (_instances == 1) {
            mat4 localTranslation = mat4.identity;
            mat4 localRotation = mat4.identity;
            mat4 localScale = mat4.identity;

            if (_traceDeep) {
                writeln("Position: ", transform.position);
                writeln("Rotation: ", transform.rotation);
                writeln("Scale: ", transform.scale);
                writeln("Model: ", transform.model);
            }

            localTranslation = localTranslation.translate(transform.position);
            localRotation = transform.rotation.to_matrix!(4, 4);
            localScale[0][0] = transform.scale.x;
            localScale[1][1] = transform.scale.y;
            localScale[2][2] = transform.scale.z;

            glUniformMatrix4fv(glGetUniformLocation(shader.id, "translation"), 1, GL_TRUE, localTranslation.value_ptr);
            glUniformMatrix4fv(glGetUniformLocation(shader.id, "rotation"), 1, GL_TRUE, localRotation.value_ptr);
            glUniformMatrix4fv(glGetUniformLocation(shader.id, "scale"), 1, GL_TRUE, localScale.value_ptr);
            glUniformMatrix4fv(glGetUniformLocation(shader.id, "model"), 1, GL_TRUE, transform.model.value_ptr);

            glDrawElements(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null);
        } else {
            glUniformMatrix4fv(glGetUniformLocation(shader.id, "model"), 1, GL_TRUE, mat4.identity.value_ptr);
            glDrawElementsInstanced(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null, _instances);
        }
    }
}

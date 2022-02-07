module magia.shape.light;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.transform;
import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;

enum LightType {
    DIRECTIONAL,
    POINT,
    SPOT
}

/// Instance of light
final class LightInstance : Entity3D {
    private {
        Mesh _mesh;
        vec4 _color;
        LightType _lightType;
    }

    @property {
        /// Gets color
        vec4 color() {
            return _color;
        }
    }

    /// Constructor
    this(LightType lightType) {
        _lightType = lightType;
        transform = Transform.identity;

        // Quad light vertices
        Vertex[] vertices = [
            //  COORDINATES
            Vertex(vec3(-0.01f, -0.01f,  0.1f)),
            Vertex(vec3(-0.01f, -0.01f, -0.01f)),
            Vertex(vec3( 0.1f, -0.01f, -0.01f)),
            Vertex(vec3( 0.1f, -0.01f,  0.1f)),
            Vertex(vec3(-0.01f,  0.1f,  0.1f)),
            Vertex(vec3(-0.01f,  0.1f, -0.01f)),
            Vertex(vec3( 0.1f,  0.1f, -0.01f)),
            Vertex(vec3( 0.1f,  0.1f,  0.1f))
        ];

        // Quad light indices
        GLuint[] indices = [
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

        _mesh = new Mesh(vertices, indices);
        _color = vec4(1.0f, 1.0f, 1.0f, 1.0f);
    }

    /// Setup light casting and receiving shaders
    void setupShaders(Shader lightShader, Shader materialShader) {
        lightShader.activate();
        glUniform4f(glGetUniformLocation(lightShader.id, "lightColor"),
                                         _color.x, _color.y, _color.z, _color.w);

        materialShader.activate();
        glUniform1i(glGetUniformLocation(materialShader.id, "lightType"), cast(int)_lightType);
        glUniform4f(glGetUniformLocation(materialShader.id, "lightColor"),
                                         _color.x, _color.y, _color.z, _color.w);
        glUniform3f(glGetUniformLocation(materialShader.id, "lightPos"),
                                         transform.position.x, transform.position.y, transform.position.z);
    }

    /// Render the light object (for debug)
    void draw(Shader shader) {
        _mesh.draw(shader, transform);
    }
}

/// @TODO decorate LightInstance with type (directional, cone, point)
module magia.shape.light;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.transform;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;
import magia.scene.entity;

/// Packs a light cube, its shader and its color
final class LightGroup {
    private {
        Mesh _mesh;
        Shader _shader;
        vec4 _color;
    }

    @property {
        /// Gets color
        vec4 color() {
            return _color;
        }
    }

    /// Constructor
    this() {
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
        _shader = new Shader("light.vert", "light.frag");
        _color = vec4(1.0f, 1.0f, 1.0f, 1.0f);

        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         _color.x, _color.y, _color.z, _color.w);
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Render the quad
    void draw(const Transform transform) {
        _mesh.draw(_shader, transform);
    }
}

/// Instance of light
final class LightInstance : Entity3D {
    private {
        LightGroup _lightGroup;
    }

    @property {
        /// Gets color
        vec4 color() {
            return _lightGroup.color;
        }
    }

    /// Constructor
    this(LightGroup lightGroup) {
        transform = Transform.identity;
        _lightGroup = lightGroup;
    }

    /// Render the light
    void draw() {
        _lightGroup.draw(transform);
    }
}

/// @TODO decorate lightInstance with type (directional, cone, point)
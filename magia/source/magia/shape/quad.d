module magia.shape.quad;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;
import magia.shape.light;
import magia.scene.entity;

/// Packs a quad mesh and shader
final class QuadGroup {
    private {
        Mesh _mesh;
        Shader _shader;
    }

    /// Constructor
    this() {
        // Quad vertices
        Vertex[] vertices = [
            //     COORDINATES                /     NORMALS         /    COLORS        /    TexCoord   //
	        Vertex(vec3(-1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(0.0f, 0.0f)),
	        Vertex(vec3(-1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(0.0f, 1.0f)),
	        Vertex(vec3( 1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(1.0f, 1.0f)),
	        Vertex(vec3( 1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(1.0f, 0.0f))
        ];

        // Quad indices
        GLuint[] indices = [
            0, 1, 2,
            0, 2, 3
        ];

        string pathPrefix = "assets/texture/";

        Texture[] textures = [
            new Texture(pathPrefix ~ "planks.png", "diffuse", 0),
            new Texture(pathPrefix ~ "planksSpec.png", "specular", 1)
        ];

        _mesh = new Mesh(vertices, indices, textures);
        _shader = new Shader("default.vert", "default.frag");
    }

    /// Setup light before a draw call
    void setupLight(LightInstance lightInstance) {
        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         lightInstance.color.x,
                                         lightInstance.color.y,
                                         lightInstance.color.z,
                                         lightInstance.color.w);
        glUniform3f(glGetUniformLocation(_shader.id, "lightPos"),
                                         lightInstance.transform.position.x,
                                         lightInstance.transform.position.y,
                                         lightInstance.transform.position.z);
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

/// Instance of quad
final class QuadInstance : Entity3D {
    private {
        QuadGroup _quadGroup;
        LightInstance _lightInstance;
    }

    /// Constructor
    this(QuadGroup quadGroup, LightInstance lightInstance) {
        transform = Transform.identity;
        _quadGroup = quadGroup;
        _lightInstance = lightInstance;
    }

    /// Render the light
    void draw() {
        _quadGroup.setupLight(_lightInstance);
        _quadGroup.draw(transform);
    }
}
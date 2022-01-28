module magia.shape.quad;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.drawable;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;
import magia.shape.light;

/// Renders a **Quad** with its own properties.
final class Quad : Drawable3D {
    private {
        Mesh _mesh;
        Shader _shader;
    }

    /// Constructor
    this(Light light) {
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

        transform = Transform.identity;
        _mesh = new Mesh(vertices, indices, textures);
        _shader = new Shader("default.vert", "default.frag");

        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         light.color.x, light.color.y, light.color.z, light.color.w);
        glUniform3f(glGetUniformLocation(_shader.id, "lightPos"),
                                         light.transform.position.x, light.transform.position.y, light.transform.position.z);
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Render the quad
    override void draw() {
        _mesh.draw(_shader, transform);
    }
}
module magia.shape.line;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.entity;
import magia.render.shader;
import magia.render.vao;
import magia.render.vbo;

class Line : Entity3D {
    VAO _VAO;
    VBO _VBO;

    vec3 _start;
    vec3 _end;
    vec3 _color;

    this(vec3 start, vec3 end, vec3 color) {
        transform = Transform.identity;

        vec3[] vertices;
        vertices ~= start;
        vertices ~= end;

        _color = color;

        _VAO = new VAO();
        _VAO.bind();

        _VBO = new VBO(vertices);

        _VAO.linkAttributes(_VBO, 0, 3, GL_FLOAT, vec3.sizeof, null);
    }

    void draw(Shader shader) {
        shader.activate();
        _VAO.bind();

        glUniformMatrix4fv(glGetUniformLocation(shader.id, "model"), 1, GL_TRUE, transform.model.value_ptr);
        glUniform3fv(glGetUniformLocation(shader.id, "color"), 1, _color.value_ptr);
        glDrawArrays(GL_LINES, 0, 2);
    }
}
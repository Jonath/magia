module magia.ui.manager;

import std.string;
import bindbc.opengl, bindbc.sdl;
import gl3n.linalg;
import magia.core, magia.render;

private {
    UIElement[] _roots;
}

private {
    
    GLuint _shaderProgram, _vertShader, _fragShader;
    GLuint _vao;
    GLint _sizeUniform, _positionUniform, _colorUniform, _modelUniform;
}

void initUI() {
    // Vertices
    immutable float[] points = [
        1f, 1f, -1f, 1f, 1f, -1f, -1f, -1f
        //1f, 1f, 0f, 1f, 1f, 0f, 0f, 0f
    ];

    GLuint vbo = 0;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);

    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
    glEnableVertexAttribArray(0);

    immutable char* vshader = toStringz("
        #version 400
        in vec2 vp;
        out vec2 st;
        uniform vec2 size;
        uniform vec2 position;

        uniform mat4 model;
        void main() {
            st = vp;//(vp + 1.0) * 0.5;
            gl_Position = model * vec4(vp, 0.0, 1.0);
            //gl_Position = vec4((position + (st * size)) * 2.0 - 1.0, 0.0, 1.0);
        }
        ");

    immutable char* fshader = toStringz("
        #version 400
        in vec2 st;
        out vec4 frag_color;
        uniform vec4 color;
        void main() {
            frag_color = color;
            if(frag_color.a == 0.0)
                discard;
        }
        ");

    _vertShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(_vertShader, 1, &vshader, null);
    glCompileShader(_vertShader);
    _fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(_fragShader, 1, &fshader, null);
    glCompileShader(_fragShader);

    _shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, _fragShader);
    glAttachShader(_shaderProgram, _vertShader);
    glLinkProgram(_shaderProgram);
    _sizeUniform = glGetUniformLocation(_shaderProgram, "size");
    _positionUniform = glGetUniformLocation(_shaderProgram, "position");
    _colorUniform = glGetUniformLocation(_shaderProgram, "color");
    _modelUniform = glGetUniformLocation(_shaderProgram, "model");
}

void drawUI() {
    mat4 model = mat4.identity;
    mat4 a = mat4.identity;
    mat4 b = mat4.identity;
    a.translate(-1f, -1f, 0.0f);
    b.scale(1f / screenSize().x, 1f / screenSize().y, 1.0f);
    model = a * b;

    drawFilledRect(Vec2f(10f, 200f), Vec2f(100f, 150f), Color.blue, 1f);
    drawTest(model, 10f, 200f, 100f, 150f);

    //import magia.render.text;
    //drawText("HEllo World", 0f, 0f);
}

abstract class UIElement {
    private {
        UIElement[] _children;
    }

    void draw();
}
/*
final class TestUI : UIElement {
    override void draw() {
        drawTest();
    }
}*/


void drawTest(mat4 model, float x, float y, float w, float h) {

    import std.stdio;

    setShaderProgram(_shaderProgram);

    Vec2f origin = Vec2f(x, y);
    Vec2f size = Vec2f(w, h);

    //writeln(size, " -> ", size / screenSize());
    origin = origin / screenSize();
    size = size / screenSize();

    glUniform2f(_sizeUniform, size.x, size.y);
    glUniform2f(_positionUniform, origin.x, origin.y);
    mat4 a = mat4.identity;
    mat4 b = mat4.identity;
    a.translate(x * 2 + w, y * 2 + h, 0f);
    b.scale(w, h, 1f);
    model = model * a * b;

    glUniform4f(_colorUniform, 1f, 0f, 0f, 1f);
    glUniformMatrix4fv(_modelUniform, 1, GL_TRUE, model.value_ptr);

    glBindVertexArray(_vao);

    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ZERO, GL_ONE);
    glBlendEquation(GL_FUNC_ADD);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
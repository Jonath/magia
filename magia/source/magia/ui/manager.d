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
    GLint _colorUniform, _modelUniform;
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
    _colorUniform = glGetUniformLocation(_shaderProgram, "color");
    _modelUniform = glGetUniformLocation(_shaderProgram, "model");

    auto t = new TestUI();
    t._children ~= new Test2UI();
    appendRoot(t);
}

void drawUI() {
    mat4 transform = mat4.identity;
    mat4 a = mat4.identity;
    mat4 b = mat4.identity;
    a.translate(-1f, -1f, 0.0f);
    b.scale(1f / screenSize().x, 1f / screenSize().y, 1.0f);
    transform = a * b;

    /*drawFilledRect(Vec2f(10f, 200f), Vec2f(100f, 150f), Color.blue, 1f);*/
    //drawTest(transform, 10f, 200f, 400f, 400f);

    //import magia.render.text;
    //drawText("HEllo World", 0f, 0f);

    foreach (UIElement element; _roots) {
        drawUI(transform, element);
    }
}

void appendRoot(UIElement element) {
    _roots ~= element;
}

private void drawUI(mat4 transform, UIElement element, UIElement parent = null) {
    mat4 local = mat4.identity;

    local.scale(element.scaleX, element.scaleY, 1f);
    local.translate(-element.w * element.scaleX, -element.h * element.scaleY, 0f);
    if(element.angle)
        local.rotatez(element.angle);
    local.translate(element.w * element.scaleX, element.h * element.scaleY, 0f);
    local.translate(element.x * 2f, element.y * 2f, 0f);
    transform = transform * local;
    
    element.draw(transform);
    foreach (UIElement child; element._children) {
        drawUI(transform, child, element);
    }
}

abstract class UIElement {
    private {
        UIElement[] _children;
        float x = 0f, y = 0f, w = 0f, h = 0f, scaleX = 1f, scaleY = 1f;
        float angle = 0f;
    }

    void draw(mat4);
}

final class TestUI : UIElement {
    private {
    }
    this() {
        x = 400f;
        w = 400f;
        h = 400f;
        scaleX = .5f;
        angle = 90f * (PI / 180.0);
    }
    override void draw(mat4 transform) {
        //angle += .05f;
        drawTest(transform, 0f, 0f, w, h, Color.red);
        //drawTest(transform, 10f, 200f, 400f, 400f);
    }
}

final class Test2UI : UIElement {
    this() {
        x = 20f;
        y = 20f;
        w = 50f;
        h = 50f;
        //scaleX = 2f;
        //scaleY = 2f;
        angle = 90f;
    }
    override void draw(mat4 transform) {
        //angle += .05f;
        drawTest(transform, 10f, 10f, w, h, Color.green);
        //drawTest(transform, 10f, 200f, 400f, 400f);
    }
}


void drawTest(mat4 transform, float x, float y, float w, float h, Color color = Color.white) {
    setShaderProgram(_shaderProgram);

    mat4 local = mat4.identity;
    local.scale(w, h, 1f);
    local.translate(x * 2 + w, y * 2 + h, 0f);
    transform = transform * local;

    glUniform4f(_colorUniform, color.r, color.g, color.b, 1f);
    glUniformMatrix4fv(_modelUniform, 1, GL_TRUE, transform.value_ptr);

    glBindVertexArray(_vao);

    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ZERO, GL_ONE);
    glBlendEquation(GL_FUNC_ADD);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
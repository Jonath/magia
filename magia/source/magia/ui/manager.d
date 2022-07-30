module magia.ui.manager;

import std.string;
import bindbc.opengl, bindbc.sdl;
import magia.core, magia.render;
import magia.ui.element;

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
            st = vp;
            gl_Position = model * vec4(vp, 0.0, 1.0);
        }");

    immutable char* fshader = toStringz("
        #version 400
        in vec2 st;
        out vec4 frag_color;
        uniform vec4 color;
        void main() {
            frag_color = color;
            if(frag_color.a == 0.0)
                discard;
        }");

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
    local.translate(
        -element.sizeX * element.scaleX * element.pivotX * 2f,
        -element.sizeY * element.scaleY * element.pivotY * 2f,
        0f);

    if (element.angle)
        local.rotatez(element.angle);

    local.translate(
        element.sizeX * element.scaleX * element.pivotX * 2f,
        element.sizeY * element.scaleY * element.pivotY * 2f,
        0f);

    float x, y;
    float parentW = parent ? parent.sizeX : screenWidth();
    float parentH = parent ? parent.sizeY : screenHeight();

    final switch (element.alignX) with (UIElement.AlignX) {
    case left:
        x = element.posX;
        break;
    case right:
        x = parentW - (element.posX + (element.sizeX * element.scaleX));
        break;
    case center:
        x = parentW / 2f + element.posX;
        break;
    }
    final switch (element.alignY) with (UIElement.AlignY) {
    case bottom:
        y = element.posY;
        break;
    case top:
        y = parentH - (element.posY + (element.sizeY * element.scaleY));
        break;
    case center:
        y = parentH / 2f + element.posY;
        break;
    }
    local.translate(x * 2f, y * 2f, 0f);
    transform = transform * local;

    element.draw(transform);
    foreach (UIElement child; element._children) {
        drawUI(transform, child, element);
    }
}

final class TestUI : UIElement {
    private {
    }
    this() {
        posX = 50f;
        posY = 50f;
        sizeX = 400f;
        sizeY = 400f;
        //scaleX = .5f;
        //angle = 90f * (PI / 180.0);
        //alignX = AlignX.right;
        //alignY = AlignY.top;

        import magia.ui.label;

        auto a = new Label;
        a.sizeX = 50f;
        a.sizeX = 50f;
        a.text = "Test de label !";
        _children ~= a;
    }

    override void draw(mat4 transform) {
        //angle += .05f;
        drawTest(transform, 0f, 0f, sizeX, sizeY, Color.red);
        //drawTest(transform, 10f, 200f, 400f, 400f);
        //drawText(transform, "HEllo World", 10f, 10f);
    }
}

final class Test2UI : UIElement {
    this() {
        posX = 20f;
        posY = 20f;
        sizeX = 50f;
        sizeY = 50f;
        scaleX = 2f;
        scaleY = 2f;
        //angle = 45f * (PI / 180.0);
        //alignX = AlignX.right;
        //alignY = AlignY.top;
    }

    override void draw(mat4 transform) {
        angle += .05f;
        drawTest(transform, 0f, 0f, sizeX, sizeY, Color.green);
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

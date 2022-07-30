module magia.ui.element;

import gl3n.linalg;

abstract class UIElement {
    public {
        UIElement[] _children;
    }

    float posX = 0f, posY = 0f;
    float sizeX = 0f, sizeY = 0f;
    float scaleX = 1f, scaleY = 1f;
    float pivotX = .5f, pivotY = .5f;
    float angle = 0f;

    AlignX alignX = AlignX.left;
    AlignY alignY = AlignY.top;

    enum AlignX {
        left,
        center,
        right
    }

    enum AlignY {
        top,
        center,
        bottom
    }

    void draw(mat4);
}

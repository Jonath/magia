module magia.ui.element;

import gl3n.linalg;
import magia.core;

abstract class UIElement {
    public {
        UIElement[] _children;
    }

    float posX = 0f, posY = 0f;
    float sizeX = 0f, sizeY = 0f;
    float pivotX = .5f, pivotY = .5f;

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

    AlignX alignX = AlignX.left;
    AlignY alignY = AlignY.top;

    // Transitions
    float offsetX = 0f, offsetY = 0f;
    float scaleX = 1f, scaleY = 1f;
    float alpha = 1f;
    float angle = 0f;

    static final class State {
        string name;
        float offsetX = 0f, offsetY = 0f;
        float scaleX = 1f, scaleY = 1f;
        float angle = 0f;
        float alpha = 1f;
        float time = 1f;
        Spline spline = Spline.linear;
    }

    State[string] states;
    string currentStateName;
    State initState, targetState;
    Timer timer;

    void draw(mat4);
}

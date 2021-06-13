module ui.gui_manager;

import std.conv : to;
import core, common, render;
import ui.gui_element;

private {
    bool _isGuiElementDebug = false;
    GuiElement[] _rootElements;
    float _deltaTime;
}

//-- Public ---

/// Add a gui as a top gui (not a child of anything).
void prependRoot(GuiElement gui) {
    _rootElements = gui ~ _rootElements;
}

/// Add a gui as a top gui (not a child of anything).
void appendRoot(GuiElement gui) {
    _rootElements ~= gui;
}

/// Remove all the top gui (that aren't a child of anything).
void removeRoots() {
    //_isChildGrabbed = false;
    _rootElements.length = 0uL;
}

/// Set those gui as the top guis (replacing the previous ones).
void setRoots(GuiElement[] widgets) {
    _rootElements = widgets;
}

/// Get all the root gui.
GuiElement[] getRoots() {
    return _rootElements;
}

/// Show every the hitbox of every gui element.
void setDebugGui(bool isDebug) {
    _isGuiElementDebug = isDebug;
}

/// Remove the specified gui from roots.
void removeRoot(GuiElement gui) {
    foreach (size_t i, GuiElement child; _rootElements) {
        if (child is gui) {
            removeRoot(i);
            return;
        }
    }
}

/// Remove the gui at the specified index from roots.
void removeRoot(size_t index) {
    if (!_rootElements.length)
        return;
    if (index + 1u == _rootElements.length)
        _rootElements.length--;
    else if (index == 0u)
        _rootElements = _rootElements[1 .. $];
    else
        _rootElements = _rootElements[0 .. index] ~ _rootElements[index + 1 .. $];
}

//-- Internal ---

/// Update all the guis from the root.
void updateRoots(float deltaTime) {
    _deltaTime = deltaTime;
    size_t index = 0;
    while (index < _rootElements.length) {
        if (_rootElements[index]._isRegistered) {
            updateRoots(_rootElements[index], null);
            index++;
        }
        else {
            removeRoot(index);
        }
    }
}

/// Draw all the guis from the root.
void drawRoots() {
    foreach_reverse (GuiElement widget; _rootElements) {
        drawRoots(widget);
    }
}

private {
    bool _hasClicked, _wasHoveredGuiElementAlreadyHovered;
    GuiElement _clickedGuiElement;
    GuiElement _focusedGuiElement;
    GuiElement _hoveredGuiElement;
    GuiElement _grabbedGuiElement, _tempGrabbedGuiElement;
    Canvas _canvas;
    Vec2f _clickedGuiElementEventPosition = Vec2f.zero;
    Vec2f _hoveredGuiElementEventPosition = Vec2f.zero;
    Vec2f _grabbedGuiElementEventPosition = Vec2f.zero;
    GuiElement[] _hookedGuis;
}

/// Dispatch global events on the guis from the root. \
/// Called by the main event loop.
void handleGuiElementEvent(Event event) {
    _hasClicked = false;
    switch (event.type) with (EventType) {
    case quit:
        dispatchQuitEvent(null);
        break;
    default:
        dispatchGenericEvents(null, event);
        break;
    }
}

/// Update all children of a gui. \
/// Called by the application itself.
void updateRoots(GuiElement gui, GuiElement parent) {
    Vec2f coords = Vec2f.zero;

    //Calculate transitions
    if (gui._timer.isRunning) {
        gui._timer.update(_deltaTime);
        const float t = gui._targetState.easing(gui._timer.value01);
        gui._currentState.offset = lerp(gui._initState.offset, gui._targetState.offset, t);

        gui._currentState.scale = lerp(gui._initState.scale, gui._targetState.scale, t);

        gui._currentState.color = lerp(gui._initState.color, gui._targetState.color, t);

        gui._currentState.alpha = lerp(gui._initState.alpha, gui._targetState.alpha, t);

        gui._currentState.angle = lerp(gui._initState.angle, gui._targetState.angle, t);
        gui.onColor();
        if (!gui._timer.isRunning) {
            if (gui._targetState.callback.length)
                gui.onCallback(gui._targetState.callback);
        }
    }

    //Calculate gui location
    const Vec2f offset = gui._position + (
            gui._size * gui._currentState.scale / 2f) + gui._currentState.offset;
    if (parent !is null) {
        if (parent.hasCanvas && parent.canvas !is null) {
            if (gui._alignX == GuiAlignX.left)
                coords.x = offset.x;
            else if (gui._alignX == GuiAlignX.right)
                coords.x = (parent._size.x * parent._currentState.scale.x) - offset.x;
            else
                coords.x = (parent._size.x * parent._currentState.scale.x) / 2f
                    + gui._currentState.offset.x + gui.position.x;

            if (gui._alignY == GuiAlignY.bottom)
                coords.y = offset.y;
            else if (gui._alignY == GuiAlignY.top)
                coords.y = (parent._size.y * parent._currentState.scale.y) - offset.y;
            else
                coords.y = (parent._size.y * parent._currentState.scale.y) / 2f
                    + gui._currentState.offset.y + gui.position.y;
        }
        else {
            if (gui._alignX == GuiAlignX.left)
                coords.x = parent.origin.x + offset.x;
            else if (gui._alignX == GuiAlignX.right)
                coords.x = parent.origin.x + (
                        parent._size.x * parent._currentState.scale.x) - offset.x;
            else
                coords.x = parent.center.x + gui._currentState.offset.x + gui.position.x;

            if (gui._alignY == GuiAlignY.bottom)
                coords.y = parent.origin.y + offset.y;
            else if (gui._alignY == GuiAlignY.top)
                coords.y = parent.origin.y + (
                        parent._size.y * parent._currentState.scale.y) - offset.y;
            else
                coords.y = parent.center.y + gui._currentState.offset.y + gui.position.y;
        }
    }
    else {
        if (gui._alignX == GuiAlignX.left)
            coords.x = offset.x;
        else if (gui._alignX == GuiAlignX.right)
            coords.x = screenWidth - offset.x;
        else
            coords.x = centerScreen.x + gui._currentState.offset.x + gui.position.x;

        if (gui._alignY == GuiAlignY.bottom)
            coords.y = offset.y;
        else if (gui._alignY == GuiAlignY.top)
            coords.y = screenHeight - offset.y;
        else
            coords.y = centerScreen.y + gui._currentState.offset.y + gui.position.y;
    }
    gui.setScreenCoords(coords);
    gui.update(_deltaTime);

    size_t childIndex = 0;
    while (childIndex < gui.nodes.length) {
        if (gui.nodes[childIndex]._isRegistered) {
            updateRoots(gui.nodes[childIndex], gui);
            childIndex++;
        }
        else {
            gui.removeChild(childIndex);
        }
    }
}

/// Renders a gui and all its children.
void drawRoots(GuiElement gui) {
    if (gui.hasCanvas && gui.canvas !is null) {
        auto canvas = gui.canvas;
        canvas.color = gui._currentState.color;
        canvas.alpha = gui._currentState.alpha;
        pushCanvas(canvas, true);
        gui.draw();
        foreach (GuiElement child; gui.nodes) {
            drawRoots(child);
        }
        popCanvas();
        canvas.draw(gui._screenCoords, gui.size, Vec4i(0, 0,
                canvas.renderSize.x, canvas.renderSize.y), gui._currentState.angle);
        const auto origin = gui._origin;
        const auto center = gui._center;
        gui._origin = gui._screenCoords - (gui._size * gui._currentState.scale) / 2f;
        gui._center = gui._screenCoords;
        gui.drawOverlay();
        gui._origin = origin;
        gui._center = center;
    }
    else {
        gui.draw();
        foreach (GuiElement child; gui.nodes) {
            drawRoots(child);
        }
        gui.drawOverlay();
    }
    if (_isGuiElementDebug) {
        /*drawRect(gui.center - (gui._size * gui._currentState.scale) / 2f,
                gui._size * gui._currentState.scale, gui.isHovered ? Color.red
                : (gui.nodes.length ? Color.blue : Color.green));*/
    }
}

/// Notify every gui in the tree that we are leaving.
private void dispatchQuitEvent(GuiElement gui) {
    if (gui !is null) {
        foreach (GuiElement child; gui.nodes)
            dispatchQuitEvent(child);
        gui.onQuit();
    }
    else {
        foreach (GuiElement widget; _rootElements)
            dispatchQuitEvent(widget);
    }
}

/// Every other event that doesn't have a specific behavior.
private void dispatchGenericEvents(GuiElement gui, Event event) {
    if (gui !is null) {
        gui.onEvent(event);
        foreach (GuiElement child; gui.nodes) {
            dispatchGenericEvents(child, event);
        }
    }
    else {
        foreach (GuiElement widget; _rootElements) {
            dispatchGenericEvents(widget, event);
        }
    }
}

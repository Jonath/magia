module magia.script.ui;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.core;
import magia.ui;

package void loadMagiaLibUI(GrLibrary library) {
    GrType splineType = grGetEnumType("Spline");
    GrType alignXType = library.addEnum("AlignX", ["left", "center", "right"]);
    GrType alignYType = library.addEnum("AlignY", ["top", "center", "bottom"]);
    GrType stateType = library.addForeign("UIState");

    GrType uiType = library.addForeign("UI");
    GrType labelType = library.addForeign("Label", [], "UI");

    // Commun aux UI
    library.addFunction(&_ui_position, "position", [
            uiType, grReal, grReal
        ]);
    library.addFunction(&_ui_size, "size", [
            uiType, grReal, grReal
        ]);
    library.addFunction(&_ui_scale, "scale", [
            uiType, grReal, grReal
        ]);
    library.addFunction(&_ui_pivot, "pivot", [
            uiType, grReal, grReal
        ]);
    library.addFunction(&_ui_angle, "angle", [
            uiType, grReal
        ]);
    library.addFunction(&_ui_alpha, "alpha", [
            uiType, grReal
        ]);
    library.addFunction(&_ui_align, "align", [
            uiType, alignXType, alignYType
        ]);

    library.addFunction(&_ui_state_make, "UIState", [grString], [stateType]);
    library.addFunction(&_ui_state_offset, "offset", [
            stateType, grReal, grReal
        ]);
    library.addFunction(&_ui_state_scale, "scale", [
            stateType, grReal, grReal
        ]);
    library.addFunction(&_ui_state_angle, "angle", [
            stateType, grReal
        ]);
    library.addFunction(&_ui_state_alpha, "alpha", [
            stateType, grReal
        ]);
    library.addFunction(&_ui_state_time, "time", [
            stateType, grReal
        ]);
    library.addFunction(&_ui_state_spline, "spline", [
            stateType, splineType
        ]);

    library.addFunction(&_ui_addState, "addState", [uiType, stateType]);
    library.addFunction(&_ui_setState, "setState", [uiType, grString]);
    library.addFunction(&_ui_runState, "runState", [uiType, grString]);

    library.addFunction(&_ui_append_root, "appendUI", [uiType]);
    library.addFunction(&_ui_append_child, "append", [uiType, uiType]);

    // Labels
    library.addFunction(&_label_make, "Label", [grString], [labelType]);
    library.addFunction(&_label_text, "text", [labelType, grString]);
}

private void _ui_position(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.posX = call.getReal(1);
    ui.posY = call.getReal(2);
}

private void _ui_size(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.sizeX = call.getReal(1);
    ui.sizeY = call.getReal(2);
}

private void _ui_scale(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.scaleX = call.getReal(1);
    ui.scaleY = call.getReal(2);
}

private void _ui_pivot(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.pivotX = call.getReal(1);
    ui.pivotY = call.getReal(2);
}

private void _ui_angle(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.angle = call.getReal(1);
}

private void _ui_alpha(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.alpha = call.getReal(1);
}

private void _ui_align(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.alignX = call.getEnum!(UIElement.AlignX)(1);
    ui.alignY = call.getEnum!(UIElement.AlignY)(2);
}

private void _ui_state_make(GrCall call) {
    UIElement.State state = new UIElement.State;
    state.name = call.getString(0);
    call.setForeign(state);
}

private void _ui_state_offset(GrCall call) {
    UIElement.State state = call.getForeign!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.offsetX = call.getReal(1);
    state.offsetY = call.getReal(2);
}

private void _ui_state_scale(GrCall call) {
    UIElement.State state = call.getForeign!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.scaleX = call.getReal(1);
    state.scaleY = call.getReal(2);
}

private void _ui_state_angle(GrCall call) {
    UIElement.State state = call.getForeign!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.angle = call.getReal(1);
}

private void _ui_state_alpha(GrCall call) {
    UIElement.State state = call.getForeign!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.alpha = call.getReal(1);
}

private void _ui_state_time(GrCall call) {
    UIElement.State state = call.getForeign!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.time = call.getReal(1);
}

private void _ui_state_spline(GrCall call) {
    UIElement.State state = call.getForeign!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.spline = call.getEnum!Spline(1);
}

private void _ui_addState(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    UIElement.State state = call.getForeign!(UIElement.State)(1);
    if (!ui || !state) {
        call.raise("NullError");
        return;
    }

    ui.states[state.name] = state;
}

private void _ui_setState(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    const auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = null;
    ui.targetState = null;
    ui.offsetX = ptr.offsetX;
    ui.offsetY = ptr.offsetY;
    ui.scaleX = ptr.scaleX;
    ui.scaleX = ptr.scaleX;
    ui.angle = ptr.angle;
    ui.alpha = ptr.alpha;
    ui.timer.stop();
}

private void _ui_runState(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = new UIElement.State;
    ui.initState.offsetX = ui.offsetX;
    ui.initState.offsetY = ui.offsetY;
    ui.initState.scaleX = ui.scaleX;
    ui.initState.scaleY = ui.scaleY;
    ui.initState.angle = ui.angle;
    ui.initState.alpha = ui.alpha;
    ui.initState.time = ui.timer.duration;
    ui.targetState = *ptr;
    ui.timer.start(ptr.time);
}

private void _ui_append_root(GrCall call) {
    UIElement ui = call.getForeign!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    appendRoot(ui);
}

private void _ui_append_child(GrCall call) {
    UIElement uiParent = call.getForeign!UIElement(0);
    UIElement uiChild = call.getForeign!UIElement(1);
    if (!uiParent || !uiChild) {
        call.raise("NullError");
        return;
    }

    uiParent._children ~= uiChild;
}

private void _label_make(GrCall call) {
    Label label = new Label(call.getString(0));
    call.setForeign(label);
}

private void _label_text(GrCall call) {
    Label label = call.getForeign!Label(0);
    if (!label) {
        call.raise("NullError");
        return;
    }

    label.text = call.getString(1);
}
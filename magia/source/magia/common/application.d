/**
    Application

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module magia.common.application;

import std.conv : to;
import std.stdio : writeln;
import bindbc.sdl;

import core.thread;
import std.datetime;

import grimoire;

import magia.core, magia.render, magia.ui, magia.script;

import magia.common.event;
import magia.common.settings;
import magia.common.resource;

private {
    float _deltatime = 1f;
    float _currentFps;
    long _tickStartFrame;

    bool _isChildGrabbed;
    uint _idChildGrabbed;

    uint _nominalFPS = 60u;

    GrEngine _engine;
    GrLibrary _stdlib;
    GrLibrary _magialib;
}

/// Actual framerate divided by the nominal framerate
/// 1 if the same, less if the application slow down,
/// more if the application runs too quickly.
float getDeltatime() {
    return _deltatime;
}

/// Actual framerate of the application.
float getCurrentFPS() {
    return _currentFps;
}

/// Maximum framerate of the application. \
/// The deltatime is equal to 1 if the framerate is exactly that.
uint getNominalFPS() {
    return _nominalFPS;
}
/// Ditto
uint setNominalFPS(uint fps) {
    return _nominalFPS = fps;
}

void print(GrString message) {
    writeln(message);
}

/// Main application loop
void runApplication() {
    createWindow(Vec2u(800, 800), "Magia");
    initializeEvents();
    _tickStartFrame = Clock.currStdTime();

    initFont();

    initializeScene();

    initUI();

    // Script
    _stdlib = grLoadStdLibrary();
    _magialib = loadMagiaLibrary();
    grSetOutputFunction(&print);

    loadScript();

    while (processEvents()) {
        // Màj
        updateEvents(_deltatime);

        if (getButtonDown(KeyButton.f5)) {
            loadScript();
        }

        if (_engine) {
            if (_engine.hasTasks)
                _engine.process();

            if (_engine.isPanicking) {
                writeln(_engine.prettifyProfiling());

                string err = "panique: " ~ _engine.panicMessage ~ "\n";
                foreach (trace; _engine.stackTraces) {
                    err ~= "[" ~ to!string(
                        trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                        trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                }
                _engine = null;
                writeln(err);
            }
        }

        updateScene(_deltatime);
        updateUI(_deltatime);

        // Rendu
        // 3D
        setup3DRender();
        drawScene();

        // 2D
        setup2DRender();
        drawUI();

        renderWindow();

        // IPS
        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        if (deltaTicks < (10_000_000 / _nominalFPS))
            Thread.sleep(dur!("hnsecs")((10_000_000 / _nominalFPS) - deltaTicks));

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
        _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();
    }
}

void loadScript() {
    resetScene();
    removeRoots();

    GrCompiler compiler = new GrCompiler;
    compiler.addLibrary(_stdlib);
    compiler.addLibrary(_magialib);

    GrBytecode bytecode = compiler.compileFile(
        "assets/script/main.gr", GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

    if (!bytecode) {
        writeln(compiler.getError().prettify());
        _engine = null;
        return;
    }

    _engine = new GrEngine;
    _engine.addLibrary(_stdlib);
    _engine.addLibrary(_magialib);
    _engine.load(bytecode);

    if (_engine.hasEvent("onLoad"))
        _engine.callEvent("onLoad");
}

/// Cleanup and kill the application
void destroyApplication() {
    destroyEvents();
    destroyWindow();
}

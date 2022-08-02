/**
    Application

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module magia.common.application;

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
    import std.stdio : writeln;

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
    GrLibrary stdlib = grLoadStdLibrary();
    GrLibrary magialib = loadMagiaLibrary();
    grSetOutputFunction(&print);

    GrCompiler compiler = new GrCompiler;
    compiler.addLibrary(stdlib);
    compiler.addLibrary(magialib);
    GrBytecode bytecode = compiler.compileFile("assets/script/main.gr", GrOption.none, GrLocale.fr_FR);
    if (!bytecode)
        throw new Exception(compiler.getError().prettify());

    _engine = new GrEngine;
    _engine.addLibrary(stdlib);
    _engine.addLibrary(magialib);
    _engine.load(bytecode);

    if (_engine.hasEvent("onLoad"))
        _engine.callEvent("onLoad");

    while (processEvents()) {
        // Màj
        updateEvents(_deltatime);

        if (_engine.hasTasks)
            _engine.process();

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

/// Cleanup and kill the application
void destroyApplication() {
    destroyEvents();
    destroyWindow();
}

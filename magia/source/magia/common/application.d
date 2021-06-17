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

import magia.core, magia.render, magia.script;

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

/// Main application loop
void runApplication() {
    createWindow(Vec2u(800, 600), "Magia");
    initializeEvents();
    _tickStartFrame = Clock.currStdTime();

    initFont();

    // Script
    GrLibrary stdlib = grLoadStdLibrary();
    GrLibrary magialib = loadMagiaLibrary();

    GrCompiler compiler = new GrCompiler;
    compiler.addLibrary(stdlib);
    compiler.addLibrary(magialib);
    GrBytecode bytecode = compiler.compileFile("script/main.gr", GrCompiler.Flags.none);
    if (!bytecode)
        throw new Exception(compiler.getError().prettify());

    _engine = new GrEngine;
    _engine.addLibrary(stdlib);
    _engine.addLibrary(magialib);
    _engine.load(bytecode);
    _engine.spawn();

    while (processEvents()) {
        updateEvents(_deltatime);

        if (_engine.hasCoroutines)
            _engine.process();

        renderWindow();

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

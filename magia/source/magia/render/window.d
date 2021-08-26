/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module magia.render.window;

import std.stdio;
import std.string;
import std.exception;
import bindbc.opengl, bindbc.sdl, bindbc.sdl.image, bindbc.sdl.mixer, bindbc.sdl.ttf;
import magia.core, magia.common, magia.render.canvas, magia.render.primitive;

static {
	/// SDL window
	SDL_Window* _sdlWindow;

	/// SDL context
	SDL_GLContext _glContext;

	/// Window clear color
	Color _windowClearColor;

	private {
		SDL_Surface* _icon;
		Vec2u _windowSize;
		Vec2f _screenSize, _centerScreen;
		DisplayMode _displayMode = DisplayMode.windowed;
		GLuint _currentShaderProgram;
		Color _baseColor = Color.white;
		float _baseAlpha = 1f;
	}
}

@property {
	/// Width of the window in pixels.
	uint screenWidth() {
		return _windowSize.x;
	}
	/// Height of the window in pixels.
	uint screenHeight() {
		return _windowSize.y;
	}
	/// Size of the window in pixels.
	Vec2f screenSize() {
		return _screenSize;
	}
	/// Half of the size of the window in pixels.
	Vec2f centerScreen() {
		return _centerScreen;
	}
}

private struct CanvasReference {
	Vec2f position;
	Vec2f renderSize;
	Vec2f size;
	Canvas canvas;
	uint frameId;
}

static private CanvasReference[] _canvases;

/// Window display mode.
enum DisplayMode {
	fullscreen,
	desktop,
	windowed
}

/// Loads all libraries and creates the application window
void createWindow(const Vec2u windowSize, string title) {
	enforce(loadSDL() >= SDLSupport.sdl202);
	enforce(loadSDLImage() >= SDLImageSupport.sdlImage200);
	enforce(loadSDLTTF() >= SDLTTFSupport.sdlTTF2014);
	enforce(loadSDLMixer() >= SDLMixerSupport.sdlMixer200);

	enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0,
			"could not initialize SDL: " ~ fromStringz(SDL_GetError()));

	enforce(TTF_Init() != -1, "could not initialize TTF module");
	enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS,
			1024) != -1, "no audio device connected");
	enforce(Mix_AllocateChannels(16) != -1, "could not allocate audio channels");

	_sdlWindow = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_CENTERED,
			SDL_WINDOWPOS_CENTERED, windowSize.x, windowSize.y,
			SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
	enforce(_sdlWindow, "failed to create the window");
	_glContext = SDL_GL_CreateContext(_sdlWindow);
	enforce(loadOpenGL() == GLSupport.gl41, "failed to load opengl");

	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);

	SDL_GL_MakeCurrent(_sdlWindow, _glContext);

	glViewport(0, 0, windowSize.x, windowSize.y);

	glDepthFunc(GL_NEVER);
	glCullFace(GL_BACK);
	glFrontFace(GL_CW);
	glEnable(GL_CULL_FACE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);

	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	CanvasReference canvasRef;
	canvasRef.position = cast(Vec2f)(windowSize) / 2;
	canvasRef.size = cast(Vec2f)(windowSize);
	canvasRef.renderSize = cast(Vec2f)(windowSize);
	_canvases ~= canvasRef;

	_windowSize = windowSize;
	_screenSize = cast(Vec2f)(windowSize);
	_centerScreen = _screenSize / 2f;

	setWindowTitle(title);

	initPrimitive();
}

/// Cleanup the application window.
void destroyWindow() {
	if (_sdlWindow) {
		SDL_DestroyWindow(_sdlWindow);
	}
}

/// Change the actual window title.
void setWindowTitle(string title) {
	SDL_SetWindowTitle(_sdlWindow, toStringz(title));
}

/// Change the base color of the base canvas.
void setWindowClearColor(Color color) {
	_windowClearColor = color;
}

/// Update the window size. \
/// If `isLogical` is set, the actual window won't be resized, only the canvas will.
void setWindowSize(const Vec2u windowSize) {
	resizeWindow(windowSize);
	SDL_SetWindowSize(_sdlWindow, windowSize.x, windowSize.y);
}

/// Call this to update canvas size when window's size is changed externally.
void resizeWindow(const Vec2u windowSize) {
	_windowSize = windowSize;
	_screenSize = cast(Vec2f)(windowSize);
	_centerScreen = _screenSize / 2f;

	glViewport(0, 0, windowSize.x, windowSize.y);
	if (_canvases.length) {
		_canvases[0].position = cast(Vec2f)(windowSize) / 2;
		_canvases[0].size = cast(Vec2f)(windowSize);
		_canvases[0].renderSize = cast(Vec2f) windowSize;
	}
}

/// Current window size.
Vec2i getWindowSize() {
	Vec2i windowSize;
	SDL_GetWindowSize(_sdlWindow, &windowSize.x, &windowSize.y);
	return windowSize;
}

/// The window cannot be resized less than this.
void setWindowMinSize(Vec2u size) {
	SDL_SetWindowMinimumSize(_sdlWindow, size.x, size.y);
}

/// The window cannot be resized more than this.
void setWindowMaxSize(Vec2u size) {
	SDL_SetWindowMaximumSize(_sdlWindow, size.x, size.y);
}

/// Change the icon displayed.
void setWindowIcon(string path) {
	if (_icon) {
		SDL_FreeSurface(_icon);
		_icon = null;
	}
	_icon = IMG_Load(toStringz(path));

	SDL_SetWindowIcon(_sdlWindow, _icon);
}

/// Change the display mode between windowed, desktop fullscreen and fullscreen.
void setWindowDisplay(DisplayMode displayMode) {
	_displayMode = displayMode;
	SDL_WindowFlags mode;
	final switch (displayMode) with (DisplayMode) {
	case fullscreen:
		mode = SDL_WINDOW_FULLSCREEN;
		break;
	case desktop:
		mode = SDL_WINDOW_FULLSCREEN_DESKTOP;
		break;
	case windowed:
		mode = cast(SDL_WindowFlags) 0;
		break;
	}
	SDL_SetWindowFullscreen(_sdlWindow, mode);
	Vec2u newSize = cast(Vec2u) getWindowSize();
	resizeWindow(newSize);
	Event event;
	event.type = EventType.resize;
	event.window.size = newSize;
}

/// Current display mode.
DisplayMode getWindowDisplay() {
	return _displayMode;
}

/// Enable/Disable the borders.
void setWindowBordered(bool bordered) {
	SDL_SetWindowBordered(_sdlWindow, bordered ? SDL_TRUE : SDL_FALSE);
}

/// Show/Hide the window.
/// Shown by default.
void showWindow(bool show) {
	if (show) {
		SDL_ShowWindow(_sdlWindow);
	} else {
		SDL_HideWindow(_sdlWindow);
	}
}

/// Render everything on screen.
void renderWindow() {
	SDL_GL_SwapWindow(_sdlWindow);

	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

/// Push a render canvas on the stack.
/// Everything after that and before the next popCanvas will be rendered onto this.
/// You **must** call popCanvas after that.
void pushCanvas(Canvas canvas, bool clear = true) {
	CanvasReference canvasRef;
	canvasRef.position = canvas.position;
	canvasRef.size = canvas.size;
	canvasRef.renderSize = Vec2f(canvas.width, canvas.height);
	canvasRef.canvas = canvas;
	canvasRef.frameId = canvas._frameId;
	_canvases ~= canvasRef;

	glBindFramebuffer(GL_FRAMEBUFFER, canvasRef.frameId);
	canvas._isTargetOnStack = true;

	if (clear) {
		canvas.clear();
	}
}

/// Called after pushCanvas to remove the render canvas from the stack.
/// When there is no canvas on the stack, everything is displayed directly on screen.
void popCanvas() {
	assert(_canvases.length > 1, "Attempt to pop the main canvas.");
	_canvases[$ - 1].canvas._isTargetOnStack = false;
	_canvases.length--;

	if (_canvases.length == 1) {
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glViewport(0, 0, _windowSize.x, _windowSize.y);
	}
	else {
		glBindFramebuffer(GL_FRAMEBUFFER, _canvases[$ - 1].frameId);
		glViewport(0, 0, _canvases[$ - 1].canvas.width, _canvases[$ - 1].canvas.height);
	}
}

/// Change coordinate system from inside to outside the canvas.
Vec2f transformRenderSpace(const Vec2f pos) {
	const CanvasReference* canvasRef = &_canvases[$ - 1];
	return (pos - canvasRef.position) * (
			canvasRef.renderSize / canvasRef.size) + canvasRef.renderSize * 0.5f;
}

/// Change coordinate system from outside to inside the canvas.
Vec2f transformCanvasSpace(const Vec2f pos, const Vec2f renderPos) {
	const CanvasReference* canvasRef = &_canvases[$ - 1];
	return (pos - renderPos) * (canvasRef.size / canvasRef.renderSize) + canvasRef.position;
}

/// Change coordinate system from outside to insside the canvas.
Vec2f transformCanvasSpace(const Vec2f pos) {
	const CanvasReference* canvasRef = &_canvases[$ - 1];
	return pos * (canvasRef.size / canvasRef.renderSize);
}

/// Change the scale from outside to inside the canvas.
Vec2f transformScale() {
	const CanvasReference* canvasRef = &_canvases[$ - 1];
	return canvasRef.renderSize / canvasRef.size;
}

/// Get the canvas size.
Vec2f transformSize() {
	const CanvasReference* canvasRef = &_canvases[$ - 1];
	return canvasRef.size;
}

/// Check if something is inside the actual canvas rendering area.
bool isVisible(const Vec2f targetPosition, const Vec2f targetSize) {
	const CanvasReference* canvasRef = &_canvases[$ - 1];
	return (((canvasRef.position.x - canvasRef.size.x * .5f) < (
			targetPosition.x + targetSize.x * .5f))
			&& ((canvasRef.position.x + canvasRef.size.x * .5f) > (
				targetPosition.x - targetSize.x * .5f))
			&& ((canvasRef.position.y - canvasRef.size.y * .5f) < (
				targetPosition.y + targetSize.y * .5f))
			&& ((canvasRef.position.y + canvasRef.size.y * .5f) > (
				targetPosition.y - targetSize.y * .5f)));
}

/// Sets shader main entry point
void setShaderProgram(GLuint shaderProgram) {
	if (shaderProgram != _currentShaderProgram) {
		_currentShaderProgram = shaderProgram;
		glUseProgram(_currentShaderProgram);
	}
}

void setBaseColor(Color color) {
	_baseColor = color;
}

Color getBaseColor() {
	return _baseColor;
}

void setBaseAlpha(float alpha) {
	_baseAlpha = alpha;
}

float getBaseAlpha() {
	return _baseAlpha;
}
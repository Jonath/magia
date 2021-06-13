
/**
    Test application

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

import std.stdio: writeln;
import std.file, std.path;

import atelier;
//+
void main() {
	try {
		createApplication(Vec2u(640, 480));

/*      auto fontCache = new ResourceCache!TrueTypeFont;
        setResourceCache!TrueTypeFont(fontCache);

        auto files = dirEntries("../data/font/", "{*.ttf}", SpanMode.depth);
        foreach(file; files) {
            fontCache.set(new TrueTypeFont(file), baseName(file, ".ttf"));
        }
        setDefaultFont(fetch!TrueTypeFont("font"));

        addRootGui(new TextButton(getDefaultFont(), "Top Left !"));

        auto o = new VContainer;
        auto t = new TextButton(getDefaultFont(), "Hello World!");
        o.setAlign(GuiAlignX.right, GuiAlignY.bottom);
        auto h = new HContainer;
        h.addChildGui(t);
        o.addChildGui(h);
        addRootGui(o);

        setDebugGui(true);

        setWindowMinSize(Vec2u(100, 100));
        setWindowMaxSize(Vec2u(600, 600));*/

		runApplication();
	}
	catch(Exception e) {
		writeln(e.msg);
	}
}/+

import std.stdio;
import bindbc.opengl;//, bindbc.glfw;
import core.thread, std.string;
import bindbc.sdl;

void main() {
	const SDLSupport sdlSup = loadSDL();
	writeln(sdlSup);
	assert(sdlSup == sdlSupport);
	assert(loadSDLImage() >= SDLImageSupport.sdlImage200);

	SDL_Init(SDL_INIT_EVERYTHING);
	SDL_Window* window = SDL_CreateWindow("TEST", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);

	SDL_GLContext context = SDL_GL_CreateContext(window);

	const GLSupport glSup = loadOpenGL();
	assert(glSup == GLSupport.gl41);

	glViewport(0, 0, 640, 480);

	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST);
	glCullFace(GL_BACK);
	glFrontFace(GL_CW);
	glEnable(GL_CULL_FACE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);

	glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    SDL_Surface* surface = IMG_Load(toStringz("mask.png"));
	assert(surface);
    GLuint _texId = 0;
    glGenTextures(1, &_texId);
    glActiveTexture (GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surface.w, surface.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, surface.pixels);
    glGenerateMipmap (GL_TEXTURE_2D);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    SDL_FreeSurface(surface);
    
	immutable float[] points = [
		-1, 1f,
		1f, -1f,
		-1f, -1f,
		-1f, 1f,
        1, 1f,
		1f, -1f,
	];

	GLuint vbo = 0;
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);

	GLuint _vao = 0;
	glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
    glEnableVertexAttribArray(0);

	immutable char* vshader = toStringz("
	#version 400
	in vec2 vp;
    out vec2 st;
	void main() {
        st = (vp + 1.0) * 0.5;
		gl_Position = vec4(vp, 0.0, 1.0);
	}
	");

	immutable char* fshader = toStringz("
	#version 400
    in vec2 st;
	out vec4 frag_colour;
	void main() {
		frag_colour = vec4(0.5, 0.0, 0.5, 1.0);
	}
	");

	GLuint vs = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vs, 1, &vshader, null);
	glCompileShader(vs);
	GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fs, 1, &fshader, null);
	glCompileShader(fs);

	GLuint _sp = glCreateProgram();
	glAttachShader(_sp, fs);
	glAttachShader(_sp, vs);
	glLinkProgram(_sp);
    auto _scaleUniform = glGetUniformLocation(_sp, "scale");


	//while(true) {
		glClearColor(0,0,0,1);
		glClear(GL_COLOR_BUFFER_BIT);
		//glViewport(0, 0, g_gl_width, g_gl_height);
glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texId);
		glUseProgram(_sp);
		glBindVertexArray(_vao);
		glDrawArrays(GL_TRIANGLES, 0, 6);

		SDL_GL_SwapWindow(window);
	//}

	Thread.sleep(dur!"msecs"(1_000));
}
+/
import std.stdio;
import common, core, ui, render;

void main() {
	
	try {
		createApplication(Vec2u(640, 480));

		setDefaultFont(new TrueTypeFont("assets\\font\\Cascadia.ttf"));

		appendRoot(new Screen);

		auto a = new Label("Test !!");
		//a.setAlign(GuiAlignX.center, GuiAlignY.center);
		appendRoot(a);
		runApplication();
	}
	catch(Exception e) {
		writeln(e.msg);
	}
}


class Screen: GuiElement {
	Texture a;
	Sprite b;
	this() {
		hasCanvas(true);
		size(Vec2f(100f, 200f));
		a = new Texture("assets\\img\\logo.png");
		b = new Sprite(a);
		//a.size = size;
		setAlign(GuiAlignX.center, GuiAlignY.center);
		b.size = size;
	}

	override void draw() {
		drawFilledRect(origin, size, Color.red, 1f);
		b.draw(center);
	}
}
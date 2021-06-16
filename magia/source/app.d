import std.stdio;
import magia.common, magia.core;

void main() {
	try {
		runApplication();
	}
	catch (Exception e) {
		writeln(e.msg);
	}
}

import std.stdio;
import magia.common, magia.core;

void main() {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
	try {
		runApplication();
	}
	catch (Exception e) {
		writeln(e.msg);
	}
}

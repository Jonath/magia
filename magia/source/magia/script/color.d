module magia.script.color;

import std.conv : to;
import std.algorithm.comparison : clamp;
import grimoire;
import magia.common;

package void loadMagiaLibColor(GrLibrary library) {
    auto colorType = library.addClass("color", [
            "r", "g", "b"
        ], [
            grReal, grReal, grReal
        ]);

    library.addFunction(&_color, "color", [], [colorType]);
    library.addFunction(&_color_3r, "color", [grReal, grReal, grReal], [
            colorType
        ]);

    library.addFunction(&_color_3i, "color", [grInt, grInt, grInt], [
            colorType
        ]);

    static foreach (op; ["+", "-", "*", "/", "%"]) {
        library.addOperator(&_opBinaryColor!op, op, [colorType, colorType], colorType);
        library.addOperator(&_opBinaryScalarColor!op, op, [colorType, grReal], colorType);
        library.addOperator(&_opBinaryScalarRightColor!op, op, [
                grReal, colorType
            ], colorType);
    }

    library.addFunction(&_lerp, "lerp", [
            colorType, colorType, grReal
        ], [
            colorType
        ]);

    library.addCast(&_fromArray, grIntArray, colorType);
    library.addCast(&_toString, colorType, grString);

    library.addFunction(&_unpack, "unpack", [colorType], [
            grReal, grReal, grReal
        ]);

    library.addFunction(&_print, "print", [colorType]);
}

private void _color(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("r", 0f);
    self.setReal("g", 0f);
    self.setReal("b", 0f);
    call.setObject(self);
}

private void _color_3r(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("r", call.getReal(0));
    self.setReal("g", call.getReal(1));
    self.setReal("b", call.getReal(2));
    call.setObject(self);
}

private void _color_3i(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("r", clamp(call.getInt(0) / 255f, 0f, 1f));
    self.setReal("g", clamp(call.getInt(1) / 255f, 0f, 1f));
    self.setReal("b", clamp(call.getInt(2) / 255f, 0f, 1f));
    call.setObject(self);
}

private void _opBinaryColor(string op)(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c1 = call.getObject(0);
    GrObject c2 = call.getObject(1);
    if (!c1 || !c2) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"r\", c1.getReal(\"r\")" ~ op ~ "c2.getReal(\"r\"));");
    mixin("self.setReal(\"g\", c1.getReal(\"g\")" ~ op ~ "c2.getReal(\"g\"));");
    mixin("self.setReal(\"b\", c1.getReal(\"b\")" ~ op ~ "c2.getReal(\"b\"));");
    call.setObject(self);
}

private void _opBinaryScalarColor(string op)(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c = call.getObject(0);
    const GrReal s = call.getReal(1);
    if (!c) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"r\", c.getReal(\"r\")" ~ op ~ "s);");
    mixin("self.setReal(\"g\", c.getReal(\"g\")" ~ op ~ "s);");
    mixin("self.setReal(\"b\", c.getReal(\"b\")" ~ op ~ "s);");
    call.setObject(self);
}

private void _opBinaryScalarRightColor(string op)(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c = call.getObject(0);
    const GrReal s = call.getReal(1);
    if (!c) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"r\", s" ~ op ~ "c.getReal(\"r\"));");
    mixin("self.setReal(\"g\", s" ~ op ~ "c.getReal(\"g\"));");
    mixin("self.setReal(\"b\", s" ~ op ~ "c.getReal(\"b\"));");
    call.setObject(self);
}

private void _lerp(GrCall call) {
    GrObject self = call.createObject("color");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject c1 = call.getObject(0);
    GrObject c2 = call.getObject(1);
    const GrReal t = call.getReal(2);
    if (!c1 || !c2) {
        call.raise("NullError");
        return;
    }
    self.setReal("r", (t * c2.getReal("r")) + ((1f - t) * c1.getReal("r")));
    self.setReal("g", (t * c2.getReal("g")) + ((1f - t) * c1.getReal("g")));
    self.setReal("b", (t * c2.getReal("b")) + ((1f - t) * c1.getReal("b")));
    call.setObject(self);
}

private void _fromArray(GrCall call) {
    GrIntArray array = call.getIntArray(0);
    if (array.data.length == 3) {
        GrObject self = call.createObject("color");
        if (!self) {
            call.raise("UnknownClass");
            return;
        }
        self.setReal("r", array.data[0]);
        self.setReal("g", array.data[1]);
        self.setReal("b", array.data[2]);
        call.setObject(self);
        return;
    }
    call.raise("ConvError");
}

private void _toString(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setString("color(" ~ to!GrString(
            self.getReal("r")) ~ ", " ~ to!GrString(
            self.getReal(
            "g")) ~ ", " ~ to!GrString(self.getReal("b")) ~ ")");
}

private void _unpack(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setReal(self.getReal("r"));
    call.setReal(self.getReal("g"));
    call.setReal(self.getReal("b"));
}

private void _print(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        print("null(color)");
        return;
    }
    print("color(" ~ to!GrString(self.getReal("r")) ~ ", " ~ to!GrString(
            self.getReal("g")) ~ ", " ~ to!GrString(self.getReal("b")) ~ ")");
}

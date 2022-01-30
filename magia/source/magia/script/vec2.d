module magia.script.vec2;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.common;

package void loadMagiaLibVec2(GrLibrary library) {
    GrType vec2Type = library.addClass("vec2", ["x", "y"], [
            grReal, grReal
        ]);

    // Ctors
    library.addFunction(&_vec2_zero, "vec2", [], [vec2Type]);
    library.addFunction(&_vec2_1, "vec2", [grReal], [vec2Type]);
    library.addFunction(&_vec2_2, "vec2", [grReal, grReal], [
            vec2Type
        ]);

    // Print
    library.addFunction(&_print, "print", [vec2Type]);

    // Operators
    static foreach (op; ["+", "-"]) {
        library.addOperator(&_opUnaryVec2!op, op, [vec2Type], vec2Type);
    }
    static foreach (op; ["+", "-", "*", "/", "%"]) {
        library.addOperator(&_opBinaryVec2!op, op, [vec2Type, vec2Type], vec2Type);
        library.addOperator(&_opBinaryScalarVec2!op, op, [vec2Type, grReal], vec2Type);
        library.addOperator(&_opBinaryScalarRightVec2!op, op, [
                grReal, vec2Type
            ], vec2Type);
    }
    static foreach (op; ["==", "!=", ">=", "<=", ">", "<"]) {
        library.addOperator(&_opBinaryCompareVec2!op, op, [
                vec2Type, vec2Type
            ], grBool);
    }

    // Utility
    library.addFunction(&_vec2_zero, "vec2_zero", [], [vec2Type]);
    library.addFunction(&_vec2_half, "vec2_half", [], [vec2Type]);
    library.addFunction(&_vec2_one, "vec2_one", [], [vec2Type]);
    library.addFunction(&_vec2_up, "vec2_up", [], [vec2Type]);
    library.addFunction(&_vec2_down, "vec2_down", [], [vec2Type]);
    library.addFunction(&_vec2_left, "vec2_left", [], [vec2Type]);
    library.addFunction(&_vec2_right, "vec2_right", [], [vec2Type]);

    library.addFunction(&_unpack, "unpack", [vec2Type], [
            grReal, grReal
        ]);

    library.addFunction(&_abs, "abs", [vec2Type], [vec2Type]);
    library.addFunction(&_ceil, "abs", [vec2Type], [vec2Type]);
    library.addFunction(&_floor, "floor", [vec2Type], [vec2Type]);
    library.addFunction(&_round, "round", [vec2Type], [vec2Type]);

    library.addFunction(&_isZero, "zero?", [vec2Type], [grBool]);

    // Operations
    library.addFunction(&_sum, "sum", [vec2Type], [grReal]);
    library.addFunction(&_sign, "sign", [vec2Type], [vec2Type]);

    library.addFunction(&_lerp, "lerp", [vec2Type, vec2Type, grReal], [
            vec2Type
        ]);
    library.addFunction(&_approach, "approach", [
            vec2Type, vec2Type, grReal
        ], [vec2Type]);

    library.addFunction(&_reflect, "reflect", [vec2Type, vec2Type], [
            vec2Type
        ]);
    library.addFunction(&_refract, "refract", [vec2Type, vec2Type, grReal], [
            vec2Type
        ]);

    library.addFunction(&_distance, "distance", [vec2Type, vec2Type], [
            grReal
        ]);
    library.addFunction(&_distanceSquared, "distance2", [
            vec2Type, vec2Type
        ], [
            grReal
        ]);
    library.addFunction(&_dot, "dot", [vec2Type, vec2Type], [grReal]);
    library.addFunction(&_cross, "cross", [vec2Type, vec2Type], [
            grReal
        ]);
    library.addFunction(&_normal, "normal", [vec2Type], [vec2Type]);
    library.addFunction(&_angle, "angle", [vec2Type], [grReal]);
    library.addFunction(&_rotate, "rotate", [vec2Type, grReal], [
            vec2Type
        ]);
    library.addFunction(&_rotated, "rotated", [vec2Type, grReal], [
            vec2Type
        ]);
    library.addFunction(&_angled, "vec2_angled", [grReal], [vec2Type]);
    library.addFunction(&_magnitude, "length", [vec2Type], [grReal]);
    library.addFunction(&_magnitudeSquared, "length2", [vec2Type], [
            grReal
        ]);
    library.addFunction(&_normalize, "normalize", [vec2Type], [
            vec2Type
        ]);
    library.addFunction(&_normalized, "normalized", [vec2Type], [
            vec2Type
        ]);

    library.addCast(&_fromArray, grRealArray, vec2Type);
    library.addCast(&_toString, vec2Type, grString);
}

// Ctors ------------------------------------------
private void _vec2_zero(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", 0f);
    self.setReal("y", 0f);
    call.setObject(self);
}

private void _vec2_1(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    const GrReal value = call.getReal(0);
    self.setReal("x", value);
    self.setReal("y", value);
    call.setObject(self);
}

private void _vec2_2(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", call.getReal(0));
    self.setReal("y", call.getReal(1));
    call.setObject(self);
}

// Print ------------------------------------------
private void _print(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        print("null(vec2)");
        return;
    }
    print("vec2(" ~ to!GrString(self.getReal("x")) ~ ", " ~ to!GrString(
            self.getReal("y")) ~ ")");
}

/// Operators ------------------------------------------
private void _opUnaryVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v = call.getObject(0);
    if (!v) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"x\", " ~ op ~ "v.getReal(\"x\"));");
    mixin("self.setReal(\"y\", " ~ op ~ "v.getReal(\"y\"));");
    call.setObject(self);
}

private void _opBinaryVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"x\", v1.getReal(\"x\")" ~ op ~ "v2.getReal(\"x\"));");
    mixin("self.setReal(\"y\", v1.getReal(\"y\")" ~ op ~ "v2.getReal(\"y\"));");
    call.setObject(self);
}

private void _opBinaryScalarVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v = call.getObject(0);
    const GrReal s = call.getReal(1);
    if (!v) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"x\", v.getReal(\"x\")" ~ op ~ "s);");
    mixin("self.setReal(\"y\", v.getReal(\"y\")" ~ op ~ "s);");
    call.setObject(self);
}

private void _opBinaryScalarRightVec2(string op)(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    GrObject v = call.getObject(0);
    const GrReal s = call.getReal(1);
    if (!v) {
        call.raise("NullError");
        return;
    }
    mixin("self.setReal(\"x\", s" ~ op ~ "v.getReal(\"x\"));");
    mixin("self.setReal(\"y\", s" ~ op ~ "v.getReal(\"y\"));");
    call.setObject(self);
}

private void _opBinaryCompareVec2(string op)(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    mixin("call.setBool(
        v1.getReal(\"x\")"
            ~ op ~ "v2.getReal(\"x\") &&
        v1.getReal(\"y\")"
            ~ op
            ~ "v2.getReal(\"y\"));");
}

// Utility ------------------------------------------
private void _vec2_one(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", 1f);
    self.setReal("y", 1f);
    call.setObject(self);
}

private void _vec2_half(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", .5f);
    self.setReal("y", .5f);
    call.setObject(self);
}

private void _vec2_up(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("y", 1f);
    call.setObject(self);
}

private void _vec2_down(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("y", -1f);
    call.setObject(self);
}

private void _vec2_left(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", -1f);
    call.setObject(self);
}

private void _vec2_right(GrCall call) {
    GrObject self = call.createObject("vec2");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", 1f);
    call.setObject(self);
}

private void _unpack(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setReal(self.getReal("x"));
    call.setReal(self.getReal("y"));
}

private void _isZero(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setBool(self.getReal("x") == 0f && self.getReal("y") == 0f);
}

// Operations ------------------------------------------
private void _abs(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", abs(self.getReal("x")));
    v.setReal("y", abs(self.getReal("y")));
    call.setObject(v);
}

private void _ceil(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", ceil(self.getReal("x")));
    v.setReal("y", ceil(self.getReal("y")));
    call.setObject(v);
}

private void _floor(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", floor(self.getReal("x")));
    v.setReal("y", floor(self.getReal("y")));
    call.setObject(v);
}

private void _round(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", round(self.getReal("x")));
    v.setReal("y", round(self.getReal("y")));
    call.setObject(v);
}

private void _sum(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setReal(self.getReal("x") + self.getReal("y"));
}

private void _sign(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", self.getReal("x") >= 0f ? 1f : -1f);
    v.setReal("y", self.getReal("y") >= 0f ? 1f : -1f);
    call.setObject(v);
}

private void _lerp(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    const GrReal weight = call.getReal(2);
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", v2.getReal("x") * weight + v1.getReal("x") * (1f - weight));
    v.setReal("y", v2.getReal("y") * weight + v1.getReal("y") * (1f - weight));
    call.setObject(v);
}

private void _approach(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrReal x1 = v1.getReal("x");
    const GrReal y1 = v1.getReal("y");
    const GrReal x2 = v2.getReal("x");
    const GrReal y2 = v2.getReal("y");
    const GrReal step = call.getReal(2);
    v.setReal("x", x1 > x2 ? max(x1 - step, x2) : min(x1 + step, x2));
    v.setReal("y", y1 > y2 ? max(y1 - step, y2) : min(y1 + step, y2));
    call.setObject(v);
}

private void _reflect(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrReal x1 = v1.getReal("x");
    const GrReal y1 = v1.getReal("y");
    const GrReal x2 = v2.getReal("x");
    const GrReal y2 = v2.getReal("y");
    const GrReal dotNI2 = 2.0 * x1 * x2 + y1 * y2;
    v.setReal("x", x1 - dotNI2 * x2);
    v.setReal("y", y1 - dotNI2 * y2);
    call.setObject(v);
}

private void _refract(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrReal x1 = v1.getReal("x");
    const GrReal y1 = v1.getReal("y");
    const GrReal x2 = v2.getReal("x");
    const GrReal y2 = v2.getReal("y");
    const GrReal eta = call.getReal(2);

    const GrReal dotNI = (x1 * x2 + y1 * y2);
    GrReal k = 1.0 - eta * eta * (1.0 - dotNI * dotNI);
    if (k < .0) {
        v.setReal("x", 0f);
        v.setReal("y", 0f);
    }
    else {
        const GrReal s = (eta * dotNI + sqrt(k));
        v.setReal("x", eta * x1 - s * x2);
        v.setReal("y", eta * y1 - s * y2);
    }
    call.setObject(v);
}

private void _distance(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    const GrReal px = v1.getReal("x") - v2.getReal("x");
    const GrReal py = v1.getReal("y") - v2.getReal("y");
    call.setReal(std.math.sqrt(px * px + py * py));
}

private void _distanceSquared(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    const GrReal px = v1.getReal("x") - v2.getReal("x");
    const GrReal py = v1.getReal("y") - v2.getReal("y");
    call.setReal(px * px + py * py);
}

private void _dot(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    call.setReal(v1.getReal("x") * v2.getReal("x") + v1.getReal("y") * v2.getReal("y"));
}

private void _cross(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    call.setReal(v1.getReal("x") * v2.getReal("y") - v1.getReal("y") * v2.getReal("x"));
}

private void _normal(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", -self.getReal("y"));
    v.setReal("y", self.getReal("x"));
    call.setObject(v);
}

private void _angle(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setReal(std.math.atan2(self.getReal("y"), self.getReal("x")));
}

private void _rotate(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal radians = call.getReal(1);
    const GrReal px = self.getReal("x"), py = self.getReal("y");
    const GrReal c = std.math.cos(radians);
    const GrReal s = std.math.sin(radians);
    self.setReal("x", px * c - py * s);
    self.setReal("y", px * s + py * c);
    call.setObject(self);
}

private void _rotated(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal radians = call.getReal(1);
    const GrReal px = self.getReal("x"), py = self.getReal("y");
    const GrReal c = std.math.cos(radians);
    const GrReal s = std.math.sin(radians);

    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", px * c - py * s);
    v.setReal("y", px * s + py * c);
    call.setObject(v);
}

private void _angled(GrCall call) {
    const GrReal radians = call.getReal(0);
    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", std.math.cos(radians));
    v.setReal("y", std.math.sin(radians));
    call.setObject(v);
}

private void _magnitude(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal x = self.getReal("x");
    const GrReal y = self.getReal("y");
    call.setReal(std.math.sqrt(x * x + y * y));
}

private void _magnitudeSquared(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal x = self.getReal("x");
    const GrReal y = self.getReal("y");
    call.setReal(x * x + y * y);
}

private void _normalize(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal x = self.getReal("x");
    const GrReal y = self.getReal("y");
    const GrReal len = std.math.sqrt(x * x + y * y);
    if (len == 0) {
        self.setReal("x", len);
        self.setReal("y", len);
        return;
    }
    self.setReal("x", x / len);
    self.setReal("y", y / len);
    call.setObject(self);
}

private void _normalized(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrReal x = self.getReal("x");
    GrReal y = self.getReal("y");
    const GrReal len = std.math.sqrt(x * x + y * y);

    if (len == 0) {
        x = len;
        y = len;
        return;
    }
    x /= len;
    y /= len;

    GrObject v = call.createObject("vec2");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", x);
    v.setReal("y", y);
    call.setObject(v);
}

private void _fromArray(GrCall call) {
    GrRealArray array = call.getRealArray(0);
    if (array.data.length == 2) {
        GrObject self = call.createObject("vec2");
        if (!self) {
            call.raise("UnknownClass");
            return;
        }
        self.setReal("x", array.data[0]);
        self.setReal("y", array.data[1]);
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
    call.setString("vec2(" ~
            to!GrString(self.getReal("x")) ~ ", " ~
            to!GrString(
                self.getReal("y")) ~ ")");
}

module magia.script.vec3;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.common;

package void loadMagiaLibVec3(GrLibrary library) {
    GrType vec3Type = library.addClass("vec3", ["x", "y", "z"], [
            grReal, grReal, grReal
        ]);

    // Ctors
    library.addFunction(&_vec3_zero, "vec3", [], [vec3Type]);
    library.addFunction(&_vec3_3, "vec3", [grReal, grReal, grReal], [vec3Type]);

    // Print
    library.addFunction(&_print, "print", [vec3Type]);

    // Operators
    static foreach (op; ["+", "-"]) {
        library.addOperator(&_opUnaryVec3!op, op, [vec3Type], vec3Type);
    }
    static foreach (op; ["+", "-", "*", "/", "%"]) {
        library.addOperator(&_opBinaryVec3!op, op, [vec3Type, vec3Type], vec3Type);
        library.addOperator(&_opBinaryScalarVec3!op, op, [vec3Type, grReal], vec3Type);
        library.addOperator(&_opBinaryScalarRightVec3!op, op, [
                grReal, vec3Type
            ], vec3Type);
    }
    static foreach (op; ["==", "!=", ">=", "<=", ">", "<"]) {
        library.addOperator(&_opBinaryCompareVec3!op, op, [
                vec3Type, vec3Type
            ], grBool);
    }

    // Utility
    library.addFunction(&_vec3_zero, "vec3_zero", [], [vec3Type]);
    library.addFunction(&_vec3_half, "vec3_half", [], [vec3Type]);
    library.addFunction(&_vec3_one, "vec3_one", [], [vec3Type]);
    library.addFunction(&_vec3_up, "vec3_up", [], [vec3Type]);
    library.addFunction(&_vec3_down, "vec3_down", [], [vec3Type]);
    library.addFunction(&_vec3_left, "vec3_left", [], [vec3Type]);
    library.addFunction(&_vec3_right, "vec3_right", [], [vec3Type]);

    library.addFunction(&_unpack, "unpack", [vec3Type], [
            grReal, grReal, grReal
        ]);

    library.addFunction(&_abs, "abs", [vec3Type], [vec3Type]);
    library.addFunction(&_ceil, "abs", [vec3Type], [vec3Type]);
    library.addFunction(&_floor, "floor", [vec3Type], [vec3Type]);
    library.addFunction(&_round, "round", [vec3Type], [vec3Type]);

    library.addFunction(&_isZero, "zero?", [vec3Type], [grBool]);

    // Operations
    library.addFunction(&_sum, "sum", [vec3Type], [grReal]);
    library.addFunction(&_sign, "sign", [vec3Type], [vec3Type]);

    library.addFunction(&_lerp, "lerp", [vec3Type, vec3Type, grReal], [
            vec3Type
        ]);
    library.addFunction(&_approach, "approach", [
            vec3Type, vec3Type, grReal
        ], [vec3Type]);

    library.addFunction(&_distance, "distance", [vec3Type, vec3Type], [
            grReal
        ]);
    library.addFunction(&_distanceSquared, "distance2", [
            vec3Type, vec3Type
        ], [
            grReal
        ]);
    library.addFunction(&_magnitude, "magnitude", [vec3Type], [grReal]);
    library.addFunction(&_magnitudeSquared, "magnitude2", [vec3Type], [
            grReal
        ]);
    library.addFunction(&_normalize, "normalize", [vec3Type], [
            vec3Type
        ]);
    library.addFunction(&_normalized, "normalized", [vec3Type], [
            vec3Type
        ]);

    library.addCast(&_fromArray, grRealArray, vec3Type);
    library.addCast(&_toString, vec3Type, grString);
}

// Ctors ------------------------------------------
private void _vec3_zero(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", 0f);
    self.setReal("y", 0f);
    self.setReal("z", 0f);
    call.setObject(self);
}

private void _vec3_3(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", call.getReal(0));
    self.setReal("y", call.getReal(1));
    self.setReal("z", call.getReal(2));
    call.setObject(self);
}

// Print ------------------------------------------
private void _print(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        print("null(vec3)");
        return;
    }
    print("vec3(" ~ to!GrString(self.getReal("x")) ~ ", " ~ to!GrString(
            self.getReal("y")) ~ ", " ~ to!GrString(
            self.getReal("z")) ~ ")");
}

/// Operators ------------------------------------------
private void _opUnaryVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setReal(\"z\", " ~ op ~ "v.getReal(\"z\"));");
    call.setObject(self);
}

private void _opBinaryVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setReal(\"z\", v1.getReal(\"z\")" ~ op ~ "v2.getReal(\"z\"));");
    call.setObject(self);
}

private void _opBinaryScalarVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setReal(\"z\", v.getReal(\"z\")" ~ op ~ "s);");
    call.setObject(self);
}

private void _opBinaryScalarRightVec3(string op)(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    mixin("self.setReal(\"z\", s" ~ op ~ "v.getReal(\"z\"));");
    call.setObject(self);
}

private void _opBinaryCompareVec3(string op)(GrCall call) {
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
            ~ op ~ "v2.getReal(\"y\") &&
        v1.getReal(\"z\")"
            ~ op ~ "v2.getReal(\"z\"));");
}

// Utility ------------------------------------------
private void _vec3_one(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", 1f);
    self.setReal("y", 1f);
    self.setReal("z", 1f);
    call.setObject(self);
}

private void _vec3_half(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", .5f);
    self.setReal("y", .5f);
    self.setReal("z", .5f);
    call.setObject(self);
}

private void _vec3_up(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("y", 1f);
    call.setObject(self);
}

private void _vec3_down(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("y", -1f);
    call.setObject(self);
}

private void _vec3_left(GrCall call) {
    GrObject self = call.createObject("vec3");
    if (!self) {
        call.raise("UnknownClass");
        return;
    }
    self.setReal("x", -1f);
    call.setObject(self);
}

private void _vec3_right(GrCall call) {
    GrObject self = call.createObject("vec3");
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
    call.setReal(self.getReal("z"));
}

private void _isZero(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setBool(self.getReal("x") == 0f && self.getReal("y") == 0f && self.getReal("z") == 0f);
}

// Operations ------------------------------------------
private void _abs(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", abs(self.getReal("x")));
    v.setReal("y", abs(self.getReal("y")));
    v.setReal("z", abs(self.getReal("z")));
    call.setObject(v);
}

private void _ceil(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", ceil(self.getReal("x")));
    v.setReal("y", ceil(self.getReal("y")));
    v.setReal("z", ceil(self.getReal("z")));
    call.setObject(v);
}

private void _floor(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", floor(self.getReal("x")));
    v.setReal("y", floor(self.getReal("y")));
    v.setReal("z", floor(self.getReal("z")));
    call.setObject(v);
}

private void _round(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", round(self.getReal("x")));
    v.setReal("y", round(self.getReal("y")));
    v.setReal("z", round(self.getReal("z")));
    call.setObject(v);
}

private void _sum(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    call.setReal(self.getReal("x") + self.getReal("y") + self.getReal("z"));
}

private void _sign(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", self.getReal("x") >= 0f ? 1f : -1f);
    v.setReal("y", self.getReal("y") >= 0f ? 1f : -1f);
    v.setReal("z", self.getReal("z") >= 0f ? 1f : -1f);
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
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", v2.getReal("x") * weight + v1.getReal("x") * (1f - weight));
    v.setReal("y", v2.getReal("y") * weight + v1.getReal("y") * (1f - weight));
    v.setReal("z", v2.getReal("z") * weight + v1.getReal("z") * (1f - weight));
    call.setObject(v);
}

private void _approach(GrCall call) {
    GrObject v1 = call.getObject(0);
    GrObject v2 = call.getObject(1);
    if (!v1 || !v2) {
        call.raise("NullError");
        return;
    }
    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    const GrReal x1 = v1.getReal("x");
    const GrReal y1 = v1.getReal("y");
    const GrReal z1 = v1.getReal("z");
    const GrReal x2 = v2.getReal("x");
    const GrReal y2 = v2.getReal("y");
    const GrReal z2 = v2.getReal("z");
    const GrReal step = call.getReal(2);
    v.setReal("x", x1 > x2 ? max(x1 - step, x2) : min(x1 + step, x2));
    v.setReal("y", y1 > y2 ? max(y1 - step, y2) : min(y1 + step, y2));
    v.setReal("z", z1 > z2 ? max(z1 - step, z2) : min(z1 + step, z2));
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
    const GrReal pz = v1.getReal("z") - v2.getReal("z");
    call.setReal(std.math.sqrt(px * px + py * py + pz * pz));
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
    const GrReal pz = v1.getReal("z") - v2.getReal("z");
    call.setReal(px * px + py * py + pz * pz);
}

private void _magnitude(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal x = self.getReal("x");
    const GrReal y = self.getReal("y");
    const GrReal z = self.getReal("z");
    call.setReal(std.math.sqrt(x * x + y * y + z * z));
}

private void _magnitudeSquared(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal x = self.getReal("x");
    const GrReal y = self.getReal("y");
    const GrReal z = self.getReal("z");
    call.setReal(x * x + y * y + z * z);
}

private void _normalize(GrCall call) {
    GrObject self = call.getObject(0);
    if (!self) {
        call.raise("NullError");
        return;
    }
    const GrReal x = self.getReal("x");
    const GrReal y = self.getReal("y");
    const GrReal z = self.getReal("z");
    const GrReal len = std.math.sqrt(x * x + y * y + z * z);
    if (len == 0) {
        self.setReal("x", len);
        self.setReal("y", len);
        self.setReal("z", len);
        return;
    }
    self.setReal("x", x / len);
    self.setReal("y", y / len);
    self.setReal("z", y / len);
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
    GrReal z = self.getReal("z");
    const GrReal len = std.math.sqrt(x * x + y * y + z * z);

    if (len == 0) {
        x = len;
        y = len;
        z = len;
        return;
    }
    x /= len;
    y /= len;
    z /= len;

    GrObject v = call.createObject("vec3");
    if (!v) {
        call.raise("UnknownClass");
        return;
    }
    v.setReal("x", x);
    v.setReal("y", y);
    v.setReal("z", z);
    call.setObject(v);
}

private void _fromArray(GrCall call) {
    GrRealArray array = call.getRealArray(0);
    if (array.data.length == 3) {
        GrObject self = call.createObject("vec3");
        if (!self) {
            call.raise("UnknownClass");
            return;
        }
        self.setReal("x", array.data[0]);
        self.setReal("y", array.data[1]);
        self.setReal("z", array.data[2]);
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
    call.setString("vec3(" ~ to!GrString(
            self.getReal("x")) ~ ", " ~ to!GrString(
            self.getReal(
            "y")) ~ ", " ~ to!GrString(self.getReal("z")) ~ ")");
}

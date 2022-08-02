module magia.script.common;

import grimoire;
import magia.core;

package void loadMagiaLibCommon(GrLibrary library) {
    GrType splineType = library.addEnum("Spline", [
            "linear",
            "sineIn",
            "sineOut",
            "sineInOut",
            "quadIn",
            "quadOut",
            "quadInOut",
            "cubicIn",
            "cubicOut",
            "cubicInOut",
            "quartIn",
            "quartOut",
            "quartInOut",
            "quintIn",
            "quintOut",
            "quintInOut",
            "expIn",
            "expOut",
            "expInOut",
            "circIn",
            "circOut",
            "circInOut",
            "backIn",
            "backOut",
            "backInOut",
            "elasticIn",
            "elasticOut",
            "elasticInOut",
            "bounceIn",
            "bounceOut",
            "bounceInOut"]);
}
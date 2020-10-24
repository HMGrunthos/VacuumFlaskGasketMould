cylinderFaceApprox = 400;
embeddingDepth = 0.01;

module stopperMould(topR, bottomR, height, wallThickness) {
    translate([0, 0, (height + 2*wallThickness)/2]) {
        difference() {
            linear_extrude(height = height + 2*wallThickness, center = true) {
                circle(r = topR + wallThickness);
            }
            union() {
                translate([0, 0, height/2 + wallThickness/2]) { // Mould walls
                    cylinder(h = wallThickness + 2*embeddingDepth, r1 = topR, r2 = topR, center = true, $fn = cylinderFaceApprox);
                }
                cylinder(h = height, r1 = bottomR, r2 = topR, center = true, $fn = cylinderFaceApprox);
            }
        }
    }
}

module centralPlug(depth, contraction, wallThickness, maxRadius) {
    scale([scale, scale, 1]) {
        difference() {
            translate([0, 0, wallThickness/2 + depth/2 + contraction]) {
                cylinder(depth - 2*contraction, r1 = maxRadius, r2 = maxRadius, center = true, $fn = cylinderFaceApprox);
            }
            //children();
        }
    }
}

module cast(height, baseHeight) {
    difference() {
        translate([0, 0, baseHeight]) {
            linear_extrude(height = height, center = false) {
                scale([0.99, 0.99, 1]) {
                    projection() {
                        children();
                    }
                }
            }
        }
        children();
    }
}

stopperHeight = 36;
stopperBaseD = 102.55;
stopperTopD = 112.55;

mouldWallThickness = 2;

centralContraction = 4;
centralScale = 0.9;

// Inner plug
/*color([0, 0, 1, 0.6]) {
    centralPlug(stopperHeight, centralContraction, mouldWallThickness, stopperTopD/2)
        stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
}*/
/*
// Inner plug mould
color([0, 1, 0, 0.6]) {
    difference() {
        difference() {
            translate([0, 0, mouldWallThickness/2]) {
                cylinder(centralPlugDepth + mouldWallThickness*2, r1 = stopperTopD/2, r2 = stopperTopD/2, center = true, $fn = cylinderFaceApprox);
            }
            union() {
                translate([0, 0, centralPlugDepth/2 + mouldWallThickness]) {
                    linear_extrude(height = mouldWallThickness + 2*embeddingDepth, center = true) {
                        projection() {
                            centralPlug(centralPlugDepth, centralScale, mouldWallThickness, stopperTopD/2)
                                stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
                        }
                    }
                }
                centralPlug(centralPlugDepth, centralScale, mouldWallThickness, stopperTopD/2)
                    stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
            }
        }
        stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
    }
}*/

// Stopper
color([0, 1, 1, 0.6]) {
    cast(stopperHeight, mouldWallThickness)
        stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
}

// Mould
color([1, 0, 0, 0.6]) {
    stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
}
cylinderFaceApprox = 400;
embeddingDepth = 0.01;

module stopperMould(topR, bottomR, height, wallThickness) {
    difference() {
        cylinder(h = height + wallThickness, r1 = topR + wallThickness, r2 = topR + wallThickness, center = false);
        translate([0, 0, wallThickness]) {
            cylinder(h = height + embeddingDepth, r1 = bottomR, r2 = topR, center = false, $fn = cylinderFaceApprox);
        }
    }
}

stopperHeight = 36;
stopperBaseD = 102.55;
stopperTopD = 112.55;

mouldWallThickness = 2;

stopperMould(stopperTopD/2, stopperBaseD/2, stopperHeight, mouldWallThickness);
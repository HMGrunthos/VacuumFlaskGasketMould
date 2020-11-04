cylinderFaceApprox = 400;
embeddingDepth = 0.01;

module stopper(baseR, tanFaceAngle, height) {
    topR = baseR + tanFaceAngle * height;
    //echo(topR);
    //echo(baseR);
    cylinder(h = height, r1 = baseR, r2 = topR, center = false, $fn = cylinderFaceApprox);
}

module stopperMould(baseR, tanFaceAngle, height, wallThickness) {
   difference() {
        linear_extrude(height = height + 2*wallThickness, center = false) { // Stopper and lip cut from mould block
            topR = baseR + tanFaceAngle * height;
            circle(r = topR + wallThickness);
        }
        translate([0, 0, mouldWallThickness - embeddingDepth])
            union() {
                stopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth); // A stopper model
                translate([0, 0, height + embeddingDepth]) // Joined to a depth indicator/lip
                    linear_extrude(height = mouldWallThickness + 2*embeddingDepth, center = false)
                        projection()
                            stopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth);
            }
    }
}

module stopperMouldWalls(baseR, tanFaceAngle, height, wallThickness) {
   difference() {
        linear_extrude(height = height + 1*wallThickness, center = false) { // Stopper and lip cut from mould block
            topR = baseR + tanFaceAngle * height;
            circle(r = topR + wallThickness);
        }
        translate([0, 0, 0*mouldWallThickness - embeddingDepth])
            union() {
                stopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth); // A stopper model
                translate([0, 0, height + embeddingDepth]) // Joined to a depth indicator/lip
                    linear_extrude(height = mouldWallThickness + 2*embeddingDepth, center = false)
                        projection()
                            stopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth);
            }
    }
}

module stopperMouldLid(height, wallThickness, interferenceTol) {
    difference() {
        union() {
            translate([0, 0, height - 3 + embeddingDepth])
                cylinder(h = 3 + embeddingDepth, r1 = 45, r2 = 45);
            translate([0, 0, 1*height + 0*mouldWallThickness - embeddingDepth])
                linear_extrude(height = 2*wallThickness + embeddingDepth, center = false)
                    hull()
                        scale([1.04, 1.04, 0])
                            projection()
                                children();
        }
        /*
        {
            topR = baseR + tanFaceAngle * height;
            translate([0, 0, height - wallThickness + interferenceTol])
                linear_extrude(2*wallThickness)
                    difference() {
                        circle(r = topR + wallThickness + interferenceTol);
                        circle(r = topR - interferenceTol);
                    }
        }*/
        translate([0, 0, height - wallThickness])
            minkowski() {
            // union() {
                linear_extrude(height = 2*wallThickness + embeddingDepth, center = false)
                        projection()
                            intersection() {
                                translate([0, 0, height])
                                    cylinder(r1 = 100, r2 = 100, h = 1, center = true);
                                children();
                            }
                cylinder(r = interferenceTol/2, h = embeddingDepth, $fn = 20);
            }
    }

            intersection() {
                translate([0, 0, height])
                    cylinder(r1 = 100, r2 = 100, h = 1, center = true);
                children();
            }

}

module centralPlug(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction) {
    innerBaseOffset = (stopperHeight - innerHeight)/2 - embeddingDepth;
    innerBaseR = baseR + tanFaceAngle * innerBaseOffset - contraction;
    translate([0, 0, innerBaseOffset])
        stopper(innerBaseR, tanFaceAngle, innerHeight + 2*embeddingDepth);
}

module centralPlugMould(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction, mouldWallThickness, legRadius) {
    intersection() {
        cast(stopperHeight, mouldWallThickness) // And constained within the outer mould
            stopperMould(stopperBaseD/2-contraction+mouldWallThickness, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
        translate([0, 0, mouldWallThickness]) {
            difference() {
                union() {
                    translate([0, 0, (stopperHeight - innerHeight)/2 - mouldWallThickness - embeddingDepth]) // Extent of linear region as cylinder
                        linear_extrude(height = innerHeight + 2*embeddingDepth + 2*mouldWallThickness, center = false)
                            scale([2, 2, 1])
                                projection()
                                        centralPlug(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction);
                    /*
                    for(a = [0:90:360]) { // Joined to a set of legs
                        translate([(baseR - contraction)*sin(a), (baseR - contraction)*cos(a), 0])
                            cylinder(h = (stopperHeight - innerHeight)/2, r1 = legRadius, r2 = legRadius);
                    }
                    */
                }
                union() { // Inner region and lip
                    translate([0, 0, stopperHeight/2 + innerHeight/2 - embeddingDepth])
                        linear_extrude(height = mouldWallThickness + 3*embeddingDepth, center = false)
                            projection()
                                centralPlug(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction);
                    centralPlug(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction);
                }
            }
        }
    }
}

module cast(height, baseHeight) {
    difference() {
        translate([0, 0, baseHeight - embeddingDepth]) {
            linear_extrude(height = height + 2*embeddingDepth, center = false) {
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

stopperHeight = 42+6;
stopperBaseD = 101.5 + 4;
//stopperTopD = stopperBaseD + (42+2*2)*((107.5-105.5)/2)/(22 - 5) +3.1;
stopperTopD = 111.25;

echo(stopperBaseD);
echo(stopperTopD);
echo(stopperHeight);

innerVolumeContraction = 5;
innerVolumeHeight = stopperHeight - innerVolumeContraction*2;
innnerLegRadius = 4;
tanStopperFaceAngle = (stopperTopD - stopperBaseD)/(2*stopperHeight);

mouldWallThickness = 1;
/*
// Assembled filler
FillerBase = 101.5;
FillerTop = 105.5;
FillerHeight = 42;
color([1, 0, 1, 0.3])
    translate([0, 0, 3 + 0*mouldWallThickness])
        stopper(FillerBase/2, (FillerTop - FillerBase)/(2*FillerHeight), FillerHeight);
*/
// Explicit stopper
/*
color([1, 1, 0, 0.3])
    translate([0, 0, 0*mouldWallThickness])
        stopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);
*/
// Stopper cast from mould
/*
color([1, 0, 0, 0.3])
    cast(stopperHeight, mouldWallThickness)
        stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
*/

color([1, 0, 0, 0.3])
    stopperMouldLid(stopperHeight, mouldWallThickness, 0.3)
        stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
/*
// Outer mould
color([0, 1, 0, 0.3])
    stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
*/
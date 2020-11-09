cylinderFaceApprox = 400;
embeddingDepth = 0.01;

ribDepth = 0.75;
ribSpacing = 4;
ribAspect = 0.725;

teardropAngle = 60;

interferenceTol = 0.4; // Allow 0.3mm for fitting the outer mould into the lid

enableRibs = true;

module teardrop(radius, angle) {
    union() {
        hull() {
            circle(r = radius, $fn = 30);
            polygon(points = [[-radius/sin(angle/2), 0],
                              [-radius*sin(angle/2), radius*cos(angle/2)],
                              [-radius*sin(angle/2), -radius*cos(angle/2)]]);
        }
    }
}

module stopper(baseR, tanFaceAngle, height) {
    topR = baseR + tanFaceAngle * height;
    cylinder(h = height, r1 = baseR, r2 = topR, center = false, $fn = cylinderFaceApprox);
}

module ribbedStopper(baseR, tanFaceAngle, height) {
    faceAngle = atan(tanFaceAngle);
    nStacks = floor((height - ribSpacing)/ribSpacing);
    intersection() {
        stopper(baseR, tanFaceAngle, height); // Intersected with an intended size stopper
        union() {
            stopper(baseR - ribDepth, tanFaceAngle, height); // Unioned with a slightly shrunken stopper
            tdRadius = (ribSpacing*ribAspect)/(1+cos(faceAngle)/sin(teardropAngle/2));
            for(baseHeight = [ribSpacing*(ribAspect):ribSpacing:((nStacks)*ribSpacing)]) { // For each ribs
                //baseHeight = 0;
                baseOffset = baseHeight + ribSpacing * (1 - ribAspect);
                baseRib = baseR - ribDepth + tanFaceAngle * baseOffset;

                rotate_extrude(angle = 360, $fn = cylinderFaceApprox) {
                    translate([0, baseOffset, 0]) {
                        hull() {
                            union() {
                                translate([baseRib, tdRadius, 0])
                                    rotate([0, 0, -90 - faceAngle])
                                        teardrop(tdRadius, teardropAngle);
                                translate([baseRib, tdRadius, 0])
                                    rotate([0, 0, 90 - faceAngle])
                                        teardrop(tdRadius, teardropAngle);
                                square(size = [baseRib + 1*(ribSpacing*ribAspect - tdRadius)*tanFaceAngle, ribSpacing*ribAspect]);
                            }
                        }
                    }
                }
            }
        }
    }
}

module stopperMould(baseR, tanFaceAngle, height, wallThickness) {
   union() {
        linear_extrude(height = wallThickness + embeddingDepth, center = false) { // A closed base for the mould
            topR = baseR + tanFaceAngle * height;
            circle(r = topR + wallThickness);
        }
        translate([0, 0, mouldWallThickness])
            stopperMouldWalls(baseR, tanFaceAngle, height, wallThickness);
    }
}

module stopperMouldWalls(baseR, tanFaceAngle, height, wallThickness) {
   difference() {
        linear_extrude(height = height + 1*wallThickness, center = false) { // 'Blank' From which the mould is cut
            topR = baseR + tanFaceAngle * height;
            circle(r = topR + wallThickness);
        }
        union() {
            translate([0, 0, -embeddingDepth])
                if(enableRibs) {
                    ribbedStopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth); // A stopper model
                } else {
                    stopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth); // A stopper model
                }
            translate([0, 0, height - embeddingDepth]) // Joined to a depth indicator/lip
                linear_extrude(height = mouldWallThickness + 2*embeddingDepth, center = false)
                    projection()
                        if(enableRibs) {
                            stopper(baseR - tanFaceAngle*embeddingDepth - ribDepth, tanFaceAngle, height + 2*embeddingDepth);
                        } else {
                            stopper(baseR - tanFaceAngle*embeddingDepth, tanFaceAngle, height + 2*embeddingDepth);
                        }
        }
    }
}

module stopperMouldLid(height, wallThickness, innerPlugOffset, diasR) {
    difference() {
        union() {
            translate([0, 0, height - innerPlugOffset])
                cylinder(h = innerPlugOffset + embeddingDepth, r1 = diasR, r2 = diasR);
            translate([0, 0, 1*height - embeddingDepth])
                linear_extrude(height = 2*wallThickness + embeddingDepth, center = false)
                    hull()
                        scale([1.04, 1.04, 0])
                            projection()
                                children();
        }
        translate([0, 0, height - wallThickness])
            linear_extrude(height = 2*wallThickness + embeddingDepth, center = false)
                minkowski() {
                    projection()
                        intersection() {
                            translate([0, 0, height])
                                cylinder(r1 = 100, r2 = 100, h = wallThickness + embeddingDepth, center = false);
                            children();
                        }
                    circle(r = interferenceTol/2);
                }
    }
}

/*
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
                    //for(a = [0:90:360]) { // Joined to a set of legs
                    //    translate([(baseR - contraction)*sin(a), (baseR - contraction)*cos(a), 0])
                    //        cylinder(h = (stopperHeight - innerHeight)/2, r1 = legRadius, r2 = legRadius);
                    //}
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
}*/

module cast(height, baseHeight, castOffset) {
    difference() {
        translate([0, 0, castOffset - embeddingDepth]) {
            linear_extrude(height = height + 2*embeddingDepth, center = false) {
                scale([0.99, 0.99, 1]) {
                    hull() {
                        projection() {
                            children();
                        }
                    }
                }
            }
        }
        children();
    }
}

module sliceCentre() {
    projection() {
        rotate([90, 0, 0]) {
            intersection() {
                children();
                rotate([-90, 0, 0]) {
                    linear_extrude(height = 1e-12, center = false) {
                        minkowski() {
                            hull()
                                projection()
                                    rotate([90, 0, 0])
                                        children();
                            square(size = [1, 1]);
                        }
                    }
                }
            }
        }
    }
}

module minkowskiDifference2D() {
    // Subtract from the original object a bigger object with a Minkowski summed (->reduced) hole
    difference() {
        children(0);
        // Minkowski sum of the negative initial object 
        minkowski() {
            // make a hollow object with a hole that corresponds to the initial object
            difference() {
                // increase the size of initial object using Minkowski sum
                minkowski() {
                    children(0);
                    square(size = [20, 20], center = true);
                }
                // now remove initial object
                children(0);
            }
            children(1);
        }
    }
}

module outlineSample(borderThickness) {
    rotate([-90, 0, 0]) {
        linear_extrude(height = 1, center = false) {
            union() {
                intersection() {
                    sliceCentre()
                        children(0);
                    translate([0, -stopperHeight/2 - mouldWallThickness, 0]) {
                        union() {
                            square(size = [borderThickness, 1000], center = true);
                            square(size = [1000, borderThickness], center = true);
                        }
                    }
                }
                difference() {
                    sliceCentre()
                        children(0);
                    minkowskiDifference2D() {
                        sliceCentre()
                            children(0);
                        circle(r = borderThickness, $fn = 12);
                    }
                }
            }
        }
    }
}


innerPlugOffset = 2;

stopperHeight = 42 + innerPlugOffset*2;
stopperBaseD = 101.5 + 4;
//stopperTopD = stopperBaseD + (42+2*2)*((107.5-105.5)/2)/(22 - 5) +3.1;
stopperTopD = 111.25;

innerVolumeContraction = 5;
innerVolumeHeight = stopperHeight - innerVolumeContraction*2;
innnerLegRadius = 4;
tanStopperFaceAngle = (stopperTopD - stopperBaseD)/(2*stopperHeight);

innerDias = 80;
mouldWallThickness = 1;

/*
// Stopper cast from mould
color([1, 0, 0, 0.3])
    cast(stopperHeight, mouldWallThickness)
        stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
*/

// Generate sample sections
color([0, 1, 0])
    outlineSample(5)
        //ribbedStopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);
        cast(stopperHeight, mouldWallThickness, 0*mouldWallThickness)
            union() {
                stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
                stopperMouldLid(stopperHeight, mouldWallThickness, innerPlugOffset, innerDias/2)
                    stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
            }

color([1, 0, 1])
    outlineSample(1)
        //stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
        stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);

// All in one mould (prefer wall and lid separately)
// stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
color([1, 0, 0])
    stopperMouldLid(stopperHeight, mouldWallThickness, innerPlugOffset, innerDias/2)
        stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);

/*
// Outer mould
color([0, 1, 0, 0.3])
    stopperMouldWalls(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
*/

showStopperAndFiller = true;
if(showStopperAndFiller) {
    // Assembled filler
    FillerBase = 101.5;
    FillerTop = 105.5;
    FillerHeight = 42;
    color([1, 0, 1, 0.3])
        translate([0, 0, innerPlugOffset + 0*mouldWallThickness])
            stopper(FillerBase/2, (FillerTop - FillerBase)/(2*FillerHeight), FillerHeight);

    // Explicit stopper
    color([1, 1, 0, 0.3])
    //color([1, 1, 0]);
        translate([0, 0, 0*mouldWallThickness])
            // stopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);
            ribbedStopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);
    
    // Explicit stopper
    color([0, 0, 0, 0.3])
    //color([1, 1, 0]);
        translate([0, 0, 0*mouldWallThickness])
            stopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);
            //ribbedStopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);
}

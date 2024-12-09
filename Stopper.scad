cylinderFaceApprox = 400;
embeddingDepth = 0.01;

module stopper(baseR, tanFaceAngle, height) {
	topR = baseR + tanFaceAngle * height;
	echo(topR);
	echo(baseR);
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

module centralPlug(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction) {
	innerBaseOffset = (stopperHeight - innerHeight)/2 - embeddingDepth;
	innerBaseR = baseR + tanFaceAngle * innerBaseOffset - contraction;
	translate([0, 0, innerBaseOffset])
		stopper(innerBaseR, tanFaceAngle, innerHeight + 2*embeddingDepth);
}

module centralPlugMould(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction, mouldWallThickness, legRadius) {
	intersection() {
		cast(stopperHeight, mouldWallThickness) // And constained within the outer mould
			stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);
		translate([0, 0, mouldWallThickness]) {
			difference() {
				union() {
					translate([0, 0, embeddingDepth + contraction - mouldWallThickness]) // Extent of linear region as cylinder
						linear_extrude(height = innerHeight + 2*mouldWallThickness + 0*contraction, center = false)
							scale([2, 2, 1])
								projection()
									centralPlug(baseR, tanFaceAngle, stopperHeight, innerHeight, contraction);
					for(a = [0:90:360]) { // Joined to a set of legs
						translate([(baseR - contraction)*sin(a), (baseR - contraction)*cos(a), 0])
						cylinder(h = (stopperHeight - innerHeight)/2, r1 = legRadius, r2 = legRadius);
					}
					cylinder(h = (stopperHeight - innerHeight)/2, r1 = legRadius, r2 = legRadius);
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

stopperHeight = 36;
stopperBaseD = 102.55;
stopperTopD = 112.55;
innerVolumeContraction = 5;
innerVolumeHeight = stopperHeight - innerVolumeContraction*2;
innnerLegRadius = 4;
tanStopperFaceAngle = (stopperTopD - stopperBaseD)/(2*stopperHeight);

mouldWallThickness = 2;

// Explicit central region of insulation
//color([1, 1, 0, 0.1])
//translate([0, 0, 1*mouldWallThickness])
//centralPlug(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, innerVolumeHeight, innerVolumeContraction);

// Explicit stopper
//color([0, 0, 1, 0.3])
//translate([0, 0, 1*mouldWallThickness])
//stopper(stopperBaseD/2, tanStopperFaceAngle, stopperHeight);

// Inner mould
//color([1, 0, 0, 0.3])
//centralPlugMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, innerVolumeHeight, innerVolumeContraction, mouldWallThickness, innnerLegRadius);

color([1, 0, 0, 0.3])
cast(stopperHeight, mouldWallThickness*0.9 + innerVolumeContraction)
centralPlugMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, innerVolumeHeight, innerVolumeContraction, mouldWallThickness, innnerLegRadius);

// Stopper cast from mould
//color([1, 0, 1, 0.3])
//cast(stopperHeight, mouldWallThickness)
//stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);

// Outer mould
//color([0, 1, 0, 0.3])
//stopperMould(stopperBaseD/2, tanStopperFaceAngle, stopperHeight, mouldWallThickness);

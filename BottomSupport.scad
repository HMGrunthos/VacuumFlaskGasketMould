baseOD = 47; // Outer diameter of base support
flaskBaseRadius = 167/2; // Radial diameter approximation to bottom of vacuum flask
outerHeight = 13; // Height of outer most mould wall
rimThickness = 9; // Wall thickness of finished hollow bung

wallSupportHeight = 3.5; // Height of mounting points for removable mould walls

mouldWallThickness = 2;

interferenceTol = 0.1; // Ammount of space to leave where we want something to be an 'slot in' fit

faceApprox = 400;
embeddingDepth = 0.01;

spTuncHlfAng = flaskBaseRadius * cos(asin((baseOD/2)/flaskBaseRadius));

module walls2D() {
    translate([baseOD/2, 0, 0]) square(size = [mouldWallThickness, outerHeight]);
    translate([baseOD/2 - rimThickness - mouldWallThickness, 0, 0]) square(size = [mouldWallThickness, outerHeight]);
}

module wallSupports2D() {
    translate([baseOD/2 + mouldWallThickness, -mouldWallThickness, 0]) square(size = [mouldWallThickness, wallSupportHeight + mouldWallThickness]);
    translate([baseOD/2 - rimThickness - 2*mouldWallThickness, -mouldWallThickness, 0]) square(size = [mouldWallThickness, wallSupportHeight + mouldWallThickness]);
}

module mouldBase2D() {
    translate([0, -mouldWallThickness, 0]) square(size = [baseOD/2 + 2*mouldWallThickness, mouldWallThickness]);
}

module mouldMask2D() {
    translate([baseOD/2 - rimThickness - 2*mouldWallThickness - embeddingDepth, -mouldWallThickness - embeddingDepth, 0]) square(size = [4*mouldWallThickness + rimThickness + 2*embeddingDepth, mouldWallThickness + outerHeight + 2*embeddingDepth]);
}

module mould3DOverall() {
    rotate_extrude(angle = 360, $fn = faceApprox)
        translate([0, mouldWallThickness, 0])
            intersection () {
                union() {
                    walls2D();
                    wallSupports2D();
                    mouldBase2D();

                    translate([0, -spTuncHlfAng, 0]) circle(r = flaskBaseRadius, $fn = faceApprox);
                }
                mouldMask2D();
            }
}

module mould3DWalls() {
    rotate_extrude(angle = 360, $fn = faceApprox)
        translate([0, mouldWallThickness, 0])
            intersection () {
                walls2D();
                mouldMask2D();
            }
}

module mould3DBaseMount() {
    rotate_extrude(angle = 360, $fn = faceApprox)
        translate([0, mouldWallThickness, 0])
            difference() {
                intersection () {
                    union() {
                        wallSupports2D();
                        mouldBase2D();

                        translate([0, -spTuncHlfAng, 0]) circle(r = flaskBaseRadius, $fn = faceApprox);
                    }
                    mouldMask2D();
                }
                minkowski() {
                    walls2D();
                    translate([-interferenceTol/2, -embeddingDepth/2, 0]) square(size = [interferenceTol, embeddingDepth]);
                }
            }
}

//color([1, 1, 0, 0.6])
mould3DOverall(); // The overall mould
//mould3DWalls(); // Just the mould walls
//mould3DBaseMount(); // The mould base minus the walls

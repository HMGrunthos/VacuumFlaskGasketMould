id = 128.7-2.5; // Controls the inner diameter of the gasket (2.5mm is the ammount of diameter reduction intended to give a slight stretch fit)
wallThickness = 6; // Controls the thickness of the gasket in the radial direction
mouldWallHeight = 10; // Controls the depth of the gasket orthogonal to the radial plane

// Mould build parameters
mouldWallThicknessTop = 2;
mouldWallThicknessBottom = 3;
baseFooting = 3;
baseHeight = 2;
cylinderFaceApprox = 400;

od = id + wallThickness*2; // Outer diameter is calculated from id and thickness

union() {
    // Build a base
    linear_extrude(height = baseHeight + 0.01) {
        // A simple track baseHeight(mm) in height and baseFooting(mm) wider than the base of the mould walls
        difference() {
            footingOR = (od + mouldWallThicknessBottom*2 + baseFooting)/2;
            footingIR = (id - mouldWallThicknessBottom*2 - baseFooting)/2;
            circle(r = footingOR);
            circle(r = footingIR);
        }
    }

    // Build mould walls
    translate([0, 0, baseHeight + mouldWallHeight/2]) {
        union() {
            // Bulid the outer mould wall
            difference() {
                outerWallBottomRadius = od/2 + mouldWallThicknessBottom;
                outerWallTopRadius = od/2 + mouldWallThicknessTop;
                outerWallInnerRadius = od/2;
                cylinder(h = mouldWallHeight, r1 = outerWallBottomRadius, r2 = outerWallTopRadius, center = true);
                cylinder(h = mouldWallHeight + 0.01, r1 = outerWallInnerRadius, r2 = outerWallInnerRadius, center = true, $fn = cylinderFaceApprox);
            }
            
            // Bulid the inner mould wall
            difference() {
                innerWallBottomRadius = id/2 - mouldWallThicknessBottom;
                innerWallTopRadius = id/2 - mouldWallThicknessTop;
                innerWallOuterRadius = id/2;
                
                cylinder(h = mouldWallHeight, r1 = innerWallOuterRadius, r2 = innerWallOuterRadius, center = true, , $fn = cylinderFaceApprox);
                cylinder(h = mouldWallHeight + 0.01, r1 = innerWallBottomRadius, r2 = innerWallTopRadius, center = true);
            }
        }
    }
 }

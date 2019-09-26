module servo(model="MG90S",forCutout=false,shim=0.05) {
    if (model == "MG90S") {
      bodyDims=[22.8,12.6,18.1];
      cableDims=[20,7.8,3.5];
      flangeDims=[32.44,12.6,2.9];
      topDims=[22.6,12.6,1.0];
      screwHoles=[27.80,0,1];
      topDimples=[[0,5.75,5.6],[9,2.5,5.6]];
      knurledStud=[0,2.4,4.1];
      if (forCutout) {
        minkowski() {
          cube([shim,shim,shim]);
          _servo(bodyDims,cableDims,flangeDims,topDims,screwHoles,topDimples,knurledStud,forCutout);
        }
      } else {
      	color("LightBlue") _servo(bodyDims,cableDims,flangeDims,topDims,screwHoles,topDimples,knurledStud,forCutout);
      }
    }
  }

module _servo(bodyDims,cableDims,flangeDims,topDims,screwHoles,topDimples,knurledStud,forCutout) {
  translate([-topDimples[0][0]-topDimples[0][1],
    -bodyDims[1]/2,
    -bodyDims[2]-flangeDims[2]-topDims[2]-topDimples[0][2]-knurledStud[2]]) {
    if (forCutout) {
      translate([-cableDims[0],(bodyDims[1]-cableDims[1])/2,cableDims[2]]) 
      cube([cableDims[0],cableDims[1],cableDims[1]]);
    }
		cube(bodyDims);
    if (forCutout) {
		  translate([(bodyDims[0]-flangeDims[0])/2,
                (bodyDims[1]-flangeDims[1])/2,
                bodyDims[2]]) union() {
			  cube(flangeDims);
		    for (hole=[[(flangeDims[0]-screwHoles[0])/2,(flangeDims[1]-screwHoles[1])/2],
                   [(flangeDims[0]-screwHoles[0])/2,(flangeDims[1]+screwHoles[1])/2],
                   [(flangeDims[0]+screwHoles[0])/2,(flangeDims[1]-screwHoles[1])/2],
                   [(flangeDims[0]+screwHoles[0])/2,(flangeDims[1]+screwHoles[1])/2]]) {
          translate([hole[0],hole[1],-5]) cylinder(r=screwHoles[2],h=flangeDims[2]+10,$fn=45);
        }
      }
    } else {
		  translate([(bodyDims[0]-flangeDims[0])/2,
              (bodyDims[1]-flangeDims[1])/2,
              bodyDims[2]]) difference() {
			  cube(flangeDims);
		    for (hole=[[(flangeDims[0]-screwHoles[0])/2,(flangeDims[1]-screwHoles[1])/2],
                   [(flangeDims[0]-screwHoles[0])/2,(flangeDims[1]+screwHoles[1])/2],
                   [(flangeDims[0]+screwHoles[0])/2,(flangeDims[1]-screwHoles[1])/2],
                   [(flangeDims[0]+screwHoles[0])/2,(flangeDims[1]+screwHoles[1])/2]]) {
          translate([hole[0],hole[1],-1]) cylinder(r=screwHoles[2],h=flangeDims[2]+2,$fn=45);
        }
      }
    }
		translate([(bodyDims[0]-topDims[0])/2,
              (bodyDims[1]-topDims[1])/2,
              bodyDims[2]+flangeDims[2]]) cube(topDims);
    for(topDimple=topDimples) {
		  translate([(bodyDims[0]-topDims[0])/2+topDimple[0]+topDimple[1],
                  (bodyDims[1]+topDims[1])/4,
                  bodyDims[2]+flangeDims[2]+topDims[2]]) cylinder(r=topDimple[1],h=topDimple[2],$fn=45);
    }
		translate([(bodyDims[0]-topDims[0])/2+topDimples[0][0]+topDimples[0][1]+knurledStud[0],
              (bodyDims[1]+topDims[1])/4,
              bodyDims[2]+flangeDims[2]+topDims[2]+topDimples[0][2]]) cylinder(r=knurledStud[1],h=knurledStud[2],$fn=45);
	}
}

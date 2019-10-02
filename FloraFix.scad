include<servo.scad>

module fixleg() {
difference() {
union() {
translate([23.4,-16.4,0])rotate(-26.5) import("CE3_Flora_Leg.stl");
translate([11,0,10.825])cube([20,12.25,21.75],center=true);
translate([19,0,12.825])cube([4,12.25,25.75],center=true);
}
#translate([0,0,-7.75])rotate([180,0,0])servo(forCutout=true,shim=0.25);
translate([-8,0,11])cube([10,12.6,26],center=true);;
translate([5,0,5])cube([32,12.6,5],center=true);;
}

}

module fixbody() {
difference() {
union() {
rotate([90,0,0])translate([-77,-175.25,-8.5])import("flora_body.stl");
translate([24,-60,2.5])cube([10,100,5],center=true);
translate([-24,-60,2.5])cube([10,100,5],center=true);
for (x = [1,-1]) {for (y = [1,0,-1]) {
translate([39*x,-59.75+40*y,24.8])cube([8,12.6,2],center=true);;
}}
}
for (x = [1,-1]) {
for (y = [1,0,-1]) {
translate([40.5*x,-59.75+40*y,-7.75]){
rotate([180,0,90+90*x])servo(forCutout=true,shim=0.25);
translate([0,0,19])rotate([180,0,90+90*x])translate([-8,0,0])cube([10,12.6,26],center=true);;
}
}}
}
//rotate([90,0,0])translate([-77,-175.25,-8.5])import("Flora_Cover.stl");
//rotate([90,0,0])translate([-77,-185.25,-8.5])import("large_battery_cover.stl");
}

module fixknuckle() {
//#rotate([90,0,0])translate([4,-187,-17])import("Flora_Hip.stl");
difference() {
hull() {for (x=[1,-1]) {for (y=[1,-1]) {
translate([(22-10)*x+1,(21-10)*y,0])cylinder(h=18,r=10,center=true);
}}}
hull() {for (x=[1,-1]) {for (y=[1,-1]) {
translate([(17-6)*x-1,(16-6)*y,0])cylinder(h=26,r=6,center=true);
}}}
translate([-15,0,0])difference() {
cube([30,50,30],center=true);
translate([15,0,0])rotate([90,0,0])cylinder(r=9,h=60,center=true);
translate([15,0,0])rotate([0,45,0])translate([-4.5,0,4.5])cube([9,60,9],center=true);
translate([15,0,0])rotate([0,45,0])translate([4.5,0,-4.5])cube([9,60,9],center=true);}

//Pommel socket
translate([0,13,0])rotate([90,0,0])cylinder(r=2.5,h=10,center=true);
translate([-5,15,0])rotate([0,90,0])cylinder(r=2,h=10,center=true);

//Servo socket
translate([0,-15,0]) rotate([90,0,0]) {
cylinder(r=2.2,h=10,center=true);
translate([0,0,3])rotate([0,-135,0])cylinder(r=2.2,h=10);
cylinder(r=2.3,h=10,center=true);
cylinder(r=1.5,h=20,center=true);
}


//Cable passthrough
translate([20,0,0]) rotate([0,90,0]) cylinder(r=5,h=20,center=true);

// Pair lock
translate([26,0,0])cube([10,18.5,20],center=true);
}
}

//rotate([90,0,180])translate([0,0,-11])fixleg();
//fixbody();
fixknuckle();
//rotate([90,0,180])translate([-38,0,0])fixknuckle();
$fn=20;
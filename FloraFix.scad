include<servo.scad>

module fixleg() {
difference() {
union() {
translate([23.4,-16.4,0])rotate(-26.5) import("Flora_Leg.stl");
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
rotate([90,0,0])translate([-77,-175.25,-8.5])import("Flora_Body.stl");
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

module 18650_holder() {
translate([0,0,10])cube([21.2,77.6,20],center=true);
}

module fixbattery() {
union (){
difference () {
hull() {for (x=[1,-1]) {for (y=[1,-1]) {for (z=[0.125,1]) {
translate([25.5*x,38.8*y,20*z])sphere(r=4);
}}}}
//Battery space
translate([0,0,25])cube([60,90,10],center=true);
translate([0,0,11])cube([51,77.6,22],center=true);

//Fancies - slots
for (x=[1,-1]) {for (y=[1,-1]) {
translate([12*x,20*y,0]) hull() {for (q=[1,-1]) {
translate([8*q,0,0])cylinder(r=2,h=10,center=true);
}}
}}
//Fancies - holes
for (x=[1,0,-1]) {
translate([20*x,0,0])cylinder(r=5,h=10,center=true);
}
cube([40,5,10],center=true);
//Fancies - triangles
for (l=[[11,-5],[0,13.5],[-11,-5]]) {
translate([l[0],l[1],-5])linear_extrude(10) polygon([[0,0],[-4.5,-7.5],[4.5,-7.5]]);
}
}
//Attaching pegs
for (x=[0,1]) {for (y=[0,1]) {mirror([x,0,0]) {mirror([0,y,0]) {
translate([10,40.175,20]) hull() {
translate([-5.35,0,1.5])cylinder(r=4.45/2,h=3,center=true);
translate([7,0,1.5])cube([4,4.45,3],center=true);
}
}}}}
}
}

//rotate([90,0,180])translate([0,0,-11])fixleg();
//fixbody();
//fixknuckle();
//rotate([90,0,180])translate([-38,0,0])fixknuckle();
fixbattery();
$fn=20;

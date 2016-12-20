module wave() {
  n = h / (2 * r);
  for (i=[0:n]) {
    theta = i * 90 / n;
    dx = 2 * r * i;
    dy = h * sin(theta);
    translate([dx, dy, 0]) rotate([theta, 0, 0]) cylinder(h, r, r, $fn=100);
  }
}
module double_wave() {
  union() {
    wave();
    translate([h, 0, 0]) mirror([1, 0, 0]) wave();
  }
}
module wave2() {
  for (i=[0:n-1]) {
    theta = i * 45 / (n-1);
    a = h * tan(theta);
    b = h / cos(theta);
    new_h = sqrt(a * a + b * b);
    theta1 = acos(h / new_h);
    translate([0, -a, 0]) rotate([0, theta1, theta]) cylinder(new_h, r, r, $fn=100);
  }
}
r = 2;
h = 100;
n = 20;
double_wave();

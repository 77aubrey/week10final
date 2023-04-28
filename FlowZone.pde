class FlowZone
{
  public float X, Y, U, V;

  FlowZone(float x, float  y, float  u, float  v)
  {
    X = x;
    Y = y;
    U = u;
    V = v;
  }

  void xdraw()
  {
    if ((abs(U) + abs(V)) / 2.0 < UVCutoff) return;

    pushMatrix();
    pushStyle();
    stroke(255);
    fill(0, 0, 0, 80);
    translate(X, Y);
    line(0, 0, -U*3, -V*3);
    popStyle();
    popMatrix();
  }


  void draw()
  {
    if ((abs(U) + abs(V)) / 2.0 < UVCutoff) return;

    currentHue = random(360);
    if (allParticles.size() < maxParticles)
    {
      allParticles.add(new Particle(X, Y, U, V));

    }
  }
}


int colorSubtract(color c1, color c2) {
  return color2value(c1)-color2value(c2);
}


int color2value(color c) {

  int base=-16777216;

  int r=int(red(c));
  int g=int(green(c));
  int b=int(blue(c));

  return base+r*256*256+g*256+b;
}

class Particle {

  PVector pos = new PVector(0, 0);
  PVector vel;
  float h = currentHue;

  Particle(float x, float y, float velX, float velY) {
    this.pos.set(x, y);

    PVector lastPos = new PVector(pX, pY);
    x = pX; 
    y = pY;
    this.vel = new PVector(velX, velY);
    this.vel.sub(lastPos);
    this.vel.limit(50);
    this.vel.mult(random(0.3, 0.6));
  }

  void move() 
  {
    this.vel.mult(0.94);
    this.pos.add(this.vel);
  }
}

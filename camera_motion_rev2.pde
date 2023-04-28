import processing.video.*;

color[] currentImageData;
color[] lastImageData;

//if the average of U and V for a zone is lower than this value, it is not rendered.
float UVCutoff = 7;
ArrayList<Particle> allParticles;
float currentHue = 0;
int pX=0, pY=0;
int maxParticles = 80000;
import processing.video.*;
Capture video;

void setup()
{
  size(1920, 1080);
  colorMode(HSB, 360);
  allParticles = new ArrayList<Particle>();
  currentImageData = new color[1920*1080];
  lastImageData = new color[1920*1080];

  video = new Capture(this,1920,1080);
  video.start();
  strokeWeight(4);
}

void AdvanceBuffer()
{
  //lastImageData = currentImageData;
  if (video.available()) {
    video.read();
    video.loadPixels();
    for (int i = 0; i < 1920*1080; i++) {
      lastImageData[i]=currentImageData[i];
      currentImageData[i] = video.pixels[i];
    }
  }
  //currentImageData = ctx.getImageData(0, 0, 640, 480).data;
}

void draw()
{
//  image(video, 0, 0);
  background(255,0,0);
  AdvanceBuffer();

  ArrayList<FlowZone> fZones = calculateFlow(lastImageData, currentImageData);
  for (FlowZone fz : fZones) 
    fz.draw();

  //println(allParticles.size());

  for (int i = allParticles.size()-1; i > -1; i--) {

    Particle p = allParticles.get(i);

    if (p.vel.mag() < 1) 
    {
      allParticles.remove(p);
      //continue;
    }

    p.move();

    //stroke(p.h, 360, 360);
    stroke(0, 0, 255);
    strokeWeight(p.vel.mag()*1.25);

    point(p.pos.x, p.pos.y);
  }

  //fill(0);
 // noStroke();

  surface.setTitle(nf(allParticles.size()));
}


ArrayList<FlowZone> calculateFlow (color[] oldImage, color[] newImage) {
  ArrayList<FlowZone> zones = new ArrayList();
  if (oldImage == null)
    return zones;  
 // stroke(0,0, 360);
  int step = 8;
  int winStep = step * 2 + 1;

  float A2, A1B2, B1, C1, C2;
  float u, v, uu, vv;
  uu = vv = 0;
  int wMax = width - step - 1;
  int hMax = height - step - 1;
  int globalY, globalX, localY, localX;

  for (globalY = step + 1; globalY < hMax; globalY += winStep) 
  {
    for (globalX = step + 1; globalX < wMax; globalX += winStep) 
    {
      A2 = A1B2 = B1 = C1 = C2 = 0;

      for (localY = -step; localY <= step; localY++) 
      {
        for (localX = -step; localX <= step; localX++) 
        {
          int address = (globalY + localY) * width + globalX + localX;

          float gradX = red(newImage[(address - 1) * 1]) - red(newImage[(address + 1) * 1]);
          float gradY = red(newImage[(address - width) * 1]) - red(newImage[(address + width) * 1]);
          float gradT = red(oldImage[address * 1]) - red(newImage[address * 1]);

          //int gradX=colorSubtract(newImage[(address - 1) * 4], newImage[(address + 1) * 4]);
          //int gradY=colorSubtract(newImage[(address - width) * 4], newImage[(address + width) * 4]);
          //int gradT = colorSubtract(oldImage[address * 4],newImage[address * 4]);

          A2 += gradX * gradX;
          A1B2 += gradX * gradY;
          B1 += gradY * gradY;
          C2 += gradX * gradT;
          C1 += gradY * gradT;
        }
      }

      float delta = (A1B2 * A1B2 - A2 * B1);


      if (delta != 0) {
        /* system is not singular - solving by Kramer method */
        float Idelta = step / delta;
        float deltaX = -(C1 * A1B2 - C2 * B1);

        float deltaY = -(A1B2 * C2 - A2 * C1);
        u = deltaX * Idelta;
        v = deltaY * Idelta;
      } else {
        /* singular system - find optical flow in gradient direction */
        float norm = (A1B2 + A2) * (A1B2 + A2) + (B1 + A1B2) * (B1 + A1B2);
        if (norm != 0) 
        {
          float IGradNorm = step / norm;
          float temp = -(C1 + C2) * IGradNorm;
          u = (A1B2 + A2) * temp;
          v = (B1 + A1B2) * temp;
        } else
        {
          u = v = 0;
        }
      }

      if (-winStep < u && u < winStep &&
        -winStep < v && v < winStep) {
        uu += u;
        vv += v;
        zones.add(new FlowZone(globalX, globalY, u, v));

        //line(globalX, globalY, globalX+u, globalY+v);
        //println(666);
      }
    }
  }

  return zones;
}

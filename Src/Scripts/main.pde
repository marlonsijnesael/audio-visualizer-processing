import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;


import       ddf.minim.analysis.*;
import       ddf.minim.*;

//------------------------------visual settings---------------------------------//
int          scale = 70;
int          cols, rows;
int          gridSize = 30;
int          sphereSize = 20;

//---------------------------------scalers--------------------------------------//
float        soundLevel;
float        soundScale;
float        colorScale;
float        colorMultiplier, soundMultiplier;

//--------------------------------files to load---------------------------------//
String[]     songs = { "blockades.mp3" };

//---------------------------------minim stuff----------------------------------//
FFT          fft;
FFT          fftLin;
FFT          fftLog;
AudioPlayer  player;
BeatDetect   beat;
Minim        minim;

//---------------------------------shapes used----------------------------------//
Grid         grid;
Grid         grid1;
PopSphere    sphere0;
PopSphere    sphere1;
PopSphere[] spheres;
PShape xy;
//--------------------------------colors used-----------------------------------//
PVector      purple = new PVector(240, 0, 255);
PVector      blue = new PVector(0, 191, 255);
PVector      red = new PVector(180, 0, 0);


PShape xSphere ;
public void setup() {
  //screen setup
  size(1840, 1000, P3D);
  frameRate(60);

  //create grid sizes
  cols = width / scale;
  rows = height / scale;

  //create instance of minim and set up minim classes
  minim = new Minim(this);
  player = minim.loadFile(songs[(int)random(0, songs.length)]);
  fft = new FFT(player.bufferSize(), player.sampleRate());
  fft.window(FFT.HAMMING);

  fftLog = new FFT( player.bufferSize(), player.sampleRate() );
  fftLog.logAverages( 22, 3 );

  beat = new BeatDetect();
  player.play();
  soundMultiplier = 20;
  colorMultiplier = 4;
}

public void draw() {
  background(0);

  //ambientLight(purple.x, purple.y, purple.z);

  //feed sound data into the fft, beat and scalers
  soundLevel = (player.right.level() + player.left.level()) / 2;
  soundScale = soundLevel * soundMultiplier;
  colorScale = soundLevel * colorMultiplier;
  fft.forward(player.mix);

  fftLog.forward( player.mix );
  beat.detect(player.mix);

  //  drawPyramid(100);

  //create shape instances

  float bass = fft.calcAvg(300, 500) ; // fft.calcAvg(minFreq, maxFreq)  
  float high =  fft.calcAvg(1000, 2000);



  grid1 = new Grid(gridSize, scale*2, rows, cols, blue);
  grid = new Grid(gridSize, scale*2, rows, cols, purple);

  //grid.Display(high, colorScale);
  print("sound: " + soundLevel);
  logband("Lines", 50, 0);
  logband("Spheres", 50,height/2);

  // circleGen(fftLog.avgSize());
  // grid1.Display(bass, colorScale);
}

void circleGen(float _multiplier) {

  float radius= 50;
  int numPoints=20;
  int numRows = 5;

  PVector[][] points = new PVector [numRows][numPoints];  
  // PVector[][] count = new PVector [numRows] [numPoints];
  for (int j = 0; j < numRows; j ++)
  {
    for (int i=0; i<numPoints; i++)
    {
      float angle= random(0, numPoints) + (TWO_PI/(float)numPoints);
      points[j][i] = new PVector(radius*sin(angle* i ) *( j * 2), radius*cos(angle* i ) * (j* 2));
    }
  }

  int counter = 1;
  for (int x = 0; x < numRows; x++) {
    for (int y = 0; y < numPoints; y++) {

      pushMatrix();
      translate(width/2, height/2);
      stroke(255);
      translate(points[x][y].x, points[x][y].y);
      noFill();
      sphere(x * fftLog.getAvg(x) /50);
      popMatrix();
      counter++;
    }
  }
}


void logband(String _type, int _offset, float _yPos ) {
  float avg = 0 ;
  for (int i = 0; i < fftLog.avgSize(); i++)
  {
    if (_type == "Lines") {
      avg = fftLog.getAvg(i) ;
      pushMatrix();
      stroke(purple.x * fftLog.getBand(i), purple.y * fftLog.getBand(i), purple.z * fftLog.getBand(i));
      strokeWeight(1 * avg / 10);
      int offSet = (i * _offset);
      line( offSet, offSet, width  - offSet, offSet);
      line( offSet, offSet, offSet, height - offSet);
      line( offSet, height - offSet, width  -  offSet, height - offSet);
      line(width -  offSet, offSet, width - offSet, height -  offSet);
      popMatrix();
    }

    if (_type == "Spheres") {

      pushMatrix();
      translate(i * 100, _yPos );
      noFill();
      stroke(purple.x * 10 / avg, purple.y * 10 / avg, purple.z * 10 / avg );

      //sphere(fftLog.getBand(i));
      ellipse(i * _offset, 0, fftLog.getBand(i), fftLog.getBand(i));
      popMatrix();
    }
  }
}

































PShape createSphere(float r, int detail) {
  textureMode(NORMAL);
  PShape sh = createShape();


  final float dA = TWO_PI / detail; // change in angle

  // process the sphere one band at a time
  // going from almost south pole to almost north
  // poles must be handled separately
  float theta2 = -PI/2+dA;
  float SHIFT = PI/2;
  float z2 = sin(theta2); // height off equator
  float rxyUpper = cos(theta2); // closer to equator
  for (int i = 1; i < detail; i++) {
    float theta1 = theta2; 
    theta2 = theta1 + dA;
    float z1 = z2;
    z2 = sin(theta2);
    float rxyLower = rxyUpper;
    rxyUpper = cos(theta2); // radius in xy plane
    sh.beginShape(QUAD_STRIP);
    sh.stroke(255);
    for (int j = 0; j <= detail; j++) {
      float phi = j * dA; //longitude in radians
      float xLower = rxyLower * cos(phi);
      float yLower = rxyLower * sin(phi);
      float xUpper = rxyUpper * cos(phi);
      float yUpper = rxyUpper * sin(phi);
      float u = phi/TWO_PI;
      sh.normal(xUpper, yUpper, z2);
      sh.vertex(r*xUpper, r*yUpper, r*z2, u, (theta2+SHIFT)/PI);    
      sh.normal(xLower, yLower, z1);
      sh.vertex(r*xLower, r*yLower, r*z1, u, (theta1+SHIFT)/PI);
    }
    sh.endShape();
  }
  return sh;
}












public void CreateTriangles() {
  pushMatrix();
  noStroke();
  //translate(0,20,0);
  rotateX(20);
  beginShape(TRIANGLES);
  vertex(0, 50 * soundScale);
  vertex(50 * soundScale, 0);
  vertex(100 * soundScale, 100 * soundScale);
  endShape();
  popMatrix();
}


//microphone input-------------------------------------------------------
//import processing.sound.*;
//AudioIn input;
//Amplitude analyzer;
//create audio components
//input = new AudioIn(this, 0);
//analyzer = new Amplitude(this);
//analyzer.input(input);

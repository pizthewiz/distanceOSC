/**
  OSC CONSTANTS
**/

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
int lastMillis=0;
int millisThreshold=1000;

/**
  ARDUINO CONSTANTS
**/
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;

int[] values = { Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW,
 Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW,
 Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW };

color off = color(4, 79, 111);
color on = color(84, 145, 158);

void setup() {
  size(470, 200);
  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.INPUT);
  
  // OSC
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",7777);
}

void draw() {
  background(off);
  stroke(on);
  
  for (int i = 0; i <= 13; i++) {
    if (values[i] == Arduino.HIGH)
      fill(on);
    else
      fill(off);
      
    rect(420 - i * 30, 30, 20, 20);
  }
  if(millis()-lastMillis>millisThreshold){
    readDistance();
    lastMillis=millis();
  }
}

void readDistance() {
  int pin=0;
  OscMessage myMessage = new OscMessage("/distance");
  myMessage.add(arduino.analogRead(pin));
  oscP5.send(myMessage, myRemoteLocation);
}

void mousePressed()
{
  int pin = (450 - mouseX) / 30;
 
  OscMessage myMessage = new OscMessage("/test");
  myMessage.add(pin);
  myMessage.add(arduino.analogRead(pin));
  oscP5.send(myMessage, myRemoteLocation);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("[OSC] ");
  print(theOscMessage.addrPattern());
  if(theOscMessage.checkTypetag("i")) {
    int val = theOscMessage.get(0).intValue();
    println(" " + val);
  }

  if(theOscMessage.checkTypetag("ii")) {
    int pin = theOscMessage.get(0).intValue();
    int val = theOscMessage.get(1).intValue();
    println(" pin "+pin+" is "+val);
  }
}

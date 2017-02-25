/*
  Reading a serial ASCII-encoded string.

 This sketch demonstrates the Serial parseInt() function.
 It looks for an ASCII string of comma-separated values.
 It parses them into ints, and uses those to fade an RGB LED.

 Circuit: Common-Cathode RGB LED wired like so:
 * Red anode: digital pin 3
 * Green anode: digital pin 5
 * Blue anode: digital pin 6
 * Cathode : GND

 created 13 Apr 2012
 by Tom Igoe
 
 modified 14 Mar 2016
 by Arturo Guadalupi

 This example code is in the public domain.
 */
#include <RedBot.h>
#include "notes.h"

RedBotSoftwareSerial XBee;


// Create a couple of constants for our pins.
const int buzzerPin = 9;
const int buttonPin = 12;
const int ledPin = 13;

int lBumperState;  // state variable to store the bumper value
int rBumperState;  // state variable to store the bumper value

RedBotMotors motors;
RedBotAccel accelerometer;
RedBotBumper lBumper = RedBotBumper(3);  // initialzes bumper object on pin 3
RedBotBumper rBumper = RedBotBumper(11); // initialzes bumper object on pin 11

String input;
 
void setup() {
  // initialize serial:
  XBee.begin(9600);
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
  beep();
  blink();
  beep();
  blink();
  beep();
  blink();
  Serial.println("\nHello, I am ready.\n");
}

void loop() {
  checkBumpers();
  
  // if there's any serial available, read it:
  while (XBee.available()) {
    
    delay(3);  //delay to allow buffer to fill 
    if (XBee.available() > 0) {
      char c = XBee.read();  //gets one byte from serial buffer

      beep();

      if (c == '\n') {
        blink();
        Serial.println("You said: " + input);
        processCommand();
        input = "";
      } else if (c == 'M' && input == "") {
        setMotorSpeed();
      } else {
        input += c;
      }
    } 
  }
}

void checkBumpers() {
  lBumperState = lBumper.read();  // default INPUT state is HIGH, it is LOW when bumped
  rBumperState = rBumper.read();  // default INPUT state is HIGH, it is LOW when bumped

  if (lBumperState == LOW) // left side is bumped/
  { 
    XBee.println("Left bumper hit");
  }

  if (rBumperState == LOW) // right side is bumped/
  { 
    XBee.println("Right bumper hit");
  }
}

void processCommand() {
  if (input == "move 1") {
    motors.drive(255);   // Turn on Left and right motors at full speed forward.
    delay(500);          // Waits for .5 seconds
    motors.stop();       // Stops both motors
  } else if (input == "sw") {
    playSmallWorld();
  } else if (input == "acc") {
    readAcceleromter();
  } else if (input == "stop") {
    motors.stop();  
  }
}

void setMotorSpeed() {
    int leftPower = XBee.parseInt();  // read in the next numeric value
    int rightPower = XBee.parseInt();
    leftPower = constrain(leftPower, -255, 255);  // constrain the data to -255 to +255
    rightPower = constrain(rightPower, -255, 255);
    motors.leftMotor(-leftPower);
    motors.rightMotor(rightPower);
    Serial.println("Set left motor to " + leftPower);
    Serial.println("Set right motor to " + rightPower);
}

void beep() {
  tone(buzzerPin, 2000);
  delay(50);
  noTone(buzzerPin);
}

void blink() {
  // Blink sequence
  digitalWrite(ledPin, HIGH); // Turns LED ON -- HIGH puts 5V on pin 13. 
  delay(500);             // delay(500) "pauses" the program for 500 milliseconds
  digitalWrite(ledPin, LOW);  // Turns LED OFF -- LOW puts 0V on pin 13.
  delay(500);             // delay(500) "pauses" the program for 500 milliseconds
  // The total delay period is 1000 ms, or 1 second.
}


void playSmallWorld()
{ 
  // we use a custom function below called playNote([note],[duration]) 
  // to play a note and delay a certain # of milliseconds. 
  //
  // Both notes and durations are #defined in notes.h -- WN = whole note, 
  // HN = half note, QN = quarter note, EN = eighth note, SN = sixteenth note.
  //
  playNote(noteG5, HN+QN);
  playNote(noteG5, QN);
  playNote(noteB5, HN);
  playNote(noteG5, HN);
  playNote(noteA5, HN+QN);
  playNote(noteA5, QN);
  playNote(noteA5, HN+QN);
  playNote(Rest, QN);
  playNote(noteA5, HN+QN);
  playNote(noteA5, QN);
  playNote(noteC6, HN);
  playNote(noteA5, HN);
  playNote(noteB5, HN+QN);
  playNote(noteB5, QN);
  playNote(noteB5, HN+QN);
  playNote(Rest, QN);
  playNote(noteB5, HN+QN);
  playNote(noteB5, QN);
  playNote(noteD6, HN);
  playNote(noteB5, HN);
  playNote(noteC6, HN+QN);
  playNote(noteC6, QN);
  playNote(noteC6, HN);
  playNote(noteB5, QN);
  playNote(noteA5, QN);
  playNote(noteD5, WN);
  playNote(noteFs5, WN);
  playNote(noteG5, WN);
}

void playNote(int note, int duration)
// This custom function takes two parameters, note and duration to make playing songs easier.
// Each of the notes have been #defined in the notes.h file. The notes are broken down by 
// octave and sharp (s) / flat (b).
{
  tone(buzzerPin, note, duration);
  delay(duration);
}

void readAcceleromter() {
  accelerometer.read(); // updates the x, y, and z axis readings on the acceleromter

  XBee.println("Accelerometer Readings:");
  XBee.println();
  XBee.println("(X, Y, Z) -- [X-Z, Y-Z, X-Y]");
  XBee.println("============================");

  // Display out the X, Y, and Z - axis "acceleration" measurements and also
  // the relative angle between the X-Z, Y-Z, and X-Y vectors. (These give us 
  // the orientation of the RedBot in 3D space. 

  XBee.print("("); 
  XBee.print(accelerometer.x);
  XBee.print(", ");  // tab

  XBee.print(accelerometer.y);
  XBee.print(", ");  // tab

  XBee.print(accelerometer.z);
  XBee.print(") -- ");  // tab

  XBee.print("[");
  XBee.print(accelerometer.angleXZ);
  XBee.print(", "); 
  XBee.print(accelerometer.angleYZ);
  XBee.print(", "); 
  XBee.print(accelerometer.angleXY);
  XBee.println("]");
}






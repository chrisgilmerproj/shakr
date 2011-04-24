
#include "Wire.h"
#include "BlinkM_funcs.h"

//--- BlinkM Definitions
byte blinkm_addr = 0x09;
byte r, g, b;

//--- Define the output pins
int vibPin = 12;
int ledPin = 13;

//--- Function to read in float
float readFloatFromBytes() {
  union u_tag {
    byte b[4];
    float val;
  } u;
  u.b[0] = Serial.read();
  u.b[1] = Serial.read();
  u.b[2] = Serial.read();
  u.b[3] = Serial.read();
  return u.val;
}

//--- Set colors based on a given value
void setColor(float val)
{
  if(val <= 1.0){
    r = 0x00; g = 0x00; b = 0xff;
  }
  if(val <= 3.0 and val > 1.0){
    r = 0x00; g = 0xff; b = 0xff;
  }
  if(val <= 5.0 and val > 3.0){
    r = 0x00; g = 0xff; b = 0x00;
  }
  if(val <= 7.0 and val > 5.0){
    r = 0xff; g = 0xff; b = 0x00;
  }
  if(val > 7.0){
    r = 0xff; g = 0x00; b = 0x00;
  }
}

void setup()
{
  // Initialize the serial port
  Serial.begin(19200);
  
  // Initialize the output pins
  pinMode(vibPin, OUTPUT);
  pinMode(ledPin, OUTPUT);
  digitalWrite(vibPin, LOW);
  digitalWrite(ledPin, LOW);
  
  // Initialize the BlinkM
  BlinkM_beginWithPower();
  BlinkM_stopScript(blinkm_addr);
  BlinkM_setRGB(blinkm_addr, 0x00,0x00,0x00);
}

void loop()
{
  
  if(Serial.available() == 4)
  {
    // Get the magnitude and set the color
    float val = readFloatFromBytes();
    setColor(val);
    
    // Turn on the lights and motors
    digitalWrite(vibPin, HIGH);
    digitalWrite(ledPin, HIGH);
    BlinkM_setRGB(blinkm_addr, r, g, b);
    
    // Wait for seconds equal to magnitude
    delay(int(val*1000));
    
    // Turn off the lights and motors
    digitalWrite(vibPin, LOW);
    digitalWrite(ledPin, LOW);
    BlinkM_setRGB(blinkm_addr, 0x00,0x00,0x00);
    
    // Send a response back to python
    Serial.println(val);
  }
}

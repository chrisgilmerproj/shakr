
#include "Wire.h"
#include "BlinkM_funcs.h"

//--- Define the output pins
#define vibPin 12
#define ledPin 13

//--- BlinkM Definitions
byte blinkm_addr = 0x09;
byte r, g, b;

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
  if(val <= 0.0){
    r = 0x00; g = 0x00; b = 0x00; // black
  }
  else if(val <= 1.0 and val > 0.0){
    r = 0x00; g = 0x00; b = 0xff; // blue
  }
  else if(val <= 2.0 and val > 1.0){
    r = 0x00; g = 0x88; b = 0xff; // blue-ish
  }
  else if(val <= 3.0 and val > 2.0){
    r = 0x00; g = 0xff; b = 0xff; // cyan
  }
  else if(val <= 4.0 and val > 3.0){
    r = 0x00; g = 0xff; b = 0x88; // green-blue
  }
  else if(val <= 5.0 and val > 4.0){
    r = 0x00; g = 0xff; b = 0x00; // green
  }
  else if(val <= 6.0 and val > 5.0){
    r = 0x88; g = 0xff; b = 0x00; // yellow-green
  }
  else if(val <= 7.0 and val > 6.0){
    r = 0xff; g = 0xff; b = 0x00; // yellow
  }
  else if(val <= 8.0 and val > 7.0){
    r = 0xff; g = 0x88; b = 0x00; // orange
  }
  else if(val <= 9.0 and val > 8.0){
    r = 0xff; g = 0x00; b = 0x00; // red
  }
  else if(val > 9.0){
    r = 0xff; g = 0xff; b = 0xff; // white
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
  
  // Color Startup
  for(float i = 1; i <= 10.0; ++i){
    setColor(i);
    BlinkM_setRGB(blinkm_addr, r, g, b);
    delay(200);
  }
  setColor(0.0);
  BlinkM_setRGB(blinkm_addr, r, g, b);
}

void loop()
{
  // Wait until all 4 bytes are available
  if(Serial.available() == 4)
  {
    // Get the magnitude and set the color
    float val = readFloatFromBytes();
    
    // Turn on the lights and motors
    digitalWrite(vibPin, HIGH);
    digitalWrite(ledPin, HIGH);
    setColor(val);
    BlinkM_setRGB(blinkm_addr, r, g, b);
    
    // Wait for seconds equal to magnitude
    delay(int(val*1000));
    
    // Turn off the lights and motors
    digitalWrite(vibPin, LOW);
    digitalWrite(ledPin, LOW);
    setColor(0.0);
    BlinkM_setRGB(blinkm_addr, r, g, b);
    
    // Send a response back to python
    Serial.println(val);
  }
}

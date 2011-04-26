#include "Wire.h"
#include "BlinkM_funcs.h"

//--- Define the output pins
#define vibPin 12
#define ledPin 13

//--- BlinkM Definitions
byte blinkm_addr = 0x09;
int h, s, b;

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
  // Hue is a number between 0.0 and 360.0
  // BlinkM takes color values from 0 to 255
  // We want colors to start at Blue and go to Red
  // Red is 0 and Blue is 240/360*255 = 170.
  // Because we want lower magnitude to be Blue
  // and the higher magnitude to be Red we must
  // reverse the values.  Thus the following equation.
  h = int(170.0 * (1.0 - val/9.0));
  s = 0xff; // Full Saturation
  b = 0xff; // Full Brightness
}

//--- Set the shakr
void shake(float val)
{
  // Turn on the lights and motors
  digitalWrite(vibPin, HIGH);
  digitalWrite(ledPin, HIGH);
  setColor(val);
  BlinkM_fadeToHSB(blinkm_addr, h, s, b);
  
  // Wait for seconds equal to magnitude
  delay(int(val*1000));
  
  // Turn off the lights and motors
  digitalWrite(vibPin, LOW);
  digitalWrite(ledPin, LOW);
  BlinkM_setRGB(blinkm_addr, 0x00, 0x00, 0x00);
}

void setup()
{
  // Initialize the serial port
  Serial.begin(19200);
  
  // Initialize the output pins
  pinMode(vibPin, OUTPUT);
  pinMode(ledPin, OUTPUT);
  
  // Initialize the BlinkM
  BlinkM_beginWithPower();
  BlinkM_setFadeSpeed(blinkm_addr, 255);
  BlinkM_stopScript(blinkm_addr);
  
  // Color Startup
  for(float i = 0.0; i <= 9.0; i=i+0.01){
    setColor(i);
    BlinkM_fadeToHSB(blinkm_addr, h, s, b);
    delay(2);
  }
  
  // Startup Test
  shake(0.5);
}

void loop()
{
  // Wait until all 4 bytes are available
  if(Serial.available() == 4)
  {
    // Get the magnitude and set the color
    float val = readFloatFromBytes();
    shake(val);
    
    // Send a response back to python
    Serial.println(val);
  }
}

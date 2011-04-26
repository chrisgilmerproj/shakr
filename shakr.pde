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
  h = int(170.0 - val/10.0 * 170.0);
  s = 0xff;
  b = 0xff;
}

//--- Set the shakr
void shake(int val)
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
  for(float i = 0; i <= 10.0; ++i){
    setColor(i);
    BlinkM_fadeToHSB(blinkm_addr, h, s, b);
    delay(200);
  }
  
  // Vibration Startup
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

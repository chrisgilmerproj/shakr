
#include "Wire.h"
#include "BlinkM_funcs.h"

byte blinkm_addr = 0x09;

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

void setup()
{
  Serial.begin(19200);
  pinMode(vibPin, OUTPUT);
  pinMode(ledPin, OUTPUT);
  digitalWrite(vibPin, LOW);
  digitalWrite(ledPin, LOW);
  
  BlinkM_beginWithPower();
  BlinkM_stopScript(blinkm_addr);
  BlinkM_setRGB(blinkm_addr, 0x00,0x00,0x00);
}

void loop()
{
  
  if(Serial.available() == 4)
  {
    float val = readFloatFromBytes();
    digitalWrite(vibPin, HIGH);
    digitalWrite(ledPin, HIGH);
    BlinkM_setRGB(blinkm_addr, 0xff,0x00,0x00);
    delay(int(val*1000));
    digitalWrite(vibPin, LOW);
    digitalWrite(ledPin, LOW);
    BlinkM_setRGB(blinkm_addr, 0x00,0x00,0x00);
    Serial.println(val); // send to python to check
  }
}

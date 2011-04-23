#include <Wire.h>

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

  //set up I2C
  Wire.begin();
  //join I2C, talk to BlinkM 0x09
  Wire.beginTransmission(0x09);
  //'f' == fade to color
  Wire.send('f');
  //value for red channel
  Wire.send(0xff);
  //value for blue channel
  Wire.send(0x00);
  //value for green channel
  Wire.send(0x00);
  //leave I2C bus
  Wire.endTransmission();
}

void loop()
{
  if(Serial.available() == 4)
  {
    float val = readFloatFromBytes();
    digitalWrite(vibPin, HIGH);
    digitalWrite(ledPin, HIGH);
    delay(int(val*1000));
    digitalWrite(vibPin, LOW);
    digitalWrite(ledPin, LOW);
    Serial.println(val); // send to python to check
  }
}

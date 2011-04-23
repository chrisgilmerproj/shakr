//--- Define the output pins
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
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
}

void loop()
{
  if(Serial.available() == 4)
  {
    float val = readFloatFromBytes();
    digitalWrite(ledPin, HIGH);
    delay(int(val*1000));
    digitalWrite(ledPin, LOW);
    Serial.println(val); // send to python to check
  }
}

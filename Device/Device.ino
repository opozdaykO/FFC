#define relay_port D7
#define UseButton
//#define AutoOn true
#define AutoOn false



boolean relay_state = false;

#ifdef UseButton
boolean already_pressed = false;
#define button_port D6
#endif

void relayOn() {
  relay_state = true;
  digitalWrite(relay_port, HIGH);
  getRelayState();
}

void relayOff() {
  relay_state = false;
  digitalWrite(relay_port, LOW);
  getRelayState();
}

void getRelayState() {
  if (relay_state) {
  Serial.print("1");
  }
  else {
  Serial.print("0");
  }
}
void setup() {
  pinMode(relay_port, OUTPUT);
  #ifdef UseBotton
  pinMode(button_port, INPUT);
  #endif
  Serial.begin(9600);
  if (AutoOn) relayOn();
}

void loop() {
  byte buf;
  if (Serial.available()) {
    buf = Serial.read();
    if (buf == 48) {
      relayOff();                  
    } else if (buf == 49) {
      relayOn();
    } else if (buf == 50) {
      getRelayState();
    }
  }
  #ifdef UseButton
  if (already_pressed) {
    if (digitalRead(button_port) == LOW) {
      already_pressed = false;
    }
  } else if (digitalRead(button_port) == HIGH) {
    already_pressed = true;
    if (relay_state) {
      relayOff();
    } else {
      relayOn();
    }
  }
  #endif
  delay(50);
}

// Flora MKI code
// movement mode: determine arc!///////////////////////////////////////////
// Walk mode  is default, setting char CurCmd = 'W'; , long press A.
// case 'f':  // forward                 //joystick forward
// case 'b':  // backward                //joystick backward
// case 'l':  // left                    //joystick left
// case 'r':  // right                   //joystick right
// case 's':  // stop
// case 'W':  // mode = MODE_WALK 
// case 'D':  // mode = MODE_DANCE
// case 'T':  // mode = TRIM
//trim mode////////////////////////////////////////////////////////////////
// Trim mode  is set by, setting char CurCmd = 'T'; , long press B.
// f    Raise current knee 1 microsecond                          //joystick forward
// b    Lower current knee 1 microsecond                          //joystick backward
// l    Move current hip clockwise                                //joystick left
// r    Move current hip counterclockwise                         //joystick right
// w    Move to next leg, the leg will twitch to indicate         //A
// s    Do nothing, just hold steady                              //no input
// S    Save all the current trim values                          //F
// P    Toggle the pose between standing and adjust mode (down)   //C
// R    Show untrimmed stance in the current pose (right)         //D
// E    Erase all the current trim values (left)                  //E

//Needed for joystick arc
#include <math.h> 

//Slow down amount of signals
#define DELAY 1000

// Buttons!
#define BUTTON_A 2            
#define BUTTON_B 3         
#define BUTTON_C 4
#define BUTTON_D 5
#define BUTTON_E 6
#define BUTTON_F 7
//buttonTime controls the time required to press a button in order to make it a long-click 
long buttonTimer = 0;
long buttonTime = 400;
//debounce prevents accidental double-presses
long debounceTimer = 0;
long debounceTime = 100;
boolean buttonActive = false;
boolean longPressActive = false;
boolean ButtonA = false;
boolean ButtonB = false;
boolean ButtonC = false;
boolean ButtonD = false;
boolean ButtonE = false;
boolean ButtonF = false;

//Joystick
#define PIN_ANALOG_X 0
#define PIN_ANALOG_Y 1
int xPosition = 0;
int yPosition = 0;
int xPosCor = 0;
int yPosCor = 0;
int CoordinateCorrection = 512;
int CenterJoystick= 20;
int Arc = 0;

//command variables
byte TrimMode = 0;
byte verbose = 0;
char ModeChars[] = {'W', 'D', 'F', 'R'};
char SubmodeChars[] = {'1', '2', '3', '4'};

char CurCmd = 'W';           // default is Walk mode
char CurSubCmd = '1';     // default is primary submode
char CurDpad = 's';                   // default is stop
unsigned int BeepFreq = 0;            // frequency of next beep command, 0 means no beep, should be range 50 to 2000 otherwise
unsigned int BeepDur = 0;             // duration of next beep command, 0 means no beep, should be in range 1 to 30000 otherwise
                                      // although if you go too short, like less than 30, you'll hardly hear anything
//variables for data transmit
unsigned long NextTransmitTime = 0;  // next time to send a command to the robot
#define SEND_DELAY 500  
//set to 1 to see debug messages about what packets we are sending, and what we are doing. This may make Flora cross!
int debugmode = 0;    

void setup() {
 Serial.begin(9600);
 // to enable pull up resistors first write pin mode
 // and then make that pin HIGH
 pinMode(BUTTON_A, INPUT);
 digitalWrite(BUTTON_A, HIGH);
 pinMode(BUTTON_B, INPUT);
 digitalWrite(BUTTON_B, HIGH);
 pinMode(BUTTON_C, INPUT);
 digitalWrite(BUTTON_C, HIGH);
 pinMode(BUTTON_D, INPUT);
 digitalWrite(BUTTON_D, HIGH);
 pinMode(BUTTON_E, INPUT);
 digitalWrite(BUTTON_E, HIGH);
 pinMode(BUTTON_F, INPUT);
 digitalWrite(BUTTON_F, HIGH);
}
//we need sendbeep to set up our checksum
unsigned int sendbeep(int noheader) {

#if DEBUG_SD
      if (BeepFreq != 0) {
        Serial.print("#BTBEEP="); Serial.print("B+"); Serial.print(BeepFreq); Serial.print("+"); Serial.println(BeepDur);
      }
#endif

    unsigned int beepfreqhigh = highByte(BeepFreq);
    unsigned int beepfreqlow = lowByte(BeepFreq);
    if (!noheader) {
      Serial.print("B");
    }
    Serial.print(beepfreqhigh);
    Serial.print(beepfreqlow);

    unsigned int beepdurhigh = highByte(BeepDur);
    unsigned int beepdurlow = lowByte(BeepDur);
    Serial.print(beepdurhigh);
    Serial.print(beepdurlow);

    // return checksum info
    if (noheader) {
      return beepfreqhigh+beepfreqlow+beepdurhigh+beepdurlow;
    } else {
      return 'B'+beepfreqhigh+beepfreqlow+beepdurhigh+beepdurlow;
    }

}

void setBeep(int f, int d) {
  // schedule a beep to go out with the next transmission
  // this is not quite right as there can only be one beep per transmission
  // right now so if two different subsystems wanted to beep at the same time
  // whichever one is scheduled last would win. 
  // But because 10 transmits go out per second this seems sufficient, and it's simple
  BeepFreq = f;
  BeepDur = d;
}

void loop() {
  
// Joystick control. Joystick axes are corrected ( 0-1023 is turned into-512 0 + 512) and then mapped into 0-64
// in order to have 0.0 as a starting coordinate, as it actually starts at -1.4 and occasionaly returns to 
// 0.4 or -1.3. Map makes sure these all read as 0. Coordiantes are translated into an arc, and arc is then
// translated into a direction. We could, instead of making Flora move in that direction ( current plan) use the 
// joystick to rotate flora into a direction and then use the buttons to move forward, backward, left or right.
// Something to consider for Flora MKII.
  xPosCor=map((analogRead(PIN_ANALOG_X) - CoordinateCorrection), 0, 1023, 0, 64);
  yPosCor=map((analogRead(PIN_ANALOG_Y) - CoordinateCorrection), 0, 1023, 0, 64);
  if (xPosCor + yPosCor != 0) {
    Arc = round(atan2(yPosCor, xPosCor)* 180 / 3.14159265);
    if ((Arc <45) && (Arc > -45)) {
    if (debugmode) {
      Serial.println("right"); 
    }
      CurDpad = 'r';
    }
    if ((Arc < 115) && (Arc > 45)) {
    if (debugmode) {      
      Serial.println("forward"); 
    }
      CurDpad =  'f';
    }
    if ((Arc > -115) && (Arc < -45)) {
    if (debugmode) {
      Serial.println("backward"); 
    }
      CurDpad =  'b' ;
    }
    if ((Arc > 115) || (Arc < -115 )) {
    if (debugmode) {      
      Serial.println("left"); 
    }
      CurDpad = 'l' ;
    }
  }  
// If a button gets pressed...
 if(digitalRead(BUTTON_A) == LOW && (millis() - debounceTimer > debounceTime)) {
   if (buttonActive == false) {
      buttonActive = true;
      buttonTimer = millis();
    }
    ButtonA= true;
 }
 if(digitalRead(BUTTON_B) == LOW && (millis() - debounceTimer > debounceTime)) {
   if (buttonActive == false) {
      buttonActive = true;
      buttonTimer = millis();
    }
    ButtonB = true;
 }
 if(digitalRead(BUTTON_C) == LOW && (millis() - debounceTimer > debounceTime)) {
   if (buttonActive == false) {
      buttonActive = true;
      buttonTimer = millis();
    }
    ButtonC = true;
 }
 if(digitalRead(BUTTON_D) == LOW && (millis() - debounceTimer > debounceTime)) {
   if (buttonActive == false) {
      buttonActive = true;
      buttonTimer = millis();
    }
    ButtonD = true;
 }
 if(digitalRead(BUTTON_E) == LOW && (millis() - debounceTimer > debounceTime)) {
   if (buttonActive == false) {
      buttonActive = true;
      buttonTimer = millis();
    }
    ButtonE = true;
 }
 if(digitalRead(BUTTON_F) == LOW && (millis() - debounceTimer > debounceTime)) {
   if (buttonActive == false) {
      buttonActive = true;
      buttonTimer = millis();
    }
    ButtonF = true;
 }
//If a button was pressed and it was pressed for a time longer than buttonTime..
if ((buttonActive == true) && (millis() - buttonTimer > buttonTime) && (longPressActive == false)) {
    longPressActive = true;
    if (ButtonA == true)  {
//      Serial.println("Long Press A");  
      CurCmd = 'W';
    } else if(ButtonB == true) {
//      Serial.println("Long Press B");  
      CurCmd = 'T';
    } else if(ButtonC == true) {
//      Serial.println("Long Press C");  
    } else if(ButtonD == true) {
//      Serial.println("Long Press D");  
    } else if(ButtonE == true) {
//      Serial.println("Long Press E");  
    } else if(ButtonF == true) {
//      Serial.println("Long Press F");  
    }
  }
//If a button was pressed but right now no buttons are pressed...
if ((buttonActive == true) && (digitalRead(BUTTON_A) == HIGH) &&  (digitalRead(BUTTON_B) == HIGH) && (digitalRead(BUTTON_C) == HIGH) && (digitalRead(BUTTON_D) == HIGH) && (digitalRead(BUTTON_E) == HIGH)&& (digitalRead(BUTTON_F) == HIGH) ) {
    if (longPressActive == true) {
      longPressActive = false;
    } else {
    if (ButtonA == true)  {
//      Serial.println("Short Press A");  
      CurDpad='w'; 
    } else if(ButtonB == true) {
//      Serial.println("Short Press B");  
    } else if(ButtonC == true) {
//      Serial.println("Short Press C");  
      CurDpad = 'P';
    } else if(ButtonD == true) {
      CurDpad = 'R';
//      Serial.println("Short Press D");  
    } else if(ButtonE == true) {
//      Serial.println("Short Press E");  
      CurDpad = 'E';
    } else if(ButtonF == true) {
//      Serial.println("Short Press F");  
      CurDpad = 'S';
    }
    }
    buttonActive = false;
    ButtonA = false;
    ButtonB = false;
    ButtonC = false;
    ButtonD = false;
    ButtonE = false;
    ButtonF = false;
    debounceTimer = millis();
  }
  
//this should handle all keypresses, now we can get on with sending the data.
  
  if (millis() > NextTransmitTime   ) { // Transit time is set down there to prevent overload. 
    // Packet consists of:
    // Byte 0: The letter "V" is used as a header. (Vorpal)
    // Byte 1: The letter "1" which is the version number of the protocol. In the future there may be different gamepad and
    //         robot protocols and this would allow some interoperability between robots and gamepads of different version.
    // Byte 2: L, the length of the data payload in the packet. Right now it is always 8. This number is
    //          only the payload bytes, it does not include the "V", the length, or the checksum
    // Bytes 3 through 3+L-1  The actual data.
    // Byte 3+L The base 256 checksum. The sum of all the payload bytes plus the L byte modulo 256.

 //   Serial.println("#S="); Serial.print(CurCmd); Serial.print(CurSubCmd); Serial.println(CurDpad);
    //V1W1sB0000E
    Serial.print("V1"); // Vorpal hexapod radio protocol header version 1
    int eight=8;
    Serial.write(eight);
    Serial.write(CurCmd);
    Serial.write(CurSubCmd);
    Serial.write(CurDpad);
    unsigned int checksum = sendbeep(0);
    //unsigned int checksum = 0;
    checksum += eight+CurCmd+CurSubCmd+CurDpad;
    checksum = (checksum % 256);
    Serial.write(checksum);
//    Serial.println("-------------------------");
    setBeep(0,0); // clear the current beep because it's been sent now
    CurDpad = 's'; //next command is stop unless we overwrite this with a different command.
    NextTransmitTime =  millis() + SEND_DELAY;
  }

}

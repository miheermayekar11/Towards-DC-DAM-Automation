// inslude the SPI library:
#include <SPI.h>
#include <Keypad.h>

// set pin 10 as the slave select for the digital pot:
const int slaveSelectPin = 10;
const int shutDownPin = 9;
int value = 0;
float voltage;
float R_pot_max = 4300.0;
float R_pot_min = 180.0;
float R_fix = 4020.0;
float V_max = 5.0;
float V_set = 0.0;
float d=0.0;
int D=0;
int D1=0;
int D2=0;
int D3=0;
int D4=0;
int D_inc =0;
int D_dec =0;
float Data;
int dec_count = 0;
int inc_count = 0;
int inc = 0;
int dec = 0;
int one = 0;
int two = 0;
int itr = 15; //number of times the DC voltage increments and decrements
int A = itr + 1;
int B = itr - 1;
//float dc_value = 0.0;


void setup() {
  Serial.begin(9600);
  Serial.setTimeout(1);
}
void digitalPotWrite(int address, int value) {
  // take the SS pin low to select the chip:
  digitalWrite(slaveSelectPin, LOW);
  //  send in the address and value via SPI:
  SPI.transfer(address);
  SPI.transfer(value);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin, HIGH); 
}
void loop() {
  two = two + 1;
  if (one == 0){
    while (!Serial.available());
    Data = Serial.read();
    Data = Data/10;
    V_set = Data;  
  if (V_set<0.21){
  V_set=0.21;
}
  if (V_set>2.63){
  V_set=2.63;
}
  d=((R_pot_min*(V_set-V_max))+(R_fix*V_set))*256*4/(R_pot_max*(V_max-V_set));
  D=ceil(d);

  if (D<255) {
  if (D<=248){
  
  D1=D+7;
  D2=0;
  D3=0;
  D4=0;
  }
  if (D>248){
  
  D1=D+(255-D);
  D2=7-(255-D);
  D3=0;
  D4=0; 
  }
  }

  if (D>=255 && D<510) {
   if (D<=503){
    
   D1=255;
   D2=ceil(255*((D/255.0)-floor(D/255.0)))+7;
   D3=0;
   D4=0;
  }
  if (D>503){
    
    D1=255;
    D2=ceil(255*((D/255.0)-floor(D/255)))+(255-(D-255));
    D3=7-(255-(D-255));
    D4=0;
  }
}

if (D>=510 && D<765) {
 if (D<=758){
  
    D1=255;
    D2=255;
    D3=ceil(255*((D/255.0)-floor(D/255)))+7;
    D4=0;
  }
 if (D>758){ 
  
    D1=255;
    D2=255;
    D3=ceil(255*((D/255.0)-floor(D/255)))+(255-(D-510));
    D4=7-(255-(D-510));
  }
}

if (D>=765 && D<1020) {
  
  if (D<=1013){
     D1=255;
     D2=255;
     D3=255;
     D4=ceil(255*((D/255.0)-floor(D/255)))+7;
  }
  if (D>1013){
     D1=255;
     D2=255;
     D3=255;
     D4=ceil(255*((D/255.0)-floor(D/255)))+(255-(D-765));
  }
}
if (D==1020) {
D1=255;
D2=255;
D3=255;
D4=255;
}
D_inc = D;
D_dec = D;
one = one + 1;
  // set the slaveSelectPin as an output
  pinMode (slaveSelectPin, OUTPUT);
  // set the shutDownPin as an output
  pinMode (shutDownPin, OUTPUT);
  // initialize SPI
  SPI.begin();
  //Shutdown the pots to start with
  digitalWrite(shutDownPin, LOW);
  //Set all pots to zero as a starting point
  for (int channel = 0; channel < 4; channel++) {
    digitalPotWrite(channel, 0);
  }
digitalWrite(shutDownPin, LOW);
  int channel = 0;
digitalWrite(shutDownPin, HIGH);
    int level = D1;
      digitalPotWrite(channel, level);
      digitalWrite(shutDownPin, LOW);
  int channel_1 = 1;
  digitalWrite(shutDownPin, HIGH);
  int level_1 = D2;
      digitalPotWrite(channel_1, level_1);
      digitalWrite(shutDownPin, LOW);
  int channel_2 = 2;
  digitalWrite(shutDownPin, HIGH);
  int level_2 = D3; 
      digitalPotWrite(channel_2, level_2);
digitalWrite(shutDownPin, LOW);
  int channel_3 = 3;
  digitalWrite(shutDownPin, HIGH);
int level_3 = D4; 
      digitalPotWrite(channel_3, level_3);
//delay(1);

  //digitalWrite(shutDownPin, LOW);
 
  value = analogRead(A0);
  voltage = value * 5.0/1023;
  Serial.print(" DC Voltage: ");
  Serial.print(V_set,6);
  Serial.print(" | Voltage= ");
  Serial.print(voltage,4);
  Serial.print(" | D = ");
  Serial.print(D);
  Serial.print(" | D1 = ");
  Serial.print(D1);
  Serial.print(" | D2 = ");
  Serial.print(D2);
  Serial.print(" | D3 = ");
  Serial.print(D3);
  Serial.print(" | D4 = ");
  Serial.print(D4);
  Serial.print(" | d = ");
  Serial.print(d);



  }

  // counter increment if the pushbutton 1 is pressed.
  if ((two <= (A)) && (two > (1))){
  while (!Serial.available());
    inc = Serial.read();
  //D_inc = D;
  
  while (inc_count < inc) {
    D_inc = D_inc + 15;
    if (D_inc > 1020){
      D_inc=1020;
    }
    int D1=0;
int D2=0;
int D3=0;
int D4=0;
    if (D_inc<255) {
if (D_inc<=248){
  
D1=D_inc+7;
D2=0;
D3=0;
D4=0;
}
if (D_inc>248){
  
 D1=D_inc+(255-D_inc);
D2=7-(255-D_inc);
D3=0;
D4=0; 
}
  }

if (D_inc>=255 && D_inc<510) {
  if (D_inc<=503){
    
D1=255;
D2=ceil(255*((D_inc/255.0)-floor(D_inc/255.0)))+7;
D3=0;
D4=0;
  }
  if (D_inc>503){
    
    D1=255;
D2=ceil(255*((D_inc/255.0)-floor(D_inc/255)))+(255-(D_inc-255));
D3=7-(255-(D_inc-255));
D4=0;
  }
}

if (D_inc>=510 && D_inc<765) {
 if (D_inc<=758){
   
D1=255;
D2=255;
D3=ceil(255*((D_inc/255.0)-floor(D_inc/255)))+7;
D4=0;
 }
 if (D_inc>758){ 
  
D1=255;
D2=255;
D3=ceil(255*((D_inc/255.0)-floor(D_inc/255)))+(255-(D_inc-510));
D4=7-(255-(D_inc-510));
 }
}

if (D_inc>=765 && D_inc<1020) {
  
  if (D_inc<=1013){
D1=255;
D2=255;
D3=255;
D4=ceil(255*((D_inc/255.0)-floor(D_inc/255)))+7;
  }
  if (D_inc>1013){
D1=255;
D2=255;
D3=255;
D4=ceil(255*((D_inc/255.0)-floor(D_inc/255)))+(255-(D_inc-765));
  }
}
if (D_inc==1020) {
D1=255;
D2=255;
D3=255;
D4=255;
}

  // set the slaveSelectPin as an output
  pinMode (slaveSelectPin, OUTPUT);
  // set the shutDownPin as an output
  pinMode (shutDownPin, OUTPUT);
  // initialize SPI
  SPI.begin();
  
digitalWrite(shutDownPin, LOW);
  int channel = 0;
digitalWrite(shutDownPin, HIGH);
    int level = D1;
      digitalPotWrite(channel, level);
      digitalWrite(shutDownPin, LOW);
  int channel_1 = 1;
  digitalWrite(shutDownPin, HIGH);
  int level_1 = D2;
      digitalPotWrite(channel_1, level_1);
      digitalWrite(shutDownPin, LOW);
  int channel_2 = 2;
  digitalWrite(shutDownPin, HIGH);
  int level_2 = D3; 
      digitalPotWrite(channel_2, level_2);
digitalWrite(shutDownPin, LOW);
  int channel_3 = 3;
  digitalWrite(shutDownPin, HIGH);
int level_3 = D4; 
      digitalPotWrite(channel_3, level_3);
//delay(1);

  //digitalWrite(shutDownPin, LOW);
 
  value = analogRead(A0);
  voltage = value * 5.0/1023;
  Serial.print(" | Voltage= ");
  Serial.print(voltage,4);
  Serial.print(" | D_inc = ");
  Serial.print(D_inc);
  Serial.print(" | D1 = ");
  Serial.print(D1);
  Serial.print(" | D2 = ");
  Serial.print(D2);
  Serial.print(" | D3 = ");
  Serial.print(D3);
  Serial.print(" | D4 = ");
  Serial.print(D4);
  Serial.print(" | d = ");
  Serial.print(d);
inc_count++;
}
inc_count = 0;
  }
// counter decrement if the pushbutton 2 is pressed.
if (two > (A)){
  while (!Serial.available());
    dec = Serial.read();
  //D_dec = D;
  
  while (dec_count < dec) {
  D_dec = D_dec - 15;
  if (D_dec < -7){
    D_dec=-7;
  }
  int D1=0;
int D2=0;
int D3=0;
int D4=0;
    if (D_dec<255) {
if (D_dec<=248){
  
D1=D_dec+7;
D2=0;
D3=0;
D4=0;
}
if (D_dec>248){
  
 D1=D_dec+(255-D_dec);
D2=7-(255-D_dec);
D3=0;
D4=0; 
}
  }

if (D_dec>=255 && D_dec<510) {
  if (D_dec<=503){
    
D1=255;
D2=ceil(255*((D_dec/255.0)-floor(D_dec/255)))+7;
D3=0;
D4=0;
  }
  if (D_dec>503){
    
    D1=255;
D2=ceil(255*((D_dec/255.0)-floor(D_dec/255)))+(255-(D_dec-255));
D3=7-(255-(D_dec-255));
D4=0;
  }
}

if (D_dec>=510 && D_dec<765) {
 if (D_dec<=758){
   
D1=255;
D2=255;
D3=ceil(255*((D_dec/255.0)-floor(D_dec/255)))+7;
D4=0;
 }
 if (D_dec>758){ 
  
D1=255;
D2=255;
D3=ceil(255*((D_dec/255.0)-floor(D_dec/255)))+(255-(D_dec-510));
D4=7-(255-(D_dec-510));
 }
}

if (D_dec>=765 && D_dec<1020) {
  
  if (D_dec<=1013){
D1=255;
D2=255;
D3=255;
D4=ceil(255*((D_dec/255.0)-floor(D_dec/255)))+7;
  }
  if (D_dec>1013){
D1=255;
D2=255;
D3=255;
D4=ceil(255*((D_dec/255.0)-floor(D_dec/255)))+(255-(D_dec-765));
  }
}
if (D_dec==1020) {
D1=255;
D2=255;
D3=255;
D4=255;
}

  // set the slaveSelectPin as an output
  pinMode (slaveSelectPin, OUTPUT);
  // set the shutDownPin as an output
  pinMode (shutDownPin, OUTPUT);
  // initialize SPI
  SPI.begin();
  
digitalWrite(shutDownPin, LOW);
  int channel = 0;
digitalWrite(shutDownPin, HIGH);
    int level = D1;
      digitalPotWrite(channel, level);
      digitalWrite(shutDownPin, LOW);
  int channel_1 = 1;
  digitalWrite(shutDownPin, HIGH);
  int level_1 = D2;
      digitalPotWrite(channel_1, level_1);
      digitalWrite(shutDownPin, LOW);
  int channel_2 = 2;
  digitalWrite(shutDownPin, HIGH);
  int level_2 = D3; 
      digitalPotWrite(channel_2, level_2);
digitalWrite(shutDownPin, LOW);
  int channel_3 = 3;
  digitalWrite(shutDownPin, HIGH);
int level_3 = D4; 
      digitalPotWrite(channel_3, level_3);
//delay(1);

  //digitalWrite(shutDownPin, LOW);
 
  value = analogRead(A0);
  voltage = value * 5.0/1023;
  Serial.print(" | Voltage= ");
  Serial.print(voltage,4);
  Serial.print(" | D_dec = ");
  Serial.print(D_dec);
  Serial.print(" | D1 = ");
  Serial.print(D1);
  Serial.print(" | D2 = ");
  Serial.print(D2);
  Serial.print(" | D3 = ");
  Serial.print(D3);
  Serial.print(" | D4 = ");
  Serial.print(D4);
  Serial.print(" | d = ");
  Serial.print(d);
dec_count++;
  }
dec_count = 0;
if (((2*itr)+1) == two){
one = 0;
two = 0;
}
  }
}
  





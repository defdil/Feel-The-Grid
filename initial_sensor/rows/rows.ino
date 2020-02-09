//This is for rows
//Output signals:
//00 - Nothing detected
//01 - Row 1 detected
//10 - Row 2 detected
//11 - Row 3 detected

// defines pins numbers - 5v
const int trigPin1 = 12;
const int echoPin1 = 11;
const int trigPin2 = 10;
const int echoPin2 = 9;
const int trigPin3 = 8;
const int echoPin3 = 7;
const int alarmLight1 = 6; // least significant bit
const int alarmLight2 = 5; // most significant bit


const int boardWidth = 28;

// defines variables
long distance;
long duration;
long distance1;
long duration2;
long distance2;
long duration3;
long distance3;

void setup() {
  pinMode(trigPin1, OUTPUT);
  pinMode(echoPin1, INPUT);
  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);
  pinMode(trigPin3, OUTPUT);
  pinMode(echoPin3, INPUT);
  pinMode(alarmLight1, OUTPUT);
  pinMode(alarmLight2, OUTPUT);
  Serial.begin(9600); // Starts the serial communication
}

void loop() {
  delay(500);
  SonarSensor(trigPin3, echoPin3);
  distance3 = distance;
  delay(50);
  SonarSensor(trigPin1, echoPin1);
  distance1 = distance;
  delay(50);
  SonarSensor(trigPin2, echoPin2);
  distance2 = distance;
  // Prints the distance on the Serial Monitor
  Serial.println("Distances: ");
  Serial.println(distance1);
  Serial.println(distance2);
  Serial.println(distance3);
  if (distance1<boardWidth){ //1th row is high
    digitalWrite(alarmLight1, HIGH);
    digitalWrite(alarmLight2, LOW);
    Serial.println("1st row detected");
  }
  else if (distance2<boardWidth){ //2nd row is high
    digitalWrite(alarmLight1, LOW);
    digitalWrite(alarmLight2, HIGH);
    Serial.println("2nd row detected");
  }
  else if (distance3<boardWidth){ //3rd row is high
    digitalWrite(alarmLight1, HIGH);
    digitalWrite(alarmLight2, HIGH);
    Serial.println("3rd row detected");
  }
  
  else{
    Serial.println("Empty");
    digitalWrite(alarmLight1, LOW);
    digitalWrite(alarmLight2, LOW);
  }
}

void SonarSensor(int trigPin,int echoPin)
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(10);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = (duration/2)*0.034;
 
}

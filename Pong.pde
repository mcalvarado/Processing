import processing.serial.*;
import cc.arduino.*;

//Variables de la tarjeta arduino
Arduino arduino;
int potJ1 = 1;
int potJ2 = 2;

//Variables de coordenadas y dimensiones de la bola y pads
float ballX, ballY, padJ1X, padJ1Y, padJ2X, padJ2Y, ballSize, padW, padH;

//Variables auxiliares para dirección y velocidad de la bola
boolean right, up;
int auxR, auxU;
float speed;

//Variables auxiliares límites del juego (bordes y pads)
float rightL, leftL, upL, downL;
float padJ1XL, padJ2XL, padJ1Y1L, padJ1Y2L, padJ2Y1L, padJ2Y2L;

//Variables punteo
boolean point;
int scoreJ1, scoreJ2;

//Variables auxiliares estado del juego
boolean win, restart, onGame, pause;

void setup(){
  //Tamaño, bordes, bordes lisos, rectMode y color blanco para todo
  size(600,500);
  stroke(255);
  smooth();
  rectMode(CENTER);
  ellipseMode(CENTER);
  fill(255,255,255);
  textSize(height*0.05);
  textAlign(CENTER);
  
  //Dimensión de la bola (se adapta a cualquier tamaño del panel)
  ballSize = width*0.033;

  //Dimensiones de los pads (se adaptan a cualquier tamaño del panel)  
  padW = width*0.02;
  padH = height*0.1;
    
  //Configuración Arduino y sus pines
  arduino = new Arduino(this, Serial.list()[0], 57600);
  
  //Límites del tablero
  rightL = width-(padW/2);
  leftL = padW/2;
  upL = padW/2;
  downL = height-(padW/2);
  
  initialize(); //Inicia valores que pueden cambiar (separado por si ocurre un restart)
  
  //Límites de los pads (x, arriba y abajo de cada uno)
  padJ1XL = padJ1X+(padW/2);  //J1 horizontal
  padJ2XL = padJ2X-(padW/2);  //J2 horizontal
  padJ1Y1L = padJ1Y-(padH/2);  //J1 arriba
  padJ1Y2L = padJ1Y+(padH/2);  //J1 abajo
  padJ2Y1L = padJ2Y-(padH/2);  //J2 arriba
  padJ2Y2L = padJ2Y+(padH/2);  //J2 abajo
}

void draw(){
  if(onGame){
    background(0); //fondo negro
    drawBackground(); //Dibuja el tablero (linea punteada y marco)
    
    drawBall(); //Dibuja la bola
    drawPads(); //Dibuja los pads
    
    moveBall(); //Movimiento de la bola
    movePads(); //Lectura y mapeo de los potenciómetros (actualiza posiciones en Y)    
  }
  if(point){
    ballX = width/2;
    ballY = height/2;
    
    randomMovement();   
    
    point = false;
  }
  if(restart){
    initialize();
    restart = false;
    onGame = true;
  }
  if(pause){
    background(0); //fondo negro
    drawBackground(); //Dibuja el tablero (linea punteada y marco)
    
    drawBall(); //Dibuja la bola
    drawPads(); //Dibuja los pads
  }
  if(win){
    background(0); //fondo negro
    drawBackground(); //Dibuja el tablero (linea punteada y marco)
    
    drawBall(); //Dibuja la bola
    drawPads(); //Dibuja los pads
    
    onGame=false;
  }
  
  checkBorder(); //Detección de colisiones (arriba, abajo, pads, izquierda y derecha) - suma puntos
  showScore(); //Muestra el score de cada jugador
  checkWin(); //Verifica si alguien ganó o no
}

void randomMovement(){
  auxR = int(random(2));
  auxU = int(random(2));
  if(auxR==1){
    right = true;
  }else{
    right = false;
  }
  if(auxU==1){
    up = true;
  }else{
    up = false;
  }
}

void initialize(){
  //Coordenadas de la bola (se adapta a cualquier tamaño del panel)
  ballX = width/2;
  ballY = height/2;
  
  //Coordenadas de los pads (se adaptan a cualquier tamaño del panel)
  padJ1X = 2*padW;
  padJ2X = width - (2*padW);
  padJ1Y = padJ2Y = height/2;
  
  //Inicializa movimiento random de la bola
  randomMovement();
  
  //Inicialización variables punteo
  point = false;
  scoreJ1 = scoreJ2 = 0;
  
  //Inicialización variables auxiliares estado del juego
  win = false;
  restart = false;
  onGame = true;
  pause =false;
  
  //Inicializa velocidad de la bola
  speed = 1.5;
}

void drawBall(){  
  ellipse(ballX, ballY, ballSize, ballSize);
}

void moveBall(){
  if(right){
    ballX=ballX+speed;
  }else{
    ballX=ballX-speed;
  }
  
  if(up){
    ballY=ballY+speed;
  }else{
    ballY=ballY-speed;
  }
}

void drawPads(){  
  rect(padJ1X, padJ1Y, padW, padH);
  rect(padJ2X, padJ2Y, padW, padH);
}

void movePads(){
  padJ1Y = map(arduino.analogRead(potJ1),0,1023,padW+(padH/2),(height-padW)-(padH/2));
  padJ2Y = map(arduino.analogRead(potJ2),0,1023,padW+(padH/2),(height-padW)-(padH/2));
  
  //Actualización de limites
  padJ1Y1L = padJ1Y-(padH/2);  //J1 arriba
  padJ1Y2L = padJ1Y+(padH/2);  //J1 abajo
  padJ2Y1L = padJ2Y-(padH/2);  //J2 arriba
  padJ2Y2L = padJ2Y+(padH/2);  //J2 abajo
}

void drawBackground(){
  int x1 = width/2;
  int x2 = width/2; 
  float y1, y2;
  float hLine = height*0.01;
  //Línea punteada
  for(y1 = padW, y2 = hLine; y2 < height; y1 = y2 + hLine, y2 = y1 + hLine){
    line(x1,y1,x2,y2);
  }
  //Marco
  noFill();
  rect(width/2,height/2,width-padW,height-padW);
  fill(255,255,255);
}

void checkBorder(){
  //Arriba y abajo
  if((ballY-ballSize/2)<=upL || (ballY+ballSize/2)>=downL){
    up=!up;
  }
    /*Para los pads
    1. limites horizontales
    2. limites arriba
    3. limites abajo */
  else if((ballX-ballSize/2>padJ1XL)&&(ballX+ballSize/2<padJ2XL)){
            //( (( (ballX-ballSize/2<=padJ1XL) && (ballY+ballSize/2>=padJ1Y1L) ) && ( (ballX-ballSize/2<=padJ1XL) && (ballY-ballSize/2<=padJ1Y2L) )) ||
           //(( (ballX+ballSize/2>=padJ2XL) && (ballY+ballSize/2>=padJ2Y1L) ) && ( (ballX+ballSize/2>=padJ2XL) && (ballY-ballSize/2<=padJ2Y2L) ))  ) {
           if(((ballX-ballSize/2)<=padJ1XL && (ballY+ballSize/2)>=padJ1Y1L && (ballY-ballSize/2)<=padJ1Y2L) ||
            ((ballX+ballSize/2)>=padJ2XL && (ballY+ballSize/2)>=padJ2Y1L && (ballY-ballSize/2)<=padJ2Y2L) ){
    right=!right;
    speed=speed+0.1;}
  //Pierde J1 (punto J2)
  }else if((ballX-ballSize/2)<=leftL){
    point=true;
    scoreJ2++;
  //Pierde J2 (punto J1)
  }else if((ballX+ballSize/2)>=rightL){
    point=true;    
    scoreJ1++;
  }
}

void showScore(){
  text(scoreJ1,(width/2)-(width*0.1),(1.5*padW)+(height*0.05));
  text(scoreJ2,(width/2)+(width*0.1),(1.5*padW)+(height*0.05));
}

void checkWin(){
  if(scoreJ1==5){
    textSize(height*0.1);
    text("WIN",(width/2)-(width*0.1),(3*padW)+(3*(height*0.05)));
    textSize(height*0.05);
    win=true;
    onGame=false;
  }else if(scoreJ2==5){
    textSize(height*0.1);
    text("WIN",(width/2)+(width*0.1),(3*padW)+(3*(height*0.05)));
    textSize(height*0.05);    
    win=true;
    onGame=false;
  }
}

void keyPressed(){
  if(keyCode == ENTER){ //restart
    win = false;
    restart = true;
    onGame = false;
    pause = false;
  }else if((key == 'p') && !win){ //pause}
    onGame=!onGame;
    pause=!pause;
  }
}

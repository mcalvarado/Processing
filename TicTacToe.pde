import processing.serial.*;
import cc.arduino.*;

//Variables de la tarjeta arduino
Arduino arduino;
int x = 0;
int y = 1;
int s = 8;


//Variables juego cuadrícula, coordenadas, turno, estado del juego, ganador
Boolean grid[][]; //nada = null, O = true, X = false
int f, c;
boolean turn, win, restart, winner;

//Variables dimensiones del tablero
float alto, ancho, borde;

//Variable auxiliares presión inicial, lecturas joystick, selección jugador, número de tiros
int auxP, auxX, auxY, auxJ, auxN;

void setup(){
  //Tamaño, bordes, bordes lisos, rectMode y color blanco para todo
  size(800,800);
  smooth();
  rectMode(CENTER);
  ellipseMode(CENTER);
  
  grid = new Boolean[3][3]; //tablero de 3x3
  
  //Configuración Arduino y sus pines
  arduino = new Arduino(this, Serial.list()[0], 57600);
  arduino.pinMode(s, Arduino.INPUT);
  
  //arduino.digitalRead(s); HIGH o LOW
  
  randomInit();
  initialize();  
}

void draw(){
  if(!win && !restart){
    println("aqui");
    background(255,255,255); //fondo blanco
  
    drawBackground(); //Dibuja el tablero 
    move();
    select();
    checkWin();
    if(win == false && auxN == 9){
      drawTie();
      win = true;
      print("winner: ");
      println(winner);
    }
    drawGame();
  }else if(restart){
    initialize();
  }
}

void initialize(){    
  alto = height/3;
  ancho = width/3;
  borde = width*0.035;
  
  auxP = 0;
  auxX = 0;
  auxY = 0;
  auxN = 0;
  
  f = 1;
  c = 1;
  
  win = false;
  restart = false;
  //winner = null;
  
   for(int f=0;f<3;f++){
    for(int c=0;c<3;c++){
      grid[f][c] = null;
    }
  }
}

void select(){
  if(arduino.digitalRead(s) == Arduino.LOW && grid[f][c] == null){
    if(auxP != 0){
    grid[f][c] = turn;
    turn = !turn;
    auxN++;
    println("presion!");
    delay(150);
    }else{
      delay(500);
      auxP++;    
    }
  }
}

void move(){
  int auxX = arduino.analogRead(x)-400;
  int auxY = arduino.analogRead(y)-400;
  print("X: ");
  println(auxX);
  print("Y: ");
  println(auxY);
  
  if(auxX > 250 && c < 2){ //derecha
    c++;
    println("derecha, c: ");
    print(c);
  }else if(auxX < -50 && c > 0){ //izquierda
    c--;
    println("izquierda, c: ");
    print(c);
  }else if(auxY > 250 && f > 0){ //arriba
    f--;
    println("arriba, f: ");
    print(f);
  }else if(auxY < -50 && f < 2){ //abajo
    f++;
    println("abajo, f: ");
    print(f);
  }
  
  drawSquare(f,c);
  delay(150);
}

void drawTie(){
  for(int f=0;f<3;f++){
    for(int c=0;c<3;c++){
      drawSquare(f,c);
    }
  }
}

void drawGame(){
  for(int f=0;f<3;f++){
    for(int c=0;c<3;c++){
      if(grid[f][c] != null){
        if(grid[f][c] == true)
          drawO(f,c);
        if(grid[f][c] == false)
          drawX(f,c);
      }
    }
  }
}

void drawX(int f, int c){
  stroke(255,0,0);
  strokeWeight(5);
  
  line(c*ancho+borde,f*alto+borde,(c+1)*ancho-borde,(f+1)*alto-borde);
  line(c*ancho+borde,(f+1)*alto-borde,(c+1)*ancho-borde,f*alto+borde);
}

void drawO(int f, int c){
  stroke(0,0,255);
  strokeWeight(5);
  noFill();
  
  ellipse(c*ancho+((ancho-borde*2)/2)+borde,f*alto+((alto-borde*2)/2)+borde, ancho-borde*2, alto-borde*2);
}

void drawSquare(int f, int c){
  noStroke();
  fill(216,216,216);
  
  rect(c*ancho+((ancho-borde*2)/2)+borde,f*alto+((alto-borde*2)/2)+borde, ancho-borde*2, alto-borde*2);
}

void checkWin(){
  for(int i=0; i < 3; i++){
    //filas
    if(grid[i][0] != null && grid[i][1] != null && grid[i][2] != null){
      if(grid[i][0] == grid[i][1] && grid[i][0] == grid[i][2]){
        win = true;
        winner = grid[i][0];
        for(int j=0; j < 3; j++){
          drawSquare(i,j);
        }
      }
    }
    //columnas
    if(grid[0][i] != null && grid[1][i] != null && grid[1][i] != null){
      if(grid[0][i] == grid[1][i] && grid[0][i] == grid[2][i]){
        win = true;
        winner = grid[0][i];
        for(int j=0; j < 3; j++){
          drawSquare(j,i);
        }
      }
    }
  }
  //diagonal así --> \
  if(grid[0][0] != null && grid[1][1] != null && grid[2][2] != null){
    if(grid[0][0] == grid[1][1] && grid[0][0] == grid[2][2]){
      win = true;
      winner = grid[0][0];
      for(int i=0; i < 3; i++){
        drawSquare(i,i);
      }
    }
  }
  //diagonal así --> /
  if(grid[0][2] != null && grid[1][1] != null && grid[2][0] != null){
    if(grid[0][2] == grid[1][1] && grid[0][2] == grid[2][0]){
      win = true;
      winner = grid[0][2];
      for(int i = 0, j = 2; i < 3; i++, j--){
        drawSquare(i,j);
      }
    }
  }
  
  if(win){
    print("winner: ");
    println(winner);
    
  }
}

void drawBackground(){
  //lineas
  stroke(0);
  strokeWeight(5);
  
  //verticales
  line(ancho,0,ancho,height);
  line(ancho*2,0,ancho*2,height);
  
  //horizontales
  line(0,alto,width,alto);
  line(0,alto*2,width,alto*2);
  
  //marco
  stroke(255,255,255);
  strokeWeight(20);
  noFill();
  rect(width/2,height/2,width,height);
}

void randomInit(){
  auxJ = int(random(2));
  if(auxJ==1){
    turn = true;
  }else{
    turn = false;
  }
}

void keyPressed(){
  if(keyCode == ENTER){ //restart
    win = false;
    restart = true;
  }
}

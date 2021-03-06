final int SIZE_SCREEN = 900;
final float G = 0.0001;

float ESCALE = 1;
int ORIGEN_X = SIZE_SCREEN / 2;
int ORIGEN_Y = SIZE_SCREEN / 2;
boolean PAUSED = true;

int cantParticulas;
Particula particulas[];

class Particula {
  public float diametro = 1;
  public float masa = 1;
  public PVector posicion = new PVector(0,0);
  public PVector velocidad = new PVector(0, 0);
  public PVector aceleracion = new PVector(0, 0);
  
  public Particula(float diametro, float masa, float postAngulo, float postMag, float velAngulo, float velMag){
    this.diametro = diametro;
    this.masa = masa;
    this.posicion.x = cos(postAngulo);
    this.posicion.y = sin(postAngulo);
    this.velocidad.normalize();
    this.posicion.mult(postMag);
    this.velocidad.x = cos(velAngulo);
    this.velocidad.y = sin(velAngulo);
    this.velocidad.normalize();
    this.velocidad.mult(velMag);
  }

  public void draw(int i) {
    noStroke();
    fill(255,255,255);
    ellipse(ORIGEN_X + ESCALE * this.posicion.x, ORIGEN_Y + ESCALE * this.posicion.y, ESCALE * this.diametro, ESCALE * this.diametro);
    text("m:" + this.masa, 10, 15 + i * 15);
    text("x:" + this.posicion.x, 90, 15 + i * 15);
    text("y:" + this.posicion.y, 170, 15 + i * 15);
    text("vx:" + this.velocidad.x, 250, 15 + i * 15);
    text("vy:" + this.velocidad.y, 330, 15 + i * 15);
    text("ax:" + this.aceleracion.x, 410, 15 + i * 15);
    text("ay:" + this.aceleracion.y, 490, 15 + i * 15);
  }

  void actualizar() {
    this.velocidad.add(this.aceleracion);
    this.posicion.add(this.velocidad);
    //this.aceleracion.mult(0);
  }

  void aplicarFuerza(PVector fuerza){
    PVector fuerzaResultante = PVector.div(fuerza, this.masa);
    this.aceleracion.add(fuerzaResultante);
  }

  void aplicarGravedadParticula(Particula p){
    PVector direccion = PVector.sub(p.posicion, this.posicion);
    float distancia = direccion.mag();
    distancia = constrain(distancia, 5, 25);
    float magnitud = (G * this.masa * p.masa) / (distancia * distancia);
    direccion.normalize();
    direccion.mult(magnitud);
    this.aplicarFuerza(direccion);
  }

  void chequearBordes(){
    // Check for bouncing.
    if (this.posicion.x > width) {
      this.posicion.x = width;
      this.velocidad.x *= -1;
    } else if(this.posicion.x < 0){
      this.posicion.x = 0;
      this.velocidad.x *= -1;
    }
    if (this.posicion.y > height) {
      this.posicion.y = width;
      this.velocidad.y *= -1;
    } else if(this.posicion.y < 0){
      this.posicion.y = 0;
      this.velocidad.y *= -1;
    }
  }

}

void actualizarParticulas() {
  for (int i = 0; i < cantParticulas; ++i) {
    particulas[i].aceleracion.mult(0);
    for (int j = 0; j < cantParticulas; ++j) {
      if (i!=j){
        particulas[i].aplicarGravedadParticula(particulas[j]);
      }
    }
    particulas[i].actualizar();
  }
}

void drawParticulas(){
  for (int i = 0; i < cantParticulas; ++i) {
    // particulas[i].chequearBordes();
    particulas[i].draw(i);
  }
}

void drawEjes(){
  stroke(0,255,0);
  line(SIZE_SCREEN/2, 0, SIZE_SCREEN/2, SIZE_SCREEN);
  line(0, SIZE_SCREEN/2, SIZE_SCREEN, SIZE_SCREEN/2);
  
  //stroke(50,50,50);
  //line(ORIGEN_X, 0, ORIGEN_X, SIZE_SCREEN);
  //line(0,ORIGEN_Y,SIZE_SCREEN,ORIGEN_Y);
}

void drawSistema(){
  background(0,0,0);
  // drawEjes();
  drawParticulas();
}

void initParticulas(int cant){
  cantParticulas = cant;
  particulas = new Particula[cantParticulas];
  for (int i = 0; i < cantParticulas; ++i) {
    float masa = random(1, 20);
    float posAngulo = random(0, 360);
    float posMag = random(0, SIZE_SCREEN);
    float velAngulo = random(0, 360);
    float velMag = random(0, 1);
    particulas[i] = new Particula(masa, masa, posAngulo, posMag, velAngulo, velMag);
  }
}

void initSolTierra(){
  cantParticulas = 5;
  particulas = new Particula[cantParticulas];
  particulas[0] = new Particula(40, 500000, 0, 0, 0, 0);
  particulas[1] = new Particula(2, 80, -1.5708, 80, -1.5708*2, 2.5);
  particulas[2] = new Particula(4, 100, 1.5708*2, 120, 1.5708, 2.5);
  particulas[3] = new Particula(10, 160, 0, 300, -1.5708, 5);
  particulas[4] = new Particula(8, 130, 0, -350, 1.5708, 5);
}

void setup() {
  size(900, 900);
  // initParticulas(100);
  initSolTierra();
  drawSistema();
}

void draw() {
  if (PAUSED) return;
  actualizarParticulas();
  drawSistema();
}

void keyPressed() {
  if (key == '+') {
    ESCALE *= 2;
  } else if (key == '-') {
    ESCALE /= 2;
  } else if (keyCode == 37) { // left
    ORIGEN_X -=10; 
  } else if (keyCode == 39) { // right
    ORIGEN_X +=10;
  } else if (keyCode == 38) { // up
    ORIGEN_Y -=10; 
  } else if (keyCode == 40) { // down
    ORIGEN_Y +=10;
  } else if (key == 'p') { // down
    PAUSED = !PAUSED;
  }
  drawSistema();
}

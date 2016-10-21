import java.io.*;

Player player;
Bot a1, a2;
Net n;
Ball b;

Network nn1, nn2;

int iterations = 500;
int framecount;
float gravity;
boolean newRound;

int FR = -1;
PFont f;
int lscore, rscore;

static final float ground = 400;
static final int MLEFT = 0;
static final int MRIGHT = 1;
static final int JUMP = 2;
static final int LJUMP = 3;
static final int RJUMP = 4;

void setup() {
    size(800, 600);

  	framecount = 0;
  	newRound = false;
  
  	gravity = -0.25;
    
    nn1 = new Network(6, 8, 5);
    nn2 = new Network(6, 8, 5);
    readNetworks();
    
    player = new Player(new PVector(width*3/4, height*2/3), ground, 40, gravity, n);
    a1 = new Bot(new PVector(width/4, height*2/3), ground, 40, gravity, nn1, n);
    //a2 = new Bot(new PVector(width*3/4, height*2/3), ground, 40, gravity, nn2, n);
    
    n = new Net();
    b = new Ball(new PVector(width/2, height/4), gravity, 10);
    
    frameRate(60);
    f = createFont("Arial", 64, true);
    lscore = rscore = 0;
}

void draw() {
    background(255);
    
    // udpate player, agent, ball
    player.update();
    
    if (framecount > 10) {
        a1.update(n, b, false); // left
        //a2.update(n, b, true); // right
    }
    
    if (framecount == 0) {
    	b = new Ball(new PVector(width/2, height/4), gravity, 10);
        
        a1.pos = a1.oriPos;
    }
    
    if (framecount > 10) {
        if (b.vel.mag() == 0)
            b.iniVel();
        
    	newRound = false;
    }
    
    // end round
    if (b.pos.y >= ground - b.radius && !newRound) {
        b.pos.y = ground - b.radius;
        framecount = -50;
        if (!newRound) {
            if (b.pos.x < n.tl.x + n.w/2)
                rscore ++;
            else lscore ++;
        }
        newRound = true;
    }
    
    // handles ball collision
    if (framecount > 10) {
        b.collideCircle(player.vel, player.pos, player.radius);
        b.collideCircle(a1.vel, a1.pos, a1.radius);
        //b.collideCircle(a2.vel, a2.pos, a2.radius);
        
        b.collideNet(n);
        b.update();
    }
    
    // render player, agent, ball
    player.render();
    a1.render(false);
    //a2.render(true);
    
    b.render();
    
    // render net
    n.render();
    
    pushMatrix();
    stroke(50, 205, 50);
    //line(0, 200, 800, 200);
    line(0, 400, 800, 400);
    popMatrix();
    
    framecount ++;
    //println(frameRate);
    
    pushMatrix();
    fill(178, 34, 34);
    textSize(60);
    text(lscore, width/4, height/3);
    text(rscore, width*3/4, height/3);
    popMatrix();
    
    pushMatrix();
    textSize(30);
    text(a1.toggleTraining? "ON" : "OFF", width/2-20, height/2);
    popMatrix();
}

void changeFR() {
    if (FR == -1) {
        FR = 60;
    }
    if (FR == 60) {
        FR = -1;
    }
}

void serialiseNetworks() {
    //try {
    //    FileOutputStream netFile = new FileOutputStream(dataPath("net1.data"));
    //    ObjectOutputStream o = new ObjectOutputStream(netFile);
        
    //    o.writeObject(nn1);
    //    o.close();
    //}
    //catch (Exception e) {
    //    e.printStackTrace();
    //}
    
    String[] a = new String[1];
    a[0] = nn1.writeData();
    saveStrings("NN.txt", a);
}

void readNetworks() {
    //try {
    //    FileInputStream netFile = new FileInputStream(dataPath("net1.data"));
    //    ObjectInputStream o = new ObjectInputStream(netFile);
        
    //    nn1 = (Network) o.readObject();
    //    o.close();
    //}
    //catch (Exception e) {
    //    e.printStackTrace();
    //}
    
    String[] a = loadStrings("NN.txt");
    int in_n = Integer.parseInt(a[0]);
    float[] tmpInt;
    float[] tmpFloat;
    
    nn1 = new Network(6, in_n, 5);
    println("Hidden " + in_n);
    
    for (int i=0; i<in_n; i++) {
        tmpInt = float(split(a[i*2+1], ' '));
        tmpFloat = float(split(a[i*2+2], ' '));
        
        nn1.hidden[i].n = (int)tmpInt[0];
        nn1.hidden[i].c = tmpInt[1];
        nn1.hidden[i].bias = tmpInt[2];
        nn1.hidden[i].bias_c = tmpInt[3];
        
        for (int j=0; j<tmpFloat.length-1; j++) {
            nn1.hidden[i].weight[j] = tmpFloat[j];
        }
    }
    for (int i=0; i<5; i++) {
        tmpInt = float(split(a[17+i*2], ' '));
        tmpFloat = float(split(a[17+i*2+1], ' '));
        
        nn1.output[i].n = (int)tmpInt[0];
        nn1.output[i].c = tmpInt[1];
        nn1.output[i].bias = tmpInt[2];
        nn1.output[i].bias_c = tmpInt[3];
        
        for (int j=0; j<tmpFloat.length-1; j++) {
            nn1.output[i].weight[j] = tmpFloat[j];
        }
    }
}

void keyPressed() {
    if (keyCode == UP) {
        player.jump();
    }
    
    if (keyCode == LEFT) {
        player.movingLeft = true;
    }
    
    if (keyCode == RIGHT) {
        player.movingRight = true;
    }
    
    if (key == ' ') {
        a1.toggleTraining = !a1.toggleTraining;
    }
    
    if (key == 's') {
        serialiseNetworks();
    }
}

void keyReleased() {
    if (keyCode == LEFT)
    	player.movingLeft = false;
    
    if (keyCode == RIGHT)
        player.movingRight = false;
}
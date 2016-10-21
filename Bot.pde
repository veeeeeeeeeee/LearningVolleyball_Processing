class Bot extends Agent {
    Network network;

    PVector[] inp;
    float[] input; // for the NN
    boolean[] decision;
    boolean isTraining;
    boolean toggleTraining;
    
    Bot(PVector _pos, float _ground, float _radius, float _gravity, Network _network, Net _n) {
        super(_pos, _ground, _radius, _gravity, _n);

        network = _network;

        inp = new PVector[3];
        for (int i=0; i<3; i++)
            inp[i] = new PVector();
        
        decision = new boolean[5];
        input = new float[6];
        
        isTraining = true;
        toggleTraining = true;
    }

    // bot on right hand side, inputs get mapped to left hand side, revert decision
    void mapInp(PVector[] inp) {
        inp[0].x = width - inp[0].x;
        inp[1].x = width - inp[1].x;
        inp[2].x *= -1.0f;
    }
    
    // get float inputs for the NN
    void genInputs(PVector[] inp) {
        for (int i=0; i<inp.length-1; i++) {
            input[i*2] = inp[i].x / (width/2);
            input[i*2+1] = inp[i].y / ground;
        }
        input[input.length-2] = inp[inp.length-1].x / 10.0f;
        input[input.length-1] = inp[inp.length-1].y / 10.0f;
    }
    
    void update(Net net, Ball ball, boolean lr) {
        /*
        if (frameCount % 20 == 0)
        if (random(1.0) > 0.5)
          movingLeft = true;
        else movingLeft = false;

        if (frameCount % 20 == 10)
        if (random(1.0, 2.0) > 1.5)
          movingRight = true;
        else movingRight = false;

        if (frameCount % 40 == 0)
        if (random(1.0) > 0.1)
          jump();
        */
        
        isTraining = true;
        decision[MLEFT] = decision[MRIGHT] = decision[JUMP] = decision[LJUMP] = decision[RJUMP] = false;
        movingLeft = movingRight = false;
        
        // get inputs and feed forward
        inp[0] = new PVector(pos.x, pos.y);
        inp[1] = new PVector(ball.pos.x, ball.pos.y);
        inp[2] = new PVector(ball.vel.x, ball.vel.y);
        if (lr) mapInp(inp);
        genInputs(inp);
        
        //for (int i=0; i<input.length; i++) {
        //    print(input[i] + " ");
        //}
        //println();
        
        int d = network.feedForward(input);
        int desired = desiredControl(net, ball);
        
        //d = desired;
        decision[d] = true;
        if (lr) { // revert output for bot on right hand side
            if (d < 2) {
                decision[d] = false;
                decision[1-d] = true;
            }
            if (d > 2) {
                decision[d] = true;
                decision[7-d] = false;
            }
        }
        
        if (decision[MLEFT] || decision[LJUMP]) {
            movingLeft = true;
            //print("left ");
        }
        if (decision[MRIGHT] || decision[RJUMP]) {
            movingRight = true;
            //print("right ");
        }
        if (decision[JUMP] || decision[LJUMP] || decision[RJUMP]) {
            jump();
            //print("jump ");
        }
        
        super.update();
        
        if (desired == MLEFT || desired == LJUMP) {
            //print("- left ");
        }
        if (desired == MRIGHT || desired == RJUMP) {
            //print("- right ");
        }
        if (desired == JUMP || desired == LJUMP || desired == RJUMP) {
            //print("jump");
        }
        //println();
        
        // only train when ball approaches the agent
        if (ball.pos.x > net.tr.x && ball.vel.x > 0)
            isTraining = false;
        
        if (isTraining && toggleTraining)
            network.backwardPropagate(desired);
    }
    
    // preprogrammed AI
    int desiredControl(Net net, Ball ball) {
        if (ball.vel.mag() == 0) {
            return MRIGHT;
        }
        
        // workout where the ball will fall
        boolean ballguess = true;
        Ball tmp = new Ball(ball.pos, gravity, ball.radius);
        tmp.vel = new PVector(ball.vel.x, ball.vel.y);
        
        PVector fallLoc = new PVector(0, 0);
        do {
            tmp.update();
            tmp.collideNet(net);
            
            if (tmp.pos.y >= ground - radius) {
                fallLoc = new PVector(tmp.pos.x, tmp.pos.y);
                ballguess = false;
            }
        } while (ballguess);
        
        // jump or not,
        if (PVector.dist(ball.pos, pos) < 230 && ball.pos.y < ground - radius) {
            // if close enough, just jump
            if (abs(ball.pos.x - pos.x) < radius*0.75)
                return JUMP;
            
            // jumps left or right
            if (fallLoc.x > pos.x)
                return RJUMP;
            else return LJUMP;
        }
        
        // not jumping
        if (fallLoc.x > pos.x)
            return MRIGHT;
        else return MLEFT;
    }
    
    void render (boolean lr) {
       PVector nn_pos = new PVector();
        
        if (!lr)
            nn_pos = new PVector(30, 10);
        else nn_pos = new PVector(550, 10);
        
        // display the activation of the NN
        for (int i=0; i<network.hidden.length; i++) {
            float c = network.hidden[i].activate(network.hidden[i].feedForward());
            noStroke();
            fill((1-c) * 255.0f);
            ellipse(nn_pos.x, nn_pos.y, 10, 10);
            nn_pos.x += 15;
        }
        if (!lr)
            nn_pos.x = 30;
        else nn_pos.x = 550;
        
        nn_pos.y += 15;
        for (int i=0; i<network.output.length; i++) {
            float c = network.output[i].activate(network.output[i].feedForward());
            noStroke();
            fill((1-c) * 255.0f);
            ellipse(nn_pos.x, nn_pos.y, 10, 10);
            nn_pos.x += 15;
        }
        
        if (!lr) {
            stroke(205, 115, 0);
            fill(255, 165, 0);
        }
        else {
            stroke(98, 0, 161);
            fill(148, 0, 211);
        }
            
        super.render();
    }
}
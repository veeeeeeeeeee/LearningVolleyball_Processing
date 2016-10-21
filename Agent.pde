class Agent {
    PVector pos;
    PVector oriPos;
    PVector vel;
    
    float jumpSpd;
    float moveSpd;
    float ground;
    float radius;
    float gravity;
    int lr;
    
    boolean movingLeft;
    boolean movingRight;
    
    int score;
    Net net;
    
    Agent(PVector _pos, float _ground, float _radius, float _gravity, Net _n) {
        pos = _pos;
        oriPos = pos;
        ground = _ground;
        radius = _radius;
        gravity = _gravity;
        net = _n;
        
        vel = new PVector(0, 0);
        movingLeft = movingRight = false;
        
        jumpSpd = 8.0;
        moveSpd = 5.0;
        lr = 0;
        
        score = 0;
    }

    void moveLeft() {
        lr --;
    }
    
    void moveRight() {
        lr ++;
    }
    
    void jump() {
        if (pos.y >= ground)
        	vel.y = -jumpSpd;
    }
    
    void update() {
        lr = 0;
        
        if (movingLeft)
            moveLeft();
        
        if (movingRight)
            moveRight();
        
        vel.x = lr*moveSpd;
        vel.y -= gravity;
        
        pos = PVector.add(pos, vel);
        
        if (pos.y >= ground) {
            pos.y = oriPos.y;
            vel.y = 0;
        }
        
        if (pos.x >= width - radius)
            pos.x = width - radius;
        
        if (pos.x <= 410 + radius && pos.x > 390)
            pos.x = 410 + radius;
            
        if (pos.x <= radius)
            pos.x = radius;
        
        if (pos.x >= 390 - radius && pos.x < 410)
            pos.x = 390 - radius;
    }
    
    void render() {
        pushMatrix();
        
        arc(pos.x, pos.y, radius*2, radius*2, -PI, 0);
        line(pos.x - radius, pos.y, pos.x + radius, pos.y);
        
        popMatrix();
    }
}
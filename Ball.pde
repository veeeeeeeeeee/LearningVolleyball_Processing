class Ball {
    PVector oriPos;
    PVector pos;
    PVector vel;

    float gravity;
    float radius;
    float maxSpd;

    Ball(PVector _pos, float _gravity, float _radius) {
        pos = _pos;
        oriPos = pos;

        gravity = _gravity;
        radius = _radius;

        vel = new PVector(0, 0);

        maxSpd = 7.5;
    }

    void reset() {
        pos = oriPos;
        vel = new PVector(0, 0);
    }

    void iniVel() {
        vel = PVector.random2D();

        vel.normalize();
        vel.mult(maxSpd);

/*
        if (vel.y > 0)
        	vel.y = - vel.y;
        vel.x *= -1.0;
        */
        vel.x = -abs(vel.x);
        
        vel.normalize();
        vel.mult(maxSpd);
    }

    void collideNet(Net n) {
        // collide body
        collideCircle(new PVector(0, -1), new PVector(n.tl.x + n.w/2, n.tl.y), n.w/2);

        if (pos.y >= n.tr.y && pos.y <= ground) {
            if (pos.x < n.tr.x)
                bounceLeft(n.tl.x);

            if (pos.x > n.tl.x)
                bounceRight(n.tr.x);
        }
    }

    boolean collideCircle(PVector incVel, PVector c, float r) {
        PVector n = PVector.sub(pos, c);
        float d = n.mag();
        
        if (n.mag() <= r + radius && pos.y <= c.y) {    
            n.normalize();
            while (PVector.sub(pos, c).mag() <= r + radius)    
                pos = PVector.add(pos, n);
            
            PVector u = PVector.sub(vel, incVel);
            PVector un = PVector.mult(n, PVector.dot(u, n) * 2);
            u = PVector.sub(u, un);

            vel = PVector.add(u, incVel);
            vel.mult(0.5);
            PVector v2 = new PVector(vel.x, vel.y);
            vel.add(v2.normalize().mult(0.4));
            
            return true;
        }
        return false;
    }
    
    void bounceLeft(float x) {
        if (pos.x >= x - radius) {
            pos.x = x - radius;
            vel.x = -vel.x;
        }
    }

    void bounceRight(float x) {
        if (pos.x <= x + radius) {
            pos.x = x + radius;
            vel.x = -vel.x;
        }
    }


    void update() {
        vel.y -= gravity;

        // bounce back from wall
        bounceLeft(width);
        bounceRight(0);

        if (pos.y <= radius) {
            pos.y = radius;
            vel.y = -vel.y;
        }

        pos = PVector.add(pos, vel);
    }

    void render() {
        stroke(100);
        fill(200);

        ellipse(pos.x, pos.y, radius*2, radius*2);
        line(pos.x, pos.y, PVector.add(pos, PVector.mult(vel, 5)).x, PVector.add(pos, PVector.mult(vel, 5)).y);
    }
    
    PVector getp() {
        return pos;
    }
    PVector getv() {
        return vel;
    }
}
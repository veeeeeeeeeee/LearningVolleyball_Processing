class Net {
    // top right, bottom left, top left bottom right
    PVector tr, bl, tl, br;

    float w, h;

    Net() {
        // middle of the map
        tl = new PVector(390, 360);
        tr = new PVector(410, 360);
        
        bl = new PVector(390, 400);
        br = new PVector(410, 400);
        
        w = tr.x - bl.x;
        h = bl.y - tr.y;
    }

    void render() {
        pushMatrix();
        noStroke();
        fill(50, 205, 50);
        rect(tl.x, tl.y, w, h);
        ellipse(tl.x + w/2, tl.y, w, w);
        popMatrix();
    }
}
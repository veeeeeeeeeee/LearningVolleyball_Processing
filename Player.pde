class Player extends Agent {
    Player(PVector _pos, float _ground, float _radius, float _gravity, Net _n) {
        super(_pos, _ground, _radius, _gravity, _n);
    }
    
    void render() {
        stroke(56, 40, 155);
        fill(106, 90, 205);
        
        super.render();
    }
}
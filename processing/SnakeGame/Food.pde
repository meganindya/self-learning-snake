class Food {
  PVector pos;

  Food() {
    int x = SIZE + floor(random(38)) * SIZE + 400;
    int y = SIZE + floor(random(38)) * SIZE;
    pos = new PVector(x, y);
  }

  void show() {
    noStroke();
    fill(255, 0, 0);
    rect(pos.x, pos.y, SIZE, SIZE);
  }

  Food clone() {
    Food f = new Food();
    f.pos.x = this.pos.x;
    f.pos.y = this.pos.y;
    return f;
  }
}

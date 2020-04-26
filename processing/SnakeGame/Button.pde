class Button {
  float X, Y, W, H;
  String text;

  Button(float X, float Y, float W, float H, String text) {
    this.X = X;
    this.Y = Y;
    this.W = W;
    this.H = H;
    this.text = text;
  }

  boolean collide(float x, float y) {
    if (x >= X - W / 2 && x <= X + W / 2 && y >= Y - H / 2 && y <= Y + H / 2) {
      return true;
    }
    return false;
  }

  void show() {
    fill(255);
    stroke(0);
    rectMode(CENTER);
    rect(X, Y, W, H);
    textSize(22);
    textAlign(CENTER, CENTER);
    fill(0);
    noStroke();
    text(text, X, Y - 3);
  }
}

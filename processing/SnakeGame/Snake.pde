class Snake {
  int score = 1;
  int lifeLeft = 300;
  int lifeTime = 0;
  int foodIterator = 0;
  PVector velocity;

  float fitness = 0;

  boolean dead = false;
  boolean replay = false;

  float vision[];
  float decision[];

  PVector head;
  ArrayList<PVector> body;
  ArrayList<Food> foodList;

  Food food;
  NeuralNetwork brain;

  Snake() {
    this(hiddenLayers);
  }

  Snake(int hLayers) {
    head = new PVector(800, height / 2);
    food = new Food();
    body = new ArrayList<PVector>();
    velocity = new PVector(0, 0);

    if (!humanPlaying) {
      vision = new float[24];
      decision = new float[4];
      foodList = new ArrayList<Food>();
      foodList.add(food.clone());
      brain = new NeuralNetwork(24, hiddenNodes, 4, hLayers);
      body.add(new PVector(800, (height / 2) + SIZE));
      body.add(new PVector(800, (height / 2) + SIZE * 2));
      score += 2;
    }
  }

  Snake(ArrayList<Food> foodList) {
    replay = true;
    vision = new float[24];
    decision = new float[4];
    this.foodList = new ArrayList<Food>(foodList.size());
    for (Food food : foodList) {
      this.foodList.add(food.clone());
    }
    food = foodList.get(foodIterator);
    foodIterator++;
    head = new PVector(800, height / 2);
    body = new ArrayList<PVector>();
    body.add(new PVector(800, (height / 2) + SIZE));
    body.add(new PVector(800, (height / 2) + SIZE * 2));
    score += 2;
  }

  boolean bodyCollide(float x, float y) {
    for (int i = 0; i < body.size(); i++) {
      if (x == body.get(i).x && y == body.get(i).y) {
        return true;
      }
    }
    return false;
  }

  boolean foodCollide(float x, float y) {
    if (x == food.pos.x && y == food.pos.y) {
      return true;
    }
    return false;
  }

  boolean wallCollide(float x, float y) {
    if (x >= width - SIZE || x < 400 + SIZE || y >= height - SIZE || y < SIZE) {
      return true;
    }
    return false;
  }

  void show() {
    food.show();

    noStroke();
    fill(255);
    for (int i = 0; i < body.size(); i++) {
      rect(body.get(i).x, body.get(i).y, SIZE, SIZE);
    }

    if(dead) {
      fill(150);
    } else {
      fill(255);
    }
    rect(head.x, head.y, SIZE, SIZE);
  }

  void move() {
    if (!dead) {
      if (!humanPlaying && !modelLoaded) {
        lifeTime++;
        lifeLeft--;
      }
      if (foodCollide(head.x, head.y)) {
        eat();
      }
      shiftBody();
      if (
        wallCollide(head.x, head.y) ||
        bodyCollide(head.x, head.y) ||
        (lifeLeft <= 0 && !humanPlaying)
      ) {
        dead = true;
      }
    }
  }

  void eat() {
    int len = body.size() - 1;
    score++;
    if (!humanPlaying && !modelLoaded) {
      lifeLeft = min(500, lifeLeft + 100);
    }
    if (len >= 0) {
      body.add(new PVector(body.get(len).x, body.get(len).y));
    } else {
      body.add(new PVector(head.x, head.y)); 
    }
    if (!replay) {
      food = new Food();
      while (bodyCollide(food.pos.x, food.pos.y)) {
        food = new Food();
      }
      if (!humanPlaying) {
        foodList.add(food);
      }
    } else {
      food = foodList.get(foodIterator);
      foodIterator++;
    }
  }

  void shiftBody() {
    head.x += velocity.x;
    head.y += velocity.y;

    float tempx = head.x;
    float tempy = head.y;

    for (int i = 0; i < body.size(); i++) {
      float temp2x = body.get(i).x;
      float temp2y = body.get(i).y;
      body.get(i).x = tempx;
      body.get(i).y = tempy;
      tempx = temp2x;
      tempy = temp2y;
    }
  }

  Snake cloneForReplay() {
    Snake clone = new Snake(foodList);
    clone.brain = brain.clone();
    return clone;
  }

  Snake clone() {
    Snake clone = new Snake(hiddenLayers);
    clone.brain = brain.clone();
    return clone;
  }

  Snake crossover(Snake s) {
    Snake crossed = new Snake(hiddenLayers);
    crossed.brain = brain.crossover(s.brain);
    return crossed;
  }

  void mutate() {
    brain.mutate(mutationRate);
  }

  void calculateFitness() {
    if (score < 10) {
      fitness = floor(lifeTime * lifeTime) * pow(2, score);
    } else {
      fitness = floor(lifeTime * lifeTime);
      fitness *= pow(2, 10);
      fitness *= score - 9;
    }
  }

  float[] lookInDirection(PVector direction) {
    float look[] = new float[3];
    PVector pos = new PVector(head.x, head.y);
    float distance = 0;
    boolean foodFound = false;
    boolean bodyFound = false;
    pos.add(direction);
    distance += 1;

    while (!wallCollide(pos.x, pos.y)) {
      if (!foodFound && foodCollide(pos.x, pos.y)) {
        foodFound = true;
        look[0] = 1;
      }
      if (!bodyFound && bodyCollide(pos.x, pos.y)) {
        bodyFound = true;
        look[1] = 1;
      }
      if (replay && showVision) {
        stroke(0, 255, 0);
        point(pos.x, pos.y);
        if (foodFound) {
          noStroke();
          fill(255, 255, 51);
          ellipseMode(CENTER);
          ellipse(pos.x, pos.y, 5, 5);
        }
        if(bodyFound) {
          noStroke();
          fill(102, 0, 102);
          ellipseMode(CENTER);
          ellipse(pos.x, pos.y, 5, 5);
        }
      }
      pos.add(direction);
      distance += 1;
    }

    if (replay && showVision) {
      noStroke();
      fill(0, 255, 0);
      ellipseMode(CENTER);
      ellipse(pos.x, pos.y, 5, 5);
    }

    look[2] = 1 / distance;
    return look;
  }

  void look() {
    vision = new float[24];
    float temp[] = lookInDirection(new PVector(-SIZE, 0));
    vision[0] = temp[0];
    vision[1] = temp[1];
    vision[2] = temp[2];
    temp = lookInDirection(new PVector(-SIZE, -SIZE));
    vision[3] = temp[0];
    vision[4] = temp[1];
    vision[5] = temp[2];
    temp = lookInDirection(new PVector(0, -SIZE));
    vision[6] = temp[0];
    vision[7] = temp[1];
    vision[8] = temp[2];
    temp = lookInDirection(new PVector(SIZE, -SIZE));
    vision[9] = temp[0];
    vision[10] = temp[1];
    vision[11] = temp[2];
    temp = lookInDirection(new PVector(SIZE, 0));
    vision[12] = temp[0];
    vision[13] = temp[1];
    vision[14] = temp[2];
    temp = lookInDirection(new PVector(SIZE, SIZE));
    vision[15] = temp[0];
    vision[16] = temp[1];
    vision[17] = temp[2];
    temp = lookInDirection(new PVector(0, SIZE));
    vision[18] = temp[0];
    vision[19] = temp[1];
    vision[20] = temp[2];
    temp = lookInDirection(new PVector(-SIZE, SIZE));
    vision[21] = temp[0];
    vision[22] = temp[1];
    vision[23] = temp[2];
  }

  void think() {
    decision = brain.output(vision);
    int maxIndex = 0;
    float max = 0;

    for (int i = 0; i < decision.length; i++) {
      if (decision[i] > max) {
        max = decision[i];
        maxIndex = i;
      }
    }

    switch (maxIndex) {
      case 0:
        moveUp();
        break;
      case 1:
        moveDown();
        break;
      case 2:
        moveLeft();
        break;
      case 3:
        moveRight();
        break;
    }
  }

  void moveUp() {
    if (velocity.y != SIZE) {
      velocity.x = 0;
      velocity.y = -SIZE;
    }
  }

  void moveDown() {
    if (velocity.y != -SIZE) {
      velocity.x = 0;
      velocity.y = SIZE;
    }
  }

  void moveLeft() {
    if (velocity.x != SIZE) {
      velocity.x = -SIZE;
      velocity.y = 0;
    }
  }

  void moveRight() {
    if (velocity.x != -SIZE) {
      velocity.x = SIZE;
      velocity.y = 0;
    }
  }
}

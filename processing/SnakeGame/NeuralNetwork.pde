class NeuralNetwork {
  int iNodes, hNodes, oNodes, hLayers;
  Matrix weights[];

  NeuralNetwork(int iNodes, int hNodes, int oNodes, int hLayers) {
    this.iNodes = iNodes;
    this.hNodes = hNodes;
    this.oNodes = oNodes;
    this.hLayers = hLayers;

    weights = new Matrix[hLayers + 1];
    weights[0] = new Matrix(hNodes, iNodes + 1);
    for (int i = 0; i < hLayers; i++) {
      weights[i] = new Matrix(hNodes, hNodes + 1);
    }
    weights[hLayers] = new Matrix(oNodes, hNodes + 1);

    for (Matrix w : weights) {
      w.randomize();
    }
  }

  void mutate(float mutationRate) {
    for (Matrix m : weights) {
      m.mutate(mutationRate);
    }
  }

  float[] output(float inputs[]) {
    Matrix inpMatrix = weights[0].toColumnMatrix(inputs);
    Matrix curr_bias = inpMatrix.addBias();

    for (int i = 0; i < hLayers; i++) {
      Matrix hiddenInp = weights[i].dot(curr_bias);
      Matrix hiddenOut = hiddenInp.activate();
      curr_bias = hiddenOut.addBias();
    }

    Matrix outputInp = weights[hLayers].dot(curr_bias);
    Matrix output = outputInp.activate();

    return output.toArray();
  }

  NeuralNetwork crossover(NeuralNetwork n) {
    NeuralNetwork crossed = new NeuralNetwork(iNodes, hNodes, oNodes, hLayers);
    for (int i = 0; i < weights.length; i++) {
      crossed.weights[i] = weights[i].crossover(n.weights[i]);
    }
    return crossed;
  }

  NeuralNetwork clone() {
    NeuralNetwork n = new NeuralNetwork(iNodes, hNodes, oNodes, hLayers);
    for (int i = 0; i < weights.length; i++) {
      n.weights[i] = weights[i].clone();
    }
    return n;
  }

  void load(Matrix weights[]) {
    for (int i = 0; i < weights.length; i++) {
      this.weights[i] = weights[i];
    }
  }

  Matrix[] pull() {
    return weights.clone();
  }

  void show(
    float x, float y, float w, float h, float vision[], float decision[]
  ) {
    float space = 5;
    float nSize = (h - (space * (iNodes - 2))) / iNodes;
    float nSpace = (w - (weights.length * nSize)) / weights.length;
    float hBuff = (h - (space * (hNodes - 1)) - (nSize * hNodes)) / 2;
    float oBuff = (h - (space * (oNodes - 1)) - (nSize * oNodes)) / 2;

    int maxIndex = 0;
    for (int i = 1; i < decision.length; i++) {
      if (decision[i] > decision[maxIndex]) {
        maxIndex = i;
      }
    }

    int layerCount = 0;

    for (int i = 0; i < iNodes; i++) {
      if (vision[i] != 0) {
        fill(0, 255, 0);
      } else {
        fill(255);
      }
      stroke(0);
      ellipseMode(CORNER);
      ellipse(x, y + i * (nSize + space), nSize, nSize);
      textSize(nSize / 2);
      textAlign(CENTER, CENTER);
      fill(0);
      text(i, x + nSize / 2, y + (nSize / 2) + i * (nSize + space));
    }

    layerCount++;

    for (int l = 0; l < hLayers; l++) {
      for (int i = 0; i < hNodes; i++) {
        fill(255);
        stroke(0);
        ellipseMode(CORNER);
        ellipse(
          x + (layerCount * nSize) + (layerCount * nSpace),
          y + hBuff + (i * (nSize + space)),
          nSize, nSize
        );
      }
      layerCount++;
    }

    for (int i = 0; i < oNodes; i++) {
      if (i == maxIndex) {
        fill(0, 255, 0);
      } else {
        fill(255);
      }
      stroke(0);
      ellipseMode(CORNER);
      ellipse(
        x + (layerCount * nSpace) + (layerCount * nSize),
        y + oBuff + (i * (nSize + space)),
        nSize, nSize
      );
    }

    layerCount = 1;

    for (int i = 0; i < weights[0].rows; i++) {
      for (int j = 0; j < weights[0].cols-1; j++) {
          if (weights[0].matrix[i][j] < 0) {
            stroke(255, 0, 0);
          } else {
            stroke(0, 0, 255);
          }
          line(
            x + nSize,
            y + (nSize / 2) + (j * (space + nSize)),
            x + nSize + nSpace,
            y + hBuff + (nSize / 2) + (i * (space + nSize))
          );
      }
    }

    layerCount++;

    for (int l = 1; l < hLayers; l++) {
      for (int i = 0; i < weights[l].rows; i++) {
        for (int j = 0; j < weights[l].cols - 1; j++) {
            if (weights[l].matrix[i][j] < 0) {
              stroke(255, 0, 0);
            } else {
              stroke(0, 0, 255);
            }
            line(
              x + (layerCount * nSize) + ((layerCount - 1) * nSpace),
              y + hBuff + (nSize / 2) + (j * (space + nSize)),
              x + (layerCount * nSize) + (layerCount * nSpace),
              y + hBuff + (nSize / 2) + (i * (space + nSize))
            );
        }
      }
      layerCount++;
    }

    for (int i = 0; i < weights[weights.length - 1].rows; i++) {
      for (int j = 0; j < weights[weights.length - 1].cols - 1; j++) {
        if (weights[weights.length - 1].matrix[i][j] < 0) {
          stroke(255, 0, 0);
        } else {
          stroke(0, 0, 255);
        }
        line(
          x + (layerCount * nSize) + ((layerCount - 1) * nSpace),
          y + hBuff + (nSize / 2) + (j * (space + nSize)),
          x + (layerCount * nSize) + (layerCount * nSpace),
          y + oBuff + (nSize / 2) + (i * (space + nSize))
        );
      }
    }

    fill(0);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(
      "U",
      x + (layerCount * nSize) + (layerCount * nSpace) + (nSize / 2),
      y + oBuff + (nSize / 2)
    );
    text(
      "D",
      x + (layerCount * nSize) + (layerCount * nSpace) + (nSize / 2),
      y + oBuff + space + nSize + (nSize / 2)
    );
    text(
      "L",
      x + (layerCount * nSize) + (layerCount * nSpace) + (nSize / 2),
      y + oBuff + (2 * space) + (2 * nSize) + (nSize / 2)
    );
    text(
      "R",
      x + (layerCount * nSize) + (layerCount * nSpace) + (nSize / 2),
      y + oBuff + (3 * space) + (3 * nSize) + (nSize / 2)
    );
  }
}

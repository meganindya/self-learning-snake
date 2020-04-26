class NeuralNetwork {
  int iNodes, hNodes, oNodes, hLayers;
  Matrix weights[];

  NeuralNetwork(int iNodes, int hNodes, int oNodes, int hLayers) {
    this.iNodes = iNodes;
    this.hNodes = hNodes;
    this.oNodes = oNodes;
    this.hLayers = hLayers;

    weights = new Matrix[hLayers + 1];
    weights[0] = new Matrix[hNodes, iNodes + 1];
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
      weights[i] = weight[i];
    }
  }

  Matrix[] pull() {
    return weights.clone();
  }
}

class Matrix {
  int rows, cols;
  float matrix[][];

  Matrix(int rows, int cols) {
    this.rows = rows;
    this.cols = cols;

    matrix = new float[rows][cols];
  }

  Matrix(float matrix[][]) {
    this.matrix = matrix;
    rows = matrix.length;
    cols = matrix[0].length;
  }

  void print() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        print(matrix[i][j] + " ");
      }
      println();
    }
    println();
  }

  Matrix dot(Matrix m) {
    if (cols == m.rows) {
      Matrix result = new Matrix(rows, m.cols);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < m.cols; j++) {
          float sum = 0;
          for (int k = 0; k < cols; k++) {
            sum += matrix[i][k] * m[k][j];
          }
          result.matrix[i][j] = sum;
        }
      }
      return result;
    }
    return null;
  }

  void randomize() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        matrix[i][j] = random(-1, 1);
      }
    }
  }

  Matrix toColumnMatrix(float arr[]) {
    Matrix m = new Matrix(arr.length, 1);
    for (int i = 0; i < arr.length; i++) {
      m.matrix[i][0] = arr[i];
    }
    return m;
  }

  float[] toArray() {
    float arr[] = new float(rows * cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        arr[i * cols + j] = matrix[i][j];
      }
    }
    return arr;
  }

  Matrix addBias() {
    Matrix m = new Matrix(rows + 1, 1);
    for (int i = 0; i < rows; i++) {
      m.matrix[i][0] = matrix[i][0];
    }
    m.matrix[rows][0] = 1;
    return m;
  }

  Matrix activate() {
    Matrix m = new Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m.matrix[i][j] = relu(matrix[i][j]);
      }
    }
    return m;
  }

  float relu(float x) {
    return max(0, x);
  }

  void mutate(float mutationRate) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float rand = random(1);
        if (rand < mutationRate) {
          matrix[i][j] += randomGaussian() / 5;
          matrix[i][j] = min(matrix[i][j], 1);
          matrix[i][j] = max(matrix[i][j], -1);
        }
      }
    }
  }

  Matrix crossover(Matrix m) {
    Matrix crossed = new Matrix(rows, cols);

    int randR = floor(random(rows));
    int randC = floor(random(cols));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if ((i < randR) || (i == randR && j <= randC)) {
          crossed.matrix[i][j] = matrix[i][j];
        } else {
          crossed.matrix[i][j] = m.matrix[i][j];
        }
      }
    }

    return crossed;
  }

  Matrix clone() {
    Matrix m = new Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m.matrix[i][j] = matrix[i][j];
      }
    }
    return m;
  }
}

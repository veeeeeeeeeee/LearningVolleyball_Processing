class Perceptron {
    int n; // number of inputs, weights
    float c; // learning rate
    
    float bias;
    float bias_c; // bias modification rate
    
    float[] weight;
    float[] input;
    
    Perceptron(int _n) {
        n = _n;
        
        // randomise bias & weights in the beginning
        bias = random(-2, 2);
        weight = new float[n];
        for (int i=0; i<n; i++) {
            weight[i] = random(-1, 1);
        }
        input = new float[n];
        
        // learning Rate
        c = 0.005f;
        // bias gets modified a lot less
        bias_c = c / 50.0f;
    }
    
    // sum of inputs*weights + bias
    float feedForward() {
        float sum = 0;
        
        for (int i=0; i<n; i++) {
            sum += input[i] * weight[i];
        }
        
        return sum + bias;
    }
    
    // sigmoid
    float activate(float sum) {
        return 1/(1+exp(-sum));
    }
    
    // modify its own set of weights
    void train(float deriErr) {
        float delta;
        
        // delta = d(Etotal)/d(net)
        // d(Etotal)/d(net) = d(Etotal)/d(out) * d(out)/d(net)
        // delta = deriErr * deriOut
        float net = feedForward();
        float output = activate(net);
        
        // deriErr can be -(target - output) or sum(allOutputs.backDerivative)
        float deriOut = output * (1-output);
        
        delta = deriErr * deriOut;
        // d(Etotal)/d(w) = delta * d(net)/d(w)
        // weight modification = constant * delta * deriNet
        for (int i=0; i<n; i++) {
            float deriNet = input[i];
            
            weight[i] = weight[i] + c * delta * deriNet;
        }
        bias = bias - c * delta * 1;
    }
    
    // back propagate the derivative of error for the required weight
    // modify the weights of previous layer
    float backDerivative(float deriErr, float prevWeight) {
        // d(Etotal)/d(w) = d(Etotal)/d(out) * d(out)/d(net) * d(net)/d(prevWeight)
        // backDerivative = deriErr * deriOut * deriNet
        
        float net = feedForward();
        float output = activate(net);
        
        float deriOut = output * (1-output);
        float deriNet = prevWeight;
        
        return deriErr * deriOut * deriNet;
    }
}
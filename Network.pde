class Network implements Serializable {
    int n, n_hidden;
    
    Perceptron[] hidden;
    Perceptron[] output;
    
    Network(int n_input, int n_hidden, int n_output) {
        n = n_input;
        this.n_hidden = n_hidden;
        hidden = new Perceptron[n_hidden];
        output = new Perceptron[n_output];
        
        for (int i=0; i<n_hidden; i++) {
            hidden[i] = new Perceptron(n_input);
        }
        
        for (int i=0; i<n_output; i++) {
            output[i] = new Perceptron(n_hidden);
        }
    }
    
    // which one is triggerd? left, right or jump perceptron
    int feedForward(float[] input) {
        float[] hidden_forward = new float[hidden.length];
        // hidden_forward are fedForward results of hidden layer
        // give hidden layer the inputs
        for (int i=0; i<hidden.length; i++) {
            arrayCopy(input, hidden[i].input);
            hidden_forward[i] = hidden[i].activate(hidden[i].feedForward());
            //print(hidden[i].feedForward() + " ");
        }
        //println();
        
        //for (int i=0; i<hidden_forward.length; i++) {
        //    print(hidden_forward[i] + " ");
        //}
        //println();
        
        float[] output_forward = new float[output.length];
        // output_forward are fedForward results of output layer
        // give output layer the inputs, which is hidden_forward
        for (int i=0; i<output.length; i++) {
            arrayCopy(hidden_forward, output[i].input);
            output_forward[i] = output[i].activate(output[i].feedForward());
            //print(output_forward[i] + " ");
        }
        //println();
        
        // maximum of 5 outputs will trigger the action MLEFT, MRIGHT, JUMP, LJUMP or RJUMP
        float maxSignal = output_forward[0];
        int decision = 0;
        for (int i=0; i<output_forward.length; i++) {
            //print(output_forward[i] + " ");
            if (maxSignal < output_forward[i]) {
                maxSignal = output_forward[i];
                decision = i;
            }
        }
        //println();
        
        return decision;
    }
    
    // train the whole network
    void backwardPropagate(int desired) {
        for (int i=0; i<output[0].input.length; i++) {
          print(output[0].input[i] + " ");
        }
        println();
        for (int i=0; i<output.length; i++) {
          print(output[i].activate(output[i].feedForward()) + " ");
        }
        println();
        
        // start from output layer
        float[] errOut = new float[output.length];
        
        // estimate roughly derivative of ErrorTotal
        if (desired == JUMP) {
            errOut[JUMP] = 1; // should not move left or right while only jumping is needed
            errOut[MLEFT] = -0.25;
            errOut[MRIGHT] = -0.25;
            errOut[RJUMP] = 0.25;
            errOut[LJUMP] = 0.25;
        }
        else {
            // if left, jumpLeft weight should also be increased & vice versa
            // right likewise
            if (desired < 2) {
                errOut[desired] = 1; // if moving left is desired, errOut[left] = 1; errOut[right] = -0.75
                errOut[1-desired] = -0.75;
                errOut[JUMP] = -0.75;
                errOut[desired+3] = 0.75; // if moving left, errOut[ljump] = 0.75, errOut[rjump] = -0.75
                errOut[4-desired] = -0.75;
            }
            else {
                errOut[desired-3] = 0.75; // if jumping left, errOut[left] = 0.75, errOut[right] = -0.75
                errOut[4-desired] = -0.75;
                errOut[JUMP] = 0.25;
                errOut[desired] = 1; // if jumping left, errOut[ljump] = 1, errOut[rjump] = -0.75
                errOut[7-desired] = -0.75;
            }
        }
        
        // output.train takes deriErr
        // d(Etotal)/d(out[i]) = f(desired-output[i]), f being linear
        for (int i=0; i<output.length; i++) {
            output[i].train(errOut[i]);
        }
        
        // continue with hidden layer
        float[] errHidden = new float[hidden.length];
        
        // hidden.train takes deriErr
        // d(Etotal)/d(out) = sigma| d(E[i])/d(out)
        // errHidden[i] = sum(allOutputs.backDerivative(errOut, weight[i]))
        for (int i=0; i<hidden.length; i++) {
            errHidden[i] = 0;
            for (int j=0; j<output.length; j++) {
                errHidden[i] += output[j].backDerivative(errOut[j], output[j].weight[i]);
            }
            hidden[i].train(errHidden[i]);
        }
    }
    
    String writeData() {
        String tmp = "";
        
        tmp += str(n_hidden); tmp += "\n";
        for (int i=0; i<n_hidden; i++) {
            tmp += str(hidden[i].n); tmp += " ";
            tmp += str(hidden[i].c); tmp += " ";
            tmp += str(hidden[i].bias); tmp += " ";
            tmp += str(hidden[i].bias_c); tmp += "\n";
            
            for (int j=0; j<n; j++) {
                tmp += hidden[i].weight[j]; tmp += " ";
            }
            tmp += "\n";
        }
        for (int i=0; i<5; i++) {
            tmp += str(output[i].n); tmp += " ";
            tmp += str(output[i].c); tmp += " ";
            tmp += str(output[i].bias); tmp += " ";
            tmp += str(output[i].bias_c); tmp += "\n";
            
            for (int j=0; j<n_hidden; j++) {
                tmp += output[i].weight[j]; tmp += " ";
            }
            tmp += "\n";
        }
        
        return tmp;
    }
}
cm = sparse([1 1 1 2 2 3 4 4 4 5 5 6 6 7], ...
            [2 3 4 4 5 6 3 5 6 6 7 5 7 6],...
            [5 4 8 1 3 5 3 4 6 1 10 1 6 1],7, 7)
[M,F,K] = graphmaxflow(cm,1,7)
        h = view(biograph(cm,[],'ShowWeights','on'))
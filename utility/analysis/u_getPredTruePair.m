function [y_trueThisChannel, y_predThisChannel] = u_getPredTruePair(l3t, thisClass, thisChannel)
    [X, y_true]  = l3t.l3c.getClassData(thisClass);
    X = padarray(X, [0 1], 1, 'pre');
    y_pred = double(X * l3t.kernels{thisClass});
    y_trueThisChannel = y_true(:,thisChannel);
    y_predThisChannel = y_pred(:,thisChannel);
end
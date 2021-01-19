"use strict";

var tx = require('@tensorflow-models/toxicity');
require('@tensorflow/tfjs-node');

exports.toxicityImpl = function (threshold, sentences) {
    return function () {
        return tx.load(threshold).then(model => {
            return model.classify(sentences).then(predictions => {
                return predictions;
            });
        });
    };
};
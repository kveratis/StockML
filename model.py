from sklearn.cross_validation import cross_val_score
from sklearn.tree import DecisionTreeRegressor as Model
from sklearn.externals import joblib
import config
import numpy
import parse
import sys

def train(features, target):
    model = Model()
    model.fit(features, target)
    return model
    
def predict(model, new_features):
    preds = model.predict(new_features)
    return preds
    
def validate(predictions, reality, scoringFunction):
    scores = []
    for i in range(len(predictions)):
        scores.append(scoringFunction(predictions[i], reality[i]))
    return scores
    
def score_AtOrBelowWithPenalty(prediction, reality):
    diff = reality - prediction
    if(diff > 0):
        return 1000 - diff
    else:
        return 1000 - diff ** 2
        
def score_AtOrBelowWithCutoff(prediction, reality):
    diff = reality - prediction
    if(diff > 0):
        return 1000 - diff
    else:
        return 0
        
def score_AtOrAboveWithPenalty(prediction, reality):
    diff = reality - prediction
    if(diff < 0):
        return 1000 + diff
    else:
        return 1000 + diff ** 2
        
def score_AtOrAboveWithCutoff(prediction, reality):
    diff = reality - prediction
    if(diff < 0):
        return 1000 + diff
    else:
        return 0
        
def RootMeanSquareError(predicted_values, true_values):
    n = len(predicted_values)
    residuals = 0
    for i in range(n):
        residuals += (true_values[i] - predicted_values[i])**2
    return numpy.sqrt(residuals/n)
    
if __name__ == '__main__':
    ticker = sys.argv[1]
    target = sys.argv[2]
    target_ticker = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '>' else ticker
    
    train_features_file = "%s_training_features.npy" % ticker
    train_targets_file = "%s_training_target_%s.npy" % (target_ticker, target)
    test_features_files = "%s_testing_features.npy" % ticker
    test_targets_file = "%s_testing_target_%s.npy" % (target_ticker, target)
       
    print "Loading data..."
    train_features = numpy.load(train_features_file)
    train_targets = numpy.load(train_targets_file)
    test_features = numpy.load(test_features_files)
    test_targets = numpy.load(test_targets_file)
    
    print "Training model..."
    model = train(train_features, train_targets)
    print "Saving model to file..."
    joblib.dump(model, "%s_%s_model.pkl" % (ticker, target))
    # reconstitute via model = joblib.load("%s_%s_model.pkl" % (ticker, target))
    
    feature_params = model.feature_importances_
    print "Feature, Importance"
    for i in range(len(config.features)):
        print config.features[i], feature_params[i]
    
    print "Making predictions..."
    predictions = predict(model, test_features)
    print "Saving predictions to file..."
    numpy.save("%s_%s_predictions.npy" % (ticker, target), predictions)
    
    print "Scoring predictions..."
    scores = validate(predictions, test_targets, score_AtOrAboveWithCutoff)
    print "Saving scores to file..."
    numpy.save("%s_%s_scores.npy" % (ticker, target), scores)

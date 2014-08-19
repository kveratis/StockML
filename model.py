from sklearn.cross_validation import cross_val_score
from sklearn.tree import DecisionTreeRegressor as Model
from sklearn.externals import joblib
import numpy
import sys
import config

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
    '''
        call like 
        python model.py IBM 5DayWindowBestLongBuyPrice > test.txt
        python model.py GSPC 5DayWindowBestLongBuyPrice IBM > test.txt
    '''
    
    ticker = sys.argv[1]
    target = sys.argv[2]
    target_ticker = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '>' else ticker
    
    train_features_file = config.GetTrainingFeaturesFileName(ticker)
    train_targets_file = config.GetTrainingTargetsFileName(target_ticker, target)
    test_features_file = config.GetTestingFeaturesFileName(ticker)
    test_targets_file = config.GetTestingTargetsFileName(target_ticker, target)
    model_file = config.GetModelFileName(ticker, target, target_ticker)
    predictions_file = config.GetPredictionsFileName(ticker, target, target_ticker)
       
    print "Loading data..."
    train_features = numpy.load(train_features_file)
    train_targets = numpy.load(train_targets_file)
    test_features = numpy.load(test_features_file)
    test_targets = numpy.load(test_targets_file)
    
    print "Training model..."
    model = train(train_features, train_targets)
    print "Saving model to file..."
    joblib.dump(model, model_file)
    
    print "Making predictions..."
    predictions = predict(model, test_features)
    print "Saving predictions to file..."
    numpy.save("%s_%s_predictions.npy" % (ticker, target), predictions)
    
    print "Scoring predictions..."
    scores = validate(predictions, test_targets, score_AtOrAboveWithCutoff)
    print "Saving scores to file..."
    numpy.save("%s_%s_scores.npy" % (ticker, target), scores)

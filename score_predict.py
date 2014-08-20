from sklearn.cross_validation import cross_val_score
from sklearn.tree import DecisionTreeRegressor as Model
from sklearn.externals import joblib
import numpy
import sys
import config

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
        python score_predict.py IBM 5DayWindowBestLongBuyPrice
        python score_predict.py GSPC 5DayWindowBestLongBuyPrice IBM
    '''
    
    ticker = sys.argv[1]
    target = sys.argv[2]
    target_ticker = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '>' else ticker
    
    test_targets_file = config.GetTestingTargetsFileName(target_ticker, target)
    predictions_file = config.GetPredictionsFileName(ticker, target, target_ticker)
    scores_file = config.GetPredictionScoresFileName(ticker, target, target_ticker)
           
    print "Loading data..."
    predictions = numpy.load(predictions_file)
    test_targets = numpy.load(test_targets_file)
    
    print "Scoring predictions..."
    scores = validate(predictions, test_targets, score_AtOrAboveWithCutoff)
    
    print "Saving scores to file..."
    numpy.save(scores_file, scores)

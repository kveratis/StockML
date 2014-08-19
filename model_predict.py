from sklearn.cross_validation import cross_val_score
from sklearn.tree import DecisionTreeRegressor as Model
from sklearn.externals import joblib
import numpy
import sys

def predict(model, new_features):
    preds = model.predict(new_features)
    return preds

if __name__ == '__main__':
    '''
        call like 
        python model_predict.py IBM 5DayWindowBestLongBuyPrice
        python model_predict.py GSPC 5DayWindowBestLongBuyPrice IBM
    '''
    
    ticker = sys.argv[1]
    target = sys.argv[2]
    target_ticker = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '>' else ticker # Target Feature Set
    
    test_features_file = config.GetTestingFeaturesFileName(ticker)
    predictions_file = config.GetPredictionsFileName(ticker, target, target_ticker)
    model_file = config.GetModelFileName(ticker, target, target_ticker)
       
    # reconstitute trained model
    print "Loading model..."
    model = joblib.load(model_file)
    
    print "Loading data..."
    test_features = numpy.load(test_features_file)
    
    print "Making predictions..."
    predictions = predict(model, test_features)
    
    print "Saving predictions to file..."
    numpy.save(predictions_file, predictions)
            

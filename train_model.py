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

if __name__ == '__main__':
    '''
        call like 
        python train_model.py IBM 5DayWindowBestLongBuyPrice > test.txt
        python train_model.py GSPC 5DayWindowBestLongBuyPrice IBM > test.txt
    '''
    
    ticker = sys.argv[1]    # Training Feature Set
    target = sys.argv[2]    # Feature To Predict
    target_ticker = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '>' else ticker # Training Target Set
    
    train_features_file = config.GetTrainingFeaturesFileName(ticker)
    train_targets_file = config.GetTrainingTargetsFileName(target_ticker, target)
    model_file = config.GetModelFileName(ticker, target, target_ticker)
    
    print "Loading data..."
    train_features = numpy.load(train_features_file)
    train_targets = numpy.load(train_targets_file)
    
    print "Training model..."
    model = train(train_features, train_targets)
    print "Saving model to file..."
    joblib.dump(model, model_file)
    
    feature_params = model.feature_importances_
    print "Feature, Importance"
    for i in range(len(config.features)):
        print config.features[i], feature_params[i]
        

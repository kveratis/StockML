import config
import parse
import sys
import numpy
import operator
  
def extract_new_feature_name(feature, targetValue=None, newFeatureName=None):
    if newFeatureName != None:
        return newFeatureName
    elif targetValue != None:
        return "%s=%s" % (feature, targetValue)
    else:
        return feature
        
def extract_feature(data, feature, extractFunction, targetValue=None, newFeatureName=None):
    key = extract_new_feature_name(feature, targetValue, newFeatureName)
            
    for row in data:
        val = row[feature]
        newVal = extractFunction(val, targetValue)
        row[key] = newVal
    
    return key
    
def extract_category_indicator(curentValue, targetValue):
    if curentValue == targetValue:
        return "1"
    else:
        return "0"
    
def extract_feature_matrix(data, features, defaultValue=0):
    n_rows = len(data)
    n_cols = len(features)
    matrix = numpy.zeros((n_rows, n_cols), dtype=numpy.float)
    
    i = 0
    for row in data:
        j = 0
        for feature in features:
            matrix[i][j] = float(row[feature]) if len(row[feature]) > 0 else defaultValue
            j+=1
        i+=1
    return matrix
        
def extract_target_matrix(data, target, defaultValue=0):
    matrix = numpy.zeros((len(data),), dtype=numpy.float)
    i = 0
    for row in data:
        matrix[i] = float(row[target]) if target in row and len(row[target]) > 0 else defaultValue
        i+=1
    return matrix
    
def extract_all_targets_into_file(data, targets, fileNamePattern, prefix,  defaultValue=0):
    for target in targets:
        m = extract_target_matrix(data, target, defaultValue)
        numpy.save(fileNamePattern % (prefix, target), m)
    
def partitionDataByFeatureRange(data, feature, trainingStartRange, testingStartRange):
    training_set = []
    testing_set = []
    
    for row in data:
        if row[feature] >= trainingStartRange:
            if row[feature] < testingStartRange:
                training_set.append(row)
            else:
                testing_set.append(row)
                
    return training_set, testing_set
    
if __name__ == '__main__':
    """
    Call like python preprocess.py BAC
    """
    ticker = sys.argv[1]
    data_file = "%s_data.csv" % ticker
    training_set_prefix = "%s_training" % ticker
    testing_set_prefix = "%s_testing" % ticker
    
    data = parse.readCsvFile(data_file)
    training_set, testing_set = partitionDataByFeatureRange(data, "Year", "1993", "2014")
    
    training_feats = extract_feature_matrix(training_set, config.features)
    numpy.save("%s_features.npy" % training_set_prefix, training_feats)
    
    extract_all_targets_into_file(training_set, config.regression_targets, "%s_target_%s.npy", training_set_prefix)
    
    testing_feats = extract_feature_matrix(testing_set, config.features)
    numpy.save("%s_features.npy" % testing_set_prefix, testing_feats)
    
    extract_all_targets_into_file(testing_set, config.regression_targets, "%s_target_%s.npy", testing_set_prefix)

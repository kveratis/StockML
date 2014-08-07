import config
import numpy
import sys

def extractColumns(data, columns):
    return data[:,columns]
    
if __name__ == '__main__':
    """
    Call like python analyze.py IBM training Low > test.txt
    Call like python analyze.py VIX training Low IBM > test.txt  -- VIX features, IBM targets
    """
    ticker = sys.argv[1]
    dataset = sys.argv[2]
    target = sys.argv[3]
    target_ticker = sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] != '>' else ticker
    
    feature_file = "%s_%s_features.npy" % (ticker, dataset)
    target_file = "%s_%s_target_%s.npy" % (target_ticker, dataset, target)
    
    features = numpy.load(feature_file)
    targets = numpy.load(target_file)
         
    print "Feature, Coefficient, CoeffMagnitude"
    
    for i in range(len(config.features)):
        feature = features[:,i]
        coef = numpy.corrcoef(feature, targets)[0][1]
        print "%s, %f, %f" % (config.features[i], coef, (coef ** 2) ** 0.5)

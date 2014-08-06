import numpy
import sys

def extractColumns(data, columns):
    return data[:,columns]
    
if __name__ == '__main__':
    ticker = sys.argv[1]
    dataset = sys.argv[2]
    target = sys.argv[3]
    #columns = sys.argv[4].split(',')
    
    feature_file = "%s_%s_features.npy" % (ticker, dataset)
    target_file = "%s_%s_target_%s.npy" % (ticker, dataset, target)
    
    features = numpy.load(feature_file)
    targets = numpy.load(target_file)
         
    for i in range(numpy.shape(features)[1]):
        feature = features[:,i]
        coef = numpy.corrcoef(feature, targets)[0][1]
        print "%d, %f" % (i, coef)

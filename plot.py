import numpy as np
import matplotlib.pyplot as plt

def basicPlot():
    plt.plot([1, 2, 3, 4]) # If given one array, it assumes these are y-axes values and auto generates the x-axis (0 - 3)
    plt.ylabel('some numbers')
    plt.show()

def twoAxesPlot():
    plt.plot([1,2,3,4],[1,4,9,16], 'ro') #[x-axis values], [y-axis values], 'color/line type'
    plt.axis([0,6,0,20])    #[xmin, xmax, ymin, ymax]
    plt.show()

def multiLinePlot():
    # Plotting several lines with different format styles in one command
    # evenly sampled time at 200ms intervals
    t = np.arange(0., 5., 0.2)
    # red dashes, blue squares, and green triangles
    plt.plot(t, t, 'r--', t, t**2, 'bs', t, t**3, 'g^')
    plt.show()

def f(t):
    return np.exp(-t) * np.cos(2 * np.pi * t)
    
def multiSubPlot():
    t1 = np.arange(0.0, 5.0, 0.1)
    t2 = np.arange(0.0, 5.0, 0.02)
    
    plt.figure(1)
    plt.subplot(211)    # equivalent to subplot(2,1,1) [numRows, numCols, figNum]
    plt.plot(t1, f(t1), 'bo', t2, f(t2), 'k')
    
    plt.subplot(212)
    plt.plot(t2, np.cos(2 * np.pi * t2), 'r--')
    plt.show()
    
def textHistogram():
    mu, sigma = 100, 15
    x = mu + sigma * np.random.randn(10000)
    
    # the histogram of the data
    n, bins, patches = plt.hist(x, 50, normed=1, facecolor='g', alpha=0.75)
    
    plt.xlabel('Smarts')
    plt.ylabel('Probability')
    plt.title('Histogram of IQ')
    plt.text(60, 0.25, r'$\mu=100, \ \sigma=15$')
    plt.axis([40, 160, 0, 0.03])
    plt.grid(True)
    plt.show()
    
#basicPlot()
#twoAxesPlot()
#multiLinePlot()
#multiSubPlot()
#textHistogram()

def plotPredictionsVersusTarget(predictions, targets):
    t = range(len(targets))
    plt.plot(t, targets[::-1], 'r', t, predictions[::-1], 'b')
    plt.xlabel('Trading Days')
    plt.ylabel('Limit Price')
    plt.show()
    
if __name__ == '__main__':
    '''
        call like 
        python plot.py IBM 5DayWindowBestLongBuyPrice
        python plot.py GSPC 5DayWindowBestLongBuyPrice IBM
    '''
    
    ticker = sys.argv[1]
    target = sys.argv[2]
    target_ticker = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '>' else ticker
    
    predictions_file = config.GetPredictionsFileName(ticker, target, target_ticker)
    test_targets_file = config.GetTestingTargetsFileName(target_ticker, target)

    predictions = np.load(predictions_file)
    targets = np.load(test_targets_file)
    
    plotPredictionsVersusTarget(predictions, targets)

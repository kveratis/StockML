input length = 16;
input pipScale = 10000;

def localHigh = Highest(high, length);
def localLow = Lowest(low, length);
def diff = (localHigh - localLow) * pipScale;

plot d = 100 - diff;
plot plusLine = 70;
plusLine.setDefaultColor(color.green);
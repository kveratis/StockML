input length = 16;

def localHigh = Highest(high, length);
def localLow = Lowest(low, length);

plot lh = localHigh;
plot ll = localLow;
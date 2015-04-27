input length = 12;
input pipScale = 10000;
input tradeOffset = .0015;
input lotSize = 10000;
input baselineChannelQuality = 90;
input triggerCloseChannelQuality = 65;

def localHigh = Highest(high, length);
def localLow = Lowest(low, length);
def channelQuality = 100 - ((localHigh - localLow) * pipScale);
def triggerBuyClose = if channelQuality <= triggerCloseChannelQuality and channelQuality < channelQuality[1] then channelQuality else triggerCloseChannelQuality;
def triggerBuyPrice = 
if channelQuality >= baselineChannelQuality and channelQuality > channelQuality[1] then localHigh[1] + tradeOffset 
else if triggerBuyPrice > 0 and high crosses above triggerBuyPrice then 0
else MAX(0, triggerBuyPrice[1]);
def triggerBuyToOpen =  triggerBuyPrice > 0 and high crosses above triggerBuyPrice;
addOrder(OrderType.BUY_TO_OPEN, triggerBuyToOpen, triggerBuyPrice, lotSize);
addOrder(OrderType.SELL_TO_CLOSE, channelQuality <  triggerCloseChannelQuality and channelQuality >= triggerBuyClose[1]);

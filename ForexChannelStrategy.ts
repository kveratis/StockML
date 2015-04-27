input length = 16;
input pipScale = 10000;
input tradeOffset = .0015;
input lotSize = 10000;
input takeProfit = .0020;
input stopLoss = .0040;
input baselineChannelQuality = 85;
input triggerCloseChannelQuality = 40;

def localHigh = Highest(high, length);
def localLow = Lowest(low, length);
def channelQuality = 100 - ((localHigh - localLow) * pipScale);
def triggerBuyPrice = if channelQuality >= baselineChannelQuality and channelQuality > channelQuality[1] then localHigh[1] + tradeOffset else MAX(0, triggerBuyPrice[1]);
def triggerSellPrice = if channelQuality >= baselineChannelQuality and channelQuality > channelQuality[1] then localLow[1] - tradeOffset else MAX(0, triggerSellPrice[1]);
def triggerSellClose = if channelQuality <= triggerCloseChannelQuality and channelQuality < channelQuality[1] then channelQuality else triggerCloseChannelQuality;

addOrder(OrderType.BUY_TO_OPEN, triggerBuyPrice > 0 and high crosses above triggerBuyPrice, triggerBuyPrice, lotSize);
addOrder(OrderType.SELL_TO_OPEN, triggerSellPrice > 0 and low crosses below triggerSellPrice, triggerSellPrice, lotSize);
addOrder(OrderType.BUY_TO_CLOSE, channelQuality <  triggerCloseChannelQuality and channelQuality >= triggerSellClose[1]);

#triggerBuyPrice = If(channelQuality <  triggerCloseChannelQuality and channelQuality >= triggerSellClose[1], 0, triggerBuyPrice);

input length = 12;
input pipScale = 10000;
input tradeOffset = .0015;
input lotSize = 10000;
input baselineChannelQuality = 90;
input triggerCloseChannelQuality = 65;

def localHigh = Highest(high, length);
def localLow = Lowest(low, length);
def channelQuality = 100 - ((localHigh - localLow) * pipScale);
def triggerSellClose = if channelQuality <= triggerCloseChannelQuality and channelQuality < channelQuality[1] then channelQuality else triggerCloseChannelQuality;
def triggerSellPrice = 
if channelQuality >= baselineChannelQuality and channelQuality > channelQuality[1] then localLow[1] - tradeOffset 
else if channelQuality <  triggerCloseChannelQuality and channelQuality >= triggerSellClose[1] then 0
else MAX(0, triggerSellPrice[1]);
def triggerSaleToOpen =  triggerSellPrice > 0 and low crosses below triggerSellPrice;
addOrder(OrderType.SELL_TO_OPEN, triggerSaleToOpen, triggerSellPrice, lotSize);
addOrder(OrderType.BUY_TO_CLOSE, channelQuality <  triggerCloseChannelQuality and channelQuality >= triggerSellClose[1]);

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
def triggerBuyPrice = 
if channelQuality >= baselineChannelQuality and channelQuality > channelQuality[1] then localHigh[1] + tradeOffset 
else if triggerBuyPrice > 0 and high crosses above triggerBuyPrice then 0
else MAX(0, triggerBuyPrice[1]);
def triggerSellPrice = 
if channelQuality >= baselineChannelQuality and channelQuality > channelQuality[1] then localLow[1] - tradeOffset 
else if channelQuality <= triggerCloseChannelQuality and channelQuality < channelQuality[1] then 0
else MAX(0, triggerSellPrice[1]);
def triggerSellClose = if channelQuality <= triggerCloseChannelQuality and channelQuality < channelQuality[1] then channelQuality else triggerCloseChannelQuality;
def triggerBuy = triggerBuyPrice > 0 and high crosses above triggerBuyPrice;
def triggerSell = triggerSellPrice > 0 and low crosses below triggerSellPrice;
def direction = 
if triggerBuy then 1
else if triggerSell then 2
else 0;

Alert(triggerSell, "Sell to Open", Alert.BAR, Sound.Bell);
Alert(triggerSellClose, "Buy to Close", Alert.BAR, Sound.Ring);

plot a = localHigh;
plot b = localLow;
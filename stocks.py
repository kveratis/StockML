import math;
import sys
import config

def roundup(value, precision):
    rval = round(value, precision)
    if value > rval:
        rval = rval + .01
    return rval

def calcTotalCost(buyPrice, shares, costPerTrade = 6.95):
    return buyPrice * shares + costPerTrade
    
def calcNetRevenue(sellPrice, shares, costPerTrade = 6.95):
    return sellPrice * shares - costPerTrade

def calcNetProfitOnStock(buyPrice, sellPrice, shares, costPerTrade = 6.95):
    return (sellPrice - buyPrice) * shares - (2 * costPerTrade)
       
def calcMinimumNumberOfSharesToBreakEven(buyPrice, sellPrice, costPerTrade = 6.95):
    return math.ceil((2 * costPerTrade) / (sellPrice - buyPrice))
    
def calcMinimumShareSellPriceToBreakEven(buyPrice, shares, costPerTrade = 6.95):
    return roundup(((2 * costPerTrade) + (buyPrice * shares))/(shares), 2)
    
def calcMinimumInvestmentToRealizeGain(buyPrice, sellPrice, costPerTrade = 6.95):
    numShares = calcMinimumNumberOfSharesToBreakEven(buyPrice, sellPrice, costPerTrade)
    return (numShares * buyPrice + costPerTrade, numShares)
    
def calcMinimumInvestmentToRealizeProfit(buyPrice, sellPrice, profit, costPerTrade = 6.95):
    sharesForBreakEven = calcMinimumNumberOfSharesToBreakEven(buyPrice, sellPrice, costPerTrade)
    sharesForProfit = profit / (sellPrice - buyPrice)
    numShares = sharesForBreakEven + sharesForProfit
    return (numShares * buyPrice + costPerTrade, numShares)
           
def calcNumberOfSharesPurchasable(buyPrice, cash, costPerTrade = 6.95):
    return math.floor((cash - costPerTrade) / buyPrice)
    
if __name__ == '__main__':
    '''
        call like 
        python stocks.py [buyPrice] [sellPrice] [shares]           # Calculates profit for a given pair of trades
        python stocks.py [-p] [buyPrice] [sellPrice] [profit]      # Calculates number of shares to achieve target profit level from range 
        python stocks.py [-t] [buyPrice] [shares] [profit]         # Calculates target sell price to achieve break even and target profit level
        python stocks.py [-m] [buyPrice] [cashToInvest]            # Calculates the maximum number of shares you can purchase given the buyPrice and cash
    '''
    
    buyPrice = float(sys.argv[2])
    profit = float(sys.argv[4]) if len(sys.argv) > 4 else 0
    
    if sys.argv[1] == "-p":
        sellPrice = float(sys.argv[3])
        
        minimumInvestment, minimumShares = calcMinimumInvestmentToRealizeGain(buyPrice, sellPrice)
        print "Buy: %.2f Sell: %.2f Break Even Investment: %.2f Shares: %d Net Profit %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumShares, calcNetProfitOnStock(buyPrice, sellPrice, minimumShares))

        minimumInvestment, minimumShares = calcMinimumInvestmentToRealizeProfit(buyPrice, sellPrice, profit)
        print "Buy: %.2f Sell: %.2f Profit Target Investment: %.2f Shares: %d Profit: %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumShares, calcNetProfitOnStock(buyPrice, sellPrice, minimumShares))
        
    elif sys.argv[1] == "-t":
        shares = float(sys.argv[3])
        
        sellPrice = calcMinimumShareSellPriceToBreakEven(buyPrice, shares)
        print "Buy: %.2f Break Even Sell: %.2f Shares: %d Net Profit %.2f" % (buyPrice, sellPrice, shares, calcNetProfitOnStock(buyPrice, sellPrice, shares))
        
        minimumInvestment, minimumShares = calcMinimumInvestmentToRealizeProfit(buyPrice, sellPrice, profit)
        print "Buy: %.2f Sell: %.2f Profit Target Investment: %.2f Shares: %d Profit: %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumShares, calcNetProfitOnStock(buyPrice, sellPrice, minimumShares))
    elif sys.argv[1] == "-m":
        cash = float(sys.argv[3])
        shares = calcNumberOfSharesPurchasable(buyPrice, cash)
        totalCost = calcTotalCost(buyPrice, shares)
        
        print "You can buy %d Shares at %.2f for %.2f" % (shares, buyPrice, totalCost)
    else:
        buyPrice = float(sys.argv[1])
        sellPrice = float(sys.argv[2])
        shares = float(sys.argv[3])
        
        print "Buy: %.2f Sell: %.2f Shares: %d Net Profit %.2f" % (buyPrice, sellPrice, shares, calcNetProfitOnStock(buyPrice, sellPrice, shares))
    

import math;
import sys
import config

def calcTotalCost(buyPrice, shares, costPerTrade = 6.95):
    return buyPrice * shares + costPerTrade
    
def calcNetRevenue(sellPrice, shares, costPerTrade = 6.95):
    return sellPrice * shares - costPerTrade

def calcNetProfitOnStock(buyPrice, sellPrice, shares, costPerTrade = 6.95):
    return (sellPrice - buyPrice) * shares - (2 * costPerTrade)
       
def calcMinimumNumberOfSharesToBreakEven(buyPrice, sellPrice, costPerTrade = 6.95):
    return math.ceil((2 * costPerTrade) / (sellPrice - buyPrice))
    
def calcMinimumInvestmentToRealizeGain(buyPrice, sellPrice, costPerTrade = 6.95):
    numShares = calcMinimumNumberOfSharesToBreakEven(buyPrice, sellPrice, costPerTrade)
    return (numShares * buyPrice + costPerTrade, numShares)
    
def calcMinimumInvestmentToRealizeProfit(buyPrice, sellPrice, profit, costPerTrade = 6.95):
    sharesForBreakEven = calcMinimumNumberOfSharesToBreakEven(buyPrice, sellPrice, costPerTrade)
    sharesForProfit = profit / (sellPrice - buyPrice)
    numShares = sharesForBreakEven + sharesForProfit
    return (numShares * buyPrice + costPerTrade, numShares)
           
if __name__ == '__main__':
    '''
        call like 
        python stocks.py [buyPrice] [sellPrice] [profit]
    '''
    
    buyPrice = float(sys.argv[1])
    sellPrice = float(sys.argv[2])
    profit = float(sys.argv[3])
      
    minimumInvestment, minimumShares = calcMinimumInvestmentToRealizeGain(buyPrice, sellPrice)
    print "Buy: %.2f Sell: %.2f Break Even Investment: %.2f Shares: %d Net Profit %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumShares, calcNetProfitOnStock(buyPrice, sellPrice, minimumShares))
    
    minimumInvestment, minimumShares = calcMinimumInvestmentToRealizeProfit(buyPrice, sellPrice, profit)
    print "Buy: %.2f Sell: %.2f Profit Target Investment: %.2f Shares: %d Profit: %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumShares, calcNetProfitOnStock(buyPrice, sellPrice, minimumShares))

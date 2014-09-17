import math;
import sys
import config
    
def roundup(value, precision):
    rval = round(value, precision)
    if value > rval:
        rval = rval + .05
    return rval
    
def calcOptionTradeCost(contracts, costPerTrade = 6.95, costPerContract = 0.75):
    return costPerTrade + (contracts * costPerContract)

def calcTotalCost(buyPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    return buyPrice * contracts * 100 + calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    
def calcNetRevenue(sellPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    return sellPrice * contracts * 100 - calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    
def calcNetProfitOnOption(buyPrice, sellPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    tradeCost = calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    return (sellPrice - buyPrice) * contracts * 100 - (2 * tradeCost)
    
def calcMinimumNumberOfContractsToBreakEven(buyPrice, sellPrice, costPerTrade = 6.95, costPerContract = 0.75):
    return math.ceil((2 * costPerTrade) / (((sellPrice - buyPrice) * 100) - costPerContract))
    
def calcMinimumContractSellPriceToBreakEven(buyPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    tradeCost = calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    return roundup(((2 * tradeCost) + (buyPrice * contracts * 100))/(contracts * 100), 2)
    
def calcMinimumOptionInvestmentToRealizeGain(buyPrice, sellPrice, costPerTrade = 6.95, costPerContract = 0.75):
    contracts = calcMinimumNumberOfContractsToBreakEven(buyPrice, sellPrice, costPerTrade, costPerContract)
    return (calcTotalCost(buyPrice, contracts, costPerTrade, costPerContract), contracts)
    
def calcMinimumOptionInvestmentToRealizeProfit(buyPrice, sellPrice, profit, costPerTrade = 6.95, costPerContract = 0.75):
    contractsForBreakEven = calcMinimumNumberOfContractsToBreakEven(buyPrice, sellPrice, costPerTrade, costPerContract)
    contractsForProfit = math.ceil(profit / (((sellPrice - buyPrice) * 100) - costPerContract))
    contracts = math.ceil(contractsForBreakEven + contractsForProfit)
    return (calcTotalCost(buyPrice, contracts, costPerTrade, costPerContract), contracts)
        
if __name__ == '__main__':
    '''
        call like 
        python options.py [-p/-t] [buyPrice] [sellPrice] [profit]
            -p profit
            -t target sell price
    '''
    buyPrice = float(sys.argv[2])
    profit = float(sys.argv[4]) if len(sys.argv) > 4 else 0
    
    if sys.argv[1] == "-p":
        sellPrice = float(sys.argv[3])
                         
        minimumInvestment, minimumContracts = calcMinimumOptionInvestmentToRealizeGain(buyPrice, sellPrice)
        print "Buy: %.2f Sell: %.2f Break Even Investment: %.2f Contracts: %d Net Profit %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumContracts, calcNetProfitOnOption(buyPrice, sellPrice, minimumContracts))
        
        minimumInvestment, minimumContracts = calcMinimumOptionInvestmentToRealizeProfit(buyPrice, sellPrice, profit)
        print "Buy: %.2f Sell: %.2f Profit Target Investment: %.2f Contracts: %d Profit: %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumContracts, calcNetProfitOnOption(buyPrice, sellPrice, minimumContracts))
    elif sys.argv[1] == "-t":
        contracts = float(sys.argv[3])

        sellPrice = calcMinimumContractSellPriceToBreakEven(buyPrice, contracts)
        print "Buy: %.2f Break Even Sell: %.2f Contracts: %d Net Profit %.2f" % (buyPrice, sellPrice, contracts, calcNetProfitOnOption(buyPrice, sellPrice, contracts))
        
        minimumInvestment, minimumContracts = calcMinimumOptionInvestmentToRealizeProfit(buyPrice, sellPrice, profit)
        print "Buy: %.2f Sell: %.2f Profit Target Investment: %.2f Contracts: %d Profit: %.2f" % (buyPrice, sellPrice, minimumInvestment, minimumContracts, calcNetProfitOnOption(buyPrice, sellPrice, minimumContracts))
    else:
        buyPrice = float(sys.argv[1])
        sellPrice = float(sys.argv[2])
        contracts = float(sys.argv[3])
        
        print "Buy: %.2f Sell: %.2f Contracts: %d Net Profit %.2f" % (buyPrice, sellPrice, contracts, calcNetProfitOnOption(buyPrice, sellPrice, contracts))

import math;
import sys
import config
    
def roundup(value, precision):
    rval = round(value, precision)
    tip = 1 / math.pow(10, precision)
    if value > rval:
        rval = rval + tip
    return rval
    
def calcOptionTradeCost(contracts, costPerTrade = 6.95, costPerContract = 0.75):
    return costPerTrade + (contracts * costPerContract)
    
def optionPrice(price, contracts = 1):
    return price * 100 * contracts
    
def calcCostPerOptionContract(buyPrice, costPerContract = 0.75):
    return optionPrice(buyPrice) + costPerContract
    
def contributionMarginPerOptionContract(buyPrice, sellPrice, costPerContract = 0.75):
    return optionPrice((sellPrice - buyPrice)) - costPerContract

def calcTotalCost(buyPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    return optionPrice(buyPrice, contracts) + calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    
def calcNetRevenue(sellPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    return optionPrice(sellPrice, contracts) - calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    
def calcNetProfitOnOption(buyPrice, sellPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    totalTradeCost = 2 * calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    grossProfit = optionPrice((sellPrice - buyPrice), contracts)
    return roundup(grossProfit - totalTradeCost, 2)
    
def optionContractVolumeToRealizeProfit(buyPrice, sellPrice, profit = 0.0, costPerTrade = 6.95, costPerContract = 0.75):
    return math.ceil((2 * costPerTrade + profit)/(contributionMarginPerOptionContract(buyPrice, sellPrice, costPerContract) - costPerContract))
    
def calcMinimumNumberOfContractsToBreakEven(buyPrice, sellPrice, costPerTrade = 6.95, costPerContract = 0.75):
    return math.ceil(2 * costPerTrade/(contributionMarginPerOptionContract(buyPrice, sellPrice, costPerContract) - costPerContract))
    
def calcMinimumContractSellPriceToBreakEven(buyPrice, contracts, costPerTrade = 6.95, costPerContract = 0.75):
    totalTradeCost = 2 * calcOptionTradeCost(contracts, costPerTrade, costPerContract)
    return roundup((totalTradeCost + optionPrice(buyPrice, contracts))/(contracts * 100), 2)
    
def calcMinimumOptionInvestmentToRealizeGain(buyPrice, sellPrice, costPerTrade = 6.95, costPerContract = 0.75):
    contracts = calcMinimumNumberOfContractsToBreakEven(buyPrice, sellPrice, costPerTrade, costPerContract)
    totalCost = calcTotalCost(buyPrice, contracts, costPerTrade, costPerContract)
    return (totalCost, contracts)
    
def calcMinimumOptionInvestmentToRealizeProfit(buyPrice, sellPrice, profit, costPerTrade = 6.95, costPerContract = 0.75):
    contracts = optionContractVolumeToRealizeProfit(buyPrice, sellPrice, profit, costPerTrade, costPerContract)
    totalCost = calcTotalCost(buyPrice, contracts, costPerTrade, costPerContract)
    return (totalCost, contracts)
    
def calcNumberOfOptionsPurchasable(buyPrice, cash, costPerTrade = 6.95, costPerContract = 0.75):
    itemCost = calcCostPerOptionContract(buyPrice, costPerContract)
    availableAssets = cash - costPerTrade;
    return math.floor(availableAssets / itemCost)
        
if __name__ == '__main__':
    '''
        call like 
        python options.py [buyPrice] [sellPrice] [contracts]        # Calculates profit from trade info
        python options.py [-p] [buyPrice] [sellPrice] [profit]      # Calculates number of contracts to achieve target profit level from range 
        python options.py [-t] [buyPrice] [contracts] [profit]      # Calculates target sell price to achieve break even and target profit level
        python options.py [-m] [buyPrice] [cashToInvest]            # Calculates the maximum number of contracts you can purchase given the buyPrice and cash        
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
    elif sys.argv[1] == "-m":
        cash = float(sys.argv[3])
        contracts = calcNumberOfOptionsPurchasable(buyPrice, cash)
        totalCost = calcTotalCost(buyPrice, contracts)
        
        print "You can buy %d Contracts at %.2f for %.2f" % (contracts, buyPrice, totalCost)
    else:
        buyPrice = float(sys.argv[1])
        sellPrice = float(sys.argv[2])
        contracts = float(sys.argv[3])
        
        print "Buy: %.2f Sell: %.2f Contracts: %d Net Profit %.2f" % (buyPrice, sellPrice, contracts, calcNetProfitOnOption(buyPrice, sellPrice, contracts))

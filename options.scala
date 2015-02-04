def round(value: Double, precision: Int): Double = {
    if(precision < 0) 0
    else {
        val factor = Math.pow(10, precision)
        val rval =  Math.round(value * factor) / factor
        val tip = 1 / factor
        if(rval < value) return rval + tip
        else return rval
    }
}

def optionTradeCost(contracts: Int, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Double = {
    return costPerTrade + (contracts * costPerContract)
}

def optionTradePrice(price: Double, contracts: Int = 1): Double = {
    return price * 100 * contracts;
}

def costPerOptionContract(buyPrice: Double, costPerContract: Double = 0.75): Double = {
    return optionTradePrice(buyPrice) + costPerContract
}

def contributionMarginPerOptionContract(buyPrice: Double, sellPrice: Double, costPerContract: Double = 0.75): Double = {
    return optionTradePrice((sellPrice - buyPrice)) - costPerContract
}

def totalOptionTradeCost(buyPrice: Double, contracts: Int, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Double = {
    return optionTradePrice(buyPrice, contracts) + optionTradeCost(contracts, costPerTrade, costPerContract)
}

def netOptionTradeRevenue(sellPrice: Double, contracts: Int, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Double = {
    return optionTradePrice(sellPrice, contracts) - optionTradeCost(contracts, costPerTrade, costPerContract)
}

def netOptionTradeProfit(buyPrice: Double, sellPrice: Double, contracts: Int, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Double = {
    val totalTradeCost = 2 * optionTradeCost(contracts, costPerTrade, costPerContract)
    val grossProfit = optionTradePrice((sellPrice - buyPrice), contracts)
    return round(grossProfit - totalTradeCost,2)
}

def breakEvenOptionSellPrice(buyPrice: Double, contracts: Int, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Double = {
    val totalTradeCost = 2 * optionTradeCost(contracts, costPerTrade, costPerContract)
    return round((totalTradeCost + optionTradePrice(buyPrice, contracts))/(contracts * 100), 2)
}

def optionContractVolumeToRealizeProfit(buyPrice: Double, sellPrice: Double, profit:Double = 0.0, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Int = {
    return Math.ceil((2 * costPerTrade + profit)/(contributionMarginPerOptionContract(buyPrice, sellPrice, costPerContract) - costPerContract)).toInt
}

def breakEvenOptionContractVolume(buyPrice: Double, sellPrice: Double, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Int = {
    return Math.ceil(2 * costPerTrade/(contributionMarginPerOptionContract(buyPrice, sellPrice, costPerContract) - costPerContract)).toInt
}

def maxOptionContractsPurchasable(buyPrice: Double, cash: Double, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Int = {
    val itemCost = costPerOptionContract(buyPrice, costPerContract)
    val availableAssets = cash - costPerTrade;
    return Math.floor(availableAssets / itemCost).toInt
}

def minInvestmentToRealizeGainOnOptionTrade(buyPrice: Double, sellPrice: Double, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Tuple2[Double, Int] = {
    val contracts = breakEvenOptionContractVolume(buyPrice, sellPrice, costPerTrade, costPerContract)
    val totalCost = totalOptionTradeCost(buyPrice, contracts, costPerTrade, costPerContract)
    return new Tuple2[Double, Int](totalCost, contracts)
}

def minInvestmentToRealizeProfitOnOptionTrade(buyPrice: Double, sellPrice: Double, profit: Double, costPerTrade: Double = 6.95, costPerContract: Double = 0.75): Tuple2[Double, Int] = {
    val contracts = optionContractVolumeToRealizeProfit(buyPrice, sellPrice, profit, costPerTrade, costPerContract)
    val totalCost = totalOptionTradeCost(buyPrice, contracts, costPerTrade, costPerContract)
    return new Tuple2[Double, Int](totalCost, contracts)
}

println(optionTradeCost(1))
println(optionTradePrice(.50))
println(costPerOptionContract(.50))
println(totalOptionTradeCost(.50, 1))
println(netOptionTradeRevenue(.50,1))
println(netOptionTradeProfit(.20, .50, 1))
println(breakEvenOptionSellPrice(.20, 1))
println(netOptionTradeProfit(.20, .36, 1))
println(breakEvenOptionContractVolume(.20, .36))
println(breakEvenOptionContractVolume(.20, .35))
println(netOptionTradeProfit(.20, .35, 2))
println(maxOptionContractsPurchasable(.20, 100))
println(minInvestmentToRealizeGainOnOptionTrade(.20, .35))
println(minInvestmentToRealizeProfitOnOptionTrade(.20, .35, 20.0))
println(netOptionTradeProfit(.20, .35, 3))

import csv
import sys
import numpy
import operator
from datetime import datetime, date, time
        
def readCsvFile(filename):
    li = []
    try:
        f = open(filename, 'rb')
        try:
            reader = csv.DictReader(f)
            for row in reader:
                li.append(row)
        finally:
            f.close()
    except IOError:
        pass
    return li
    
def writeCsvFile(filename, items, fields):
    try:
        f = open(filename, 'wb')
        try:
            writer = csv.DictWriter(f, fields, extrasaction='ignore')
            writer.writeheader()
            writer.writerows(items)
        finally:
            f.close()
    except IOError:
        pass
        
def insert(list, index, newItems):
    for i in range(len(newItems)):
        list.insert(index+1, newItems[i])
        
def calcDateInfo(quotes):
    newFields = ["Year", "Month", "Week", "DayOfWeek"]
    for row in quotes:
        d = datetime.strptime(row["Date"], "%Y-%m-%d")
        row["Year"] = "%d" % d.year
        row["Month"] = "%d" % d.month
        row["Week"] = "%d" % d.isocalendar()[1]     # ISO Week
        row["DayOfWeek"] = "%d" % d.isoweekday()    # ISO Week Day where Monday = 1
    return newFields
    
def calcRange(quotes):
    newKey = "Range"
    for row in quotes:
        high = float(row["High"])
        low = float(row["Low"])
        range = high - low;
        row[newKey] = "%.2f" % range
    return newKey
    
def calcChange(quotes):
    newFields = ["DailyChange", "DailyRangeRatio"]
    for row in quotes:
        open = float(row["Open"])
        close = float(row["Close"])
        change = close - open
        ratio = change / open
        row["DailyChange"] = "%.2f" % change
        row["DailyRangeRatio"] = "%.4f" % ratio
    return newFields
        
def extractFieldFromListOfDictionariesIntoList(items, fieldName):
    data = []
    for row in items:
        if fieldName in row.keys():
            data.append(float(row[fieldName]))
    return data
    
def calculateMovingAverage(items, windowSize):
    window = numpy.ones(int(windowSize))/float(windowSize)
    ma = numpy.convolve(numpy.array(items), window, 'valid')    # will have a length of windowSize less than the data
    return ma
    
def calculateDelayedStream(items, delay):
    data = items[delay:]
    return numpy.array(data)   
    
def addFieldToList(items, newData, fieldName):
    for i in range(newData.size):
        items[i][fieldName] = "%.2f" % newData[i]
    if newData.size < len(items): # back fill with zeros
        for j in range(newData.size, len(items)):
            items[i][fieldName] = "0.00"
          
def calculateMovingAveragesOfFields(quotes, fieldNames, averages):
    newFields = []
    for field in fieldNames:
        data = extractFieldFromListOfDictionariesIntoList(quotes, field)
        for numDays in averages:
            key = "%ddMA_%s" % (numDays, field)
            newFields.append(key)
            ma = calculateMovingAverage(data, numDays)
            addFieldToList(quotes, ma, key)
    return newFields
    
def calculateDaysDelayedStream(quotes, fieldNames, daysDelayed):
    newFields = []
    for field in fieldNames:
        data = extractFieldFromListOfDictionariesIntoList(quotes, field)
        for delay in daysDelayed:
            key = "%s_D%d" % (field, delay)
            newFields.append(key)
            delayedList = calculateDelayedStream(data, delay)
            addFieldToList(quotes, delayedList, key)
    return newFields
    
def findLowestTradeInList(items):
    lowest = min(items)
    low_idx = items.index(lowest)
    return (lowest, low_idx)
    
def findHighestTradeInList(items):
    highest = max(items)
    high_idx = items.index(highest)
    return (highest, high_idx)
    
def findBestLongTrade(buyList, sellList):
    buyTrade = findLowestTradeInList(buyList)
    sellTrade = findHighestTradeInList(sellList)
    
    if buyTrade[1] < sellTrade[1]:  # buy low, sell high
        return (buyTrade[0], sellTrade[0], sellTrade[0] - buyTrade[0])  #buy price, sell price, range
    elif buyTrade[1] == 0 or sellTrade[1] == len(sellList) - 1:
        return (0.00, 0.00, 0.00)
    else:
        trade1 = findBestLongTrade(buyList[:sellTrade[1]+1], sellList[:sellTrade[1]+1]) # find the second best buy price
        trade2 = findBestLongTrade(buyList[buyTrade[1]:], sellList[buyTrade[1]:])       # find the second best sell price
        if trade1[2] > trade2[2]:    # find best range
            return trade1
        else:
            return trade2
            
def findBestShortTrade(buyList, sellList):
    buyTrade = findLowestTradeInList(buyList)
    sellTrade = findHighestTradeInList(sellList)
    
    if sellTrade[1] < buyTrade[1]:  # sell high, buy low
        return (buyTrade[0], sellTrade[0], sellTrade[0] - buyTrade[0])  #buy price, sell price, range
    elif sellTrade[1] == 0 or buyTrade[1] == len(buyList) - 1:
        return (0.00, 0.00, 0.00)
    else:
        trade1 = findBestShortTrade(buyList[:buyTrade[1]+1], sellList[:buyTrade[1]+1])    # find the second best sell price
        trade2 = findBestShortTrade(buyList[sellTrade[1]:], sellList[sellTrade[1]:])      # find the second best buy price
        if trade1[2] > trade2[2]:    # find best range
            return trade1
        else:
            return trade2
    
def calculateBestTradeInWindow(quotes, tradeWindow):
    newFields = []
    high = extractFieldFromListOfDictionariesIntoList(quotes, "High")[::-1] # extract list in sequential order
    low = extractFieldFromListOfDictionariesIntoList(quotes, "Low")[::-1]
    for windowSize in tradeWindow:
        index = range(len(high) - windowSize)
        keyBestLongBuyPrice = "%sDayWindowBestLongBuyPrice" % windowSize
        keyBestLongSellPrice = "%sDayWindowBestLongSellPrice" % windowSize
        keyBestLongRange = "%sDayWindowBestLongRange" % windowSize
        keyBestShortBuyPrice = "%sDayWindowBestShortBuyPrice" % windowSize
        keyBestShortSellPrice = "%sDayWindowBestShortSellPrice" % windowSize
        keyBestShortRange = "%sDayWindowBestShortRange" % windowSize
        keyBestStrategy = "%sDayWindowBestStrategy" % windowSize
        newFields.extend([keyBestLongBuyPrice, keyBestLongSellPrice, keyBestLongRange, keyBestShortBuyPrice, keyBestShortSellPrice, keyBestShortRange, keyBestStrategy])
        for i in index:
            bestLongTrade = findBestLongTrade(low[i:i + windowSize], high[i:i + windowSize])
            bestShortTrade = findBestShortTrade(low[i:i + windowSize], high[i:i + windowSize])
            quotes[i][keyBestLongBuyPrice] = "%.2f" % bestLongTrade[0]
            quotes[i][keyBestLongSellPrice] = "%.2f" % bestLongTrade[1]
            quotes[i][keyBestLongRange] = "%.2f" % bestLongTrade[2]
            quotes[i][keyBestShortBuyPrice] = "%.2f" % bestLongTrade[0]
            quotes[i][keyBestShortSellPrice] = "%.2f" % bestLongTrade[1]
            quotes[i][keyBestShortRange] = "%.2f" % bestLongTrade[2]
            if bestLongTrade[2] > bestShortTrade[2]: # Short or Whichever option has the most profit potential
                quotes[i][keyBestStrategy] = "Long"
            elif bestLongTrade[2] < bestShortTrade[2]:
                quotes[i][keyBestStrategy] = "Short"
            else:
                quotes[i][keyBestStrategy] = "Hold"
    return newFields

def calculateNewFields(quotes, fields, calcTradeWindow=False):
    insert(fields, 1, calcDateInfo(quotes))
    #fields.extend(calcDateInfo(quotes))
    fields.append(calcRange(quotes))
    fields.extend(calcChange(quotes))
    fields.extend(calculateMovingAveragesOfFields(quotes, fields[6:], movingAgerage))
    fields.extend(calculateDaysDelayedStream(quotes, fields[6:], daysDelayed))

    if calcTradeWindow == True:
        fields.extend(calculateBestTradeInWindow(quotes, tradeWindow))
            
if __name__ == '__main__':
    """
    call like python parse.py BAC trade or python parse.py VIX
    """
    ticker = sys.argv[1]
    trade = (len(sys.argv) > 2 and sys.argv[2] == "trade")
    source_file = "%s.csv" % ticker
    data_file = "%s_data.csv" % ticker
    fields = ["Date", "Adj Close", "Open", "High", "Low", "Close", "Volume"]
    movingAgerage = [5, 10, 15, 50, 200]
    daysDelayed = range(1, 21)  #1 to 20 day delay
    tradeWindow = [5, 10, 15, 20]
    
    print "parsing file..." 
    quotes = readCsvFile(source_file)
    
    print "running calculations..."
    calculateNewFields(quotes, fields, trade)
    
    print "writing data file..."
    writeCsvFile(data_file, quotes, fields)
    

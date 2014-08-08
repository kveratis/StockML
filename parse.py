import config
import csv
import sys
import numpy
import operator
from datetime import datetime, date, time
from operator import itemgetter
        
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
        row[newKey] = "%f" % range
    return newKey
    
def calcChange(quotes):
    newFields = ["DailyChange", "DailyRangeRatio"]
    for row in quotes:
        open = float(row["Open"])
        close = float(row["Close"])
        change = close - open
        ratio = change / open
        row["DailyChange"] = "%f" % change
        row["DailyRangeRatio"] = "%f" % ratio
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
        items[i][fieldName] = "%f" % newData[i]
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
                  
def calculateBestTradeInWindow(quotes, tradeWindow):
    newFields = []
    high = extractFieldFromListOfDictionariesIntoList(quotes, "High")[::-1] # extract list in sequential order
    low = extractFieldFromListOfDictionariesIntoList(quotes, "Low")[::-1]
    for windowSize in tradeWindow:
        idx_len = len(high)
        index = range(idx_len)
        upperBound = idx_len - 1
        keyBestLongBuyPrice = "%sDayWindowBestLongBuyPrice" % windowSize
        keyBestLongSellPrice = "%sDayWindowBestLongSellPrice" % windowSize
        keyBestLongRange = "%sDayWindowBestLongRange" % windowSize
        keyBestShortBuyPrice = "%sDayWindowBestShortBuyPrice" % windowSize
        keyBestShortSellPrice = "%sDayWindowBestShortSellPrice" % windowSize
        keyBestShortRange = "%sDayWindowBestShortRange" % windowSize
        keyBestStrategy = "%sDayWindowBestStrategy" % windowSize
        newFields.extend([keyBestLongBuyPrice, keyBestLongSellPrice, keyBestLongRange, keyBestShortBuyPrice, keyBestShortSellPrice, keyBestShortRange, keyBestStrategy])
        for i in index:
            j = upperBound - i # reverse index
            upperBoundOfWindow = i + windowSize if (i + windowSize) <= idx_len else idx_len
            buyList = low[i:upperBoundOfWindow]
            sellList = high[i:upperBoundOfWindow]
            allPossibleTrades = [(a, b, buyList[a], sellList[b], sellList[b] - buyList[a]) for a in range(len(buyList)) for b in range(len(sellList)) if a != b]
            bestLongTrades = sorted([(allPossibleTrades[x][0], allPossibleTrades[x][1], allPossibleTrades[x][2], allPossibleTrades[x][3], allPossibleTrades[x][4]) for x in range(len(allPossibleTrades)) if allPossibleTrades[x][0] < allPossibleTrades[x][1]], key=itemgetter(4), reverse = True)
            bestShortTrades = sorted([(allPossibleTrades[y][0], allPossibleTrades[y][1], allPossibleTrades[y][2], allPossibleTrades[y][3], -1 * allPossibleTrades[y][4]) for y in range(len(allPossibleTrades)) if allPossibleTrades[y][1] < allPossibleTrades[y][0]], key=itemgetter(4), reverse = True)
            quotes[j][keyBestLongBuyPrice] = "%f" % bestLongTrades[0][2] if j > 0 else quotes[j]["Low"]
            quotes[j][keyBestLongSellPrice] = "%f" % bestLongTrades[0][3] if j > 0 else quotes[j]["High"]
            longRange = bestLongTrades[0][3] if j > 0 else float(quotes[j]["Range"])
            quotes[j][keyBestLongRange] = "%f" % longRange
            quotes[j][keyBestShortBuyPrice] = "%f" % bestShortTrades[0][2] if j > 0 else quotes[j]["Low"]
            quotes[j][keyBestShortSellPrice] = "%f" % bestShortTrades[0][3] if j > 0 else quotes[j]["High"]
            shortRange = bestShortTrades[0][3] if j > 0 else float(quotes[j]["Range"])
            quotes[j][keyBestShortRange] = "%f" % shortRange

            if longRange > shortRange: # Short or Whichever option has the most profit potential
                quotes[j][keyBestStrategy] = "Long"
            elif longRange < shortRange:
                quotes[j][keyBestStrategy] = "Short"
            else:
                quotes[j][keyBestStrategy] = "Hold"
    return newFields
    
def calculateNewFields(quotes, fields, calcTradeWindow=False):
    insert(fields, 0, calcDateInfo(quotes))
    fields.append(calcRange(quotes))

    if calcTradeWindow == True:
        fields.extend(calculateBestTradeInWindow(quotes, config.tradeWindow))
            
if __name__ == '__main__':
    """
    call like python parse.py BAC trade or python parse.py VIX
    """
    ticker = sys.argv[1]
    trade = (len(sys.argv) > 2 and sys.argv[2] == "trade")
    source_file = "%s.csv" % ticker
    data_file = "%s_data.csv" % ticker
    
    print "parsing file..." 
    quotes = readCsvFile(source_file)
    
    print "running calculations..."
    calculateNewFields(quotes, config.fields, trade)
    
    print "writing data file..."
    writeCsvFile(data_file, quotes, config.fields)
    

import csv
import sys
import numpy
import operator

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
            writer = csv.DictWriter(f, fields)
            writer.writeheader()
            writer.writerows(items)
        finally:
            f.close()
    except IOError:
        pass
    
def calcRange(quotes):
    newKey = "Range"
    for row in quotes:
        high = float(row["High"])
        low = float(row["Low"])
        range = high - low;
        row[newKey] = "%.2f" % range
    return newKey
        
def extractFieldFromListOfDictionariesIntoList(items, fieldName):
    data = []
    for row in items:
        data.append(float(row[fieldName]))
    return data
    
def calculateMovingAverage(items, windowSize):
    window = numpy.ones(int(windowSize))/float(windowSize)
    return numpy.convolve(numpy.array(items), window, 'valid')    # will have a length of windowSize less than the data
    
def addFieldToList(items, newData, fieldName):
    for i in range(newData.size):
        items[i][fieldName] = "%.2f" % newData[i]
          
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
            
quotes = readCsvFile(sys.argv[1])
fields = ["Date", "Adj Close", "Open", "High", "Low", "Close", "Volume"]
movingAgerage = [5, 10, 15, 50, 200]
fields.append(calcRange(quotes))
fields.extend(calculateMovingAveragesOfFields(quotes, fields[2:], movingAgerage))
writeCsvFile('test.csv', quotes, fields)

import numpy
import sys
import config
import parse
from datetime import datetime, date, time

def extractSqlImportRecords(quotes, fields, ticker):
    sqlExport = [];
    for i in range(len(quotes)):
        d = datetime.strptime(quotes[i]["Date"], "%Y-%m-%d")
        datekey = int("%d%d%d" % (d.year, d.month, d.day))
        for key in fields[1:]:
            txt = quotes[i][key];
            if txt != None and txt != "":
                val = float(txt);
                sqlExport.append({"datekey": datekey, "ticker": ticker, "feature": key, "feature_text": txt, "feature_value": val})
    return sqlExport
    
def importRecordsToSqlStaging(records):
    connectionString = 'DRIVER={SQL Server};SERVER=%s;Trusted_Connection=yes' % server
    cnxn = pyodbc.connect(connectionString)
    cursor = cnxn.cursor()
    
    for rec in records:
        qry = "INSERT INTO Stock..stg_raw_data (datekey, ticker, feature, feature_text, feature_value) VALUES (%d, '%s', '%s', '%s', %f)" % (rec["datekey"], rec["ticker"], rec["feature"], rec["feature_text"], rec["feature_value"])
        cursor.execute(sqlQuery)
    
if __name__ == '__main__':
    """
    Call like 
    python extract.py BAC
    """
    ticker = sys.argv[1]
    
    data_file = config.GetDataFileName(ticker)
    fields_file = config.GetFieldsFileName(ticker)
    
    print "Loading data..."
    data = parse.readCsvFile(data_file)
    fields = numpy.load(fields_file)
    
    print "extracting sql data..."
    records = extractSqlImportRecords(data, fields, ticker)
    
    print "importing data to sql..."
    #importRecordsToSqlStaging(records)
    parse.writeCsvFile("%s_sql_import.csv" % ticker, records, config.sqlFields)
    

USE [Stock]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_extract_stock_data_points]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[stp_extract_stock_data_points]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stp_extract_stock_data_points
AS
BEGIN
	SET NOCOUNT ON;

	EXEC stp_extract_tickers

	EXEC stp_extract_features

    -- Insert statements for procedure here
	INSERT INTO Stock..FactStockDataPoints (datekey, ticker_id, feature_type_id, feature_value)
	SELECT datekey
		,dt.ticker_id
		,df.feature_type_id
		,CONVERT(decimal(18,2), stg.feature_value) as feature_value
	FROM Stock..stg_raw_data stg
		INNER JOIN Stock..DimTicker dt ON stg.ticker = dt.symbol
		INNER JOIN Stock..DimFeature df ON stg.feature = df.name
	ORDER BY datekey, df.feature_type_id, dt.ticker_id

	TRUNCATE TABLE Stock..stg_raw_data
END
GO

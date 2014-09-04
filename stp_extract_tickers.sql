USE [Stock]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_extract_tickers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[stp_extract_tickers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stp_extract_tickers
AS
BEGIN
	SET NOCOUNT ON;

    ;WITH MissingSymbols AS
	(
		SELECT DISTINCT ticker as symbol
		FROM Stock..stg_raw_data
		EXCEPT
		SELECT symbol
		FROM Stock..DimTicker
	)
	INSERT INTO Stock..DimTicker(symbol)
	SELECT symbol
	FROM MissingSymbols
END
GO

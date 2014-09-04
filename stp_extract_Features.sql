IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_extract_features]') AND type in (N'P', N'PC'))
USE [Stock]
GO
DROP PROCEDURE [dbo].[stp_extract_features]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stp_extract_features
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cnt int;
	SELECT @cnt = COUNT(*) FROM Stock..DimFeature;

	if(@cnt = 0)
	BEGIN
		-- Insert statements for procedure here
		INSERT INTO Stock..DimFeature(name)
		SELECT feature as name
		FROM Stock..stg_raw_data
		GROUP BY feature
		ORDER BY MIN(id)
	END
END
GO

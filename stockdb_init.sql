USE [master]
GO

/****** Object:  Database [Stock]    Script Date: 8/21/2014 10:13:52 AM ******/
CREATE DATABASE [Stock]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Stock', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\Stock.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Stock_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\Stock_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [Stock] SET COMPATIBILITY_LEVEL = 110
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Stock].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Stock] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Stock] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [Stock] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Stock] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Stock] SET ARITHABORT OFF 
GO

ALTER DATABASE [Stock] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Stock] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [Stock] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Stock] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Stock] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Stock] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Stock] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Stock] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Stock] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [Stock] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Stock] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Stock] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Stock] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Stock] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Stock] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Stock] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Stock] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Stock] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Stock] SET RECOVERY FULL 
GO

ALTER DATABASE [Stock] SET  MULTI_USER 
GO

ALTER DATABASE [Stock] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Stock] SET DB_CHAINING OFF 
GO

ALTER DATABASE [Stock] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [Stock] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [Stock] SET  READ_WRITE 
GO

USE [Stock]
GO

/****** Object:  Table [dbo].[Ticker]    Script Date: 8/21/2014 10:12:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DimTicker](
	[ticker_id] [int] IDENTITY(1,1) NOT NULL,
	[symbol] [varchar](10) NOT NULL,
	[name] [varchar](50) NULL,
	[start_dt] [date] NULL,
	[earliest_whole_year] [int] NULL,
	[is_tradable] [bit] NOT NULL,
 CONSTRAINT [PK_Ticker] PRIMARY KEY CLUSTERED 
(
	[ticker_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DimTicker] ADD  CONSTRAINT [DF_Ticker_isTradable]  DEFAULT ((1)) FOR [is_tradable]
GO

CREATE NONCLUSTERED INDEX [IX_DimTicker_Symbol] ON [dbo].[DimTicker] ([symbol])
GO

CREATE TABLE [dbo].[DimFeature](
	[feature_type_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](500) NULL,
	[is_valid_for_prediction] [bit] NOT NULL,
	[is_calculated] [bit] NOT NULL,
	[is_boolean] [bit] NOT NULL,
	[is_categorical] [bit] NOT NULL,
	[is_numeric] [bit] NOT NULL,
    [is_delayed] [bit] NOT NULL,
 CONSTRAINT [PK_Features] PRIMARY KEY CLUSTERED 
(
	[feature_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[DimFeature] ADD  CONSTRAINT [DF_Features_is_valid_for_prediction]  DEFAULT ((0)) FOR [is_valid_for_prediction]
GO

ALTER TABLE [dbo].[DimFeature] ADD  CONSTRAINT [DF_Features_is_calculated]  DEFAULT ((0)) FOR [is_calculated]
GO

ALTER TABLE [dbo].[DimFeature] ADD  CONSTRAINT [DF_Features_is_boolean]  DEFAULT ((0)) FOR [is_boolean]
GO

ALTER TABLE [dbo].[DimFeature] ADD  CONSTRAINT [DF_Features_is_categorical]  DEFAULT ((0)) FOR [is_categorical]
GO

ALTER TABLE [dbo].[DimFeature] ADD  CONSTRAINT [DF_Features_is_numeric]  DEFAULT ((1)) FOR [is_numeric]
GO

ALTER TABLE [dbo].[DimFeature] ADD  CONSTRAINT [DF_Features_is_delayed]  DEFAULT ((0)) FOR [is_delayed]
GO

CREATE NONCLUSTERED INDEX [IX_DimFeature_Name] ON [dbo].[DimFeature] ([name])
GO

CREATE TABLE [dbo].[DimDate] (
	[DateKey] [int] NOT NULL PRIMARY KEY,
	[FullDate] [date] NOT NULL,
	[Year] [smallint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[MonthOfYear] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[DayOfMonth] [tinyint] NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[DayName] [varchar](10) NOT NULL,
	[IsTradingDay] bit NOT NULL DEFAULT 0,
	[IsOptionExpirationDay] bit NOT NULL DEFAULT 1,
) ON [PRIMARY]
GO

-- Fill DimDate
DECLARE @startDate as datetime,@endDate as datetime;
SET @startDate = '1990-01-01T00:00:00';
SET @endDate = '2020-01-01T00:00:00';
 
while @startDate<@endDate
begin
  INSERT INTO DimDate([DateKey]
		,[FullDate]
		,[Year]
		,[Quarter]
		,[MonthOfYear]
		,[MonthName]
		,[WeekOfYear]
		,[DayOfMonth]
		,[DayOfWeek]
		,[DayName]
		,[IsTradingDay]
		,[IsOptionExpirationDay])
	SELECT CAST(CONVERT(char(8), @startDate, 112) AS INT) as DateKey
		,@startDate
		,DATEPART(year, @startDate) as Year
		,DATEPART(quarter, @startDate) as Quarter
		,DATEPART(month, @startDate) as MonthOfYear
		,DATENAME(month, @startDate) as MonthName
		,DATEPART(week, @startDate) as WeekOfYear
		,DATEPART(day, @startDate) as DayOfMonth
		,DATEPART(weekday, @startDate) as DayOfWeek
		,DATENAME(weekday, @startDate) as DayName
		,(CASE WHEN DATEPART(weekday, @startDate) = 1 OR DATEPART(weekday, @startDate) = 7 THEN 0 ELSE 1 END) as IsWorkDay
		,0
	SET @startDate = DATEADD(day, 1, @startDate);
end
GO

CREATE INDEX IDX_DimDate_FullDate ON DimDate(FullDate) INCLUDE (IsTradingDay, IsOptionExpirationDay);
CREATE INDEX IDX_DimDate_Calendar ON DimDate(Year, Quarter, MonthOfYear) INCLUDE (MonthName, IsTradingDay, IsOptionExpirationDay);
CREATE INDEX IDX_DimDate_Weeks ON DimDate(Year, WeekOfYear, DayOfWeek) INCLUDE (DayName, IsTradingDay, IsOptionExpirationDay);
GO

CREATE TABLE [dbo].[stg_raw_data](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[datekey] [int] NOT NULL,
	[ticker] [varchar](10) NOT NULL,
	[feature] [varchar](50) NOT NULL,
	[feature_value] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_stg_raw_data] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[FactStockDataPoints](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[datekey] [int] NOT NULL,
	[ticker_id] [int] NOT NULL,
	[feature_type_id] [int] NOT NULL,
	[feature_value] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_FactStockDataPoints] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[rpt_MarketStream](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FullDate] [date] NOT NULL,
	[Ticker] [varchar](10) NOT NULL,
	[High] [decimal](18, 2) NOT NULL,
	[Low] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_rpt_MarketStream] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE INDEX IDX_RptMarketDtream_Ticker ON rpt_MarketStream(Ticker, FullDate);

CREATE TABLE [dbo].[rpt_MarketInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FullDate] [date] NOT NULL,
	[Ticker] [varchar](10) NOT NULL,
	[High_D1] [decimal](18, 2) NULL, [High_D2] [decimal](18, 2) NULL, [High_D3] [decimal](18, 2) NULL, [High_D4] [decimal](18, 2) NULL, [High_D5] [decimal](18, 2) NULL, [High_D6] [decimal](18, 2) NULL, [High_D7] [decimal](18, 2) NULL, [High_D8] [decimal](18, 2) NULL, [High_D9] [decimal](18, 2) NULL, [High_D10] [decimal](18, 2) NULL, [High_D11] [decimal](18, 2) NULL, [High_D12] [decimal](18, 2) NULL, [High_D13] [decimal](18, 2) NULL, [High_D14] [decimal](18, 2) NULL, [High_D15] [decimal](18, 2) NULL, [High_D16] [decimal](18, 2) NULL, [High_D17] [decimal](18, 2) NULL, [High_D18] [decimal](18, 2) NULL, [High_D19] [decimal](18, 2) NULL, [High_D20] [decimal](18, 2) NULL, [High_D21] [decimal](18, 2) NULL, [High_D22] [decimal](18, 2) NULL, [High_D23] [decimal](18, 2) NULL, [High_D24] [decimal](18, 2) NULL, [High_D25] [decimal](18, 2) NULL, [High_D26] [decimal](18, 2) NULL, [High_D27] [decimal](18, 2) NULL, [High_D28] [decimal](18, 2) NULL, [High_D29] [decimal](18, 2) NULL, [High_D30] [decimal](18, 2) NULL, [Low_D1] [decimal](18, 2) NULL, [Low_D2] [decimal](18, 2) NULL, [Low_D3] [decimal](18, 2) NULL, [Low_D4] [decimal](18, 2) NULL, [Low_D5] [decimal](18, 2) NULL, [Low_D6] [decimal](18, 2) NULL, [Low_D7] [decimal](18, 2) NULL, [Low_D8] [decimal](18, 2) NULL, [Low_D9] [decimal](18, 2) NULL, [Low_D10] [decimal](18, 2) NULL, [Low_D11] [decimal](18, 2) NULL, [Low_D12] [decimal](18, 2) NULL, [Low_D13] [decimal](18, 2) NULL, [Low_D14] [decimal](18, 2) NULL, [Low_D15] [decimal](18, 2) NULL, [Low_D16] [decimal](18, 2) NULL, [Low_D17] [decimal](18, 2) NULL, [Low_D18] [decimal](18, 2) NULL, [Low_D19] [decimal](18, 2) NULL, [Low_D20] [decimal](18, 2) NULL, [Low_D21] [decimal](18, 2) NULL, [Low_D22] [decimal](18, 2) NULL, [Low_D23] [decimal](18, 2) NULL, [Low_D24] [decimal](18, 2) NULL, [Low_D25] [decimal](18, 2) NULL, [Low_D26] [decimal](18, 2) NULL, [Low_D27] [decimal](18, 2) NULL, [Low_D28] [decimal](18, 2) NULL, [Low_D29] [decimal](18, 2) NULL, [Low_D30] [decimal](18, 2) NULL, [Volume_D1] [decimal](18, 2) NULL, [Volume_D2] [decimal](18, 2) NULL, [Volume_D3] [decimal](18, 2) NULL, [Volume_D4] [decimal](18, 2) NULL, [Volume_D5] [decimal](18, 2) NULL, [Volume_D6] [decimal](18, 2) NULL, [Volume_D7] [decimal](18, 2) NULL, [Volume_D8] [decimal](18, 2) NULL, [Volume_D9] [decimal](18, 2) NULL, [Volume_D10] [decimal](18, 2) NULL, [Volume_D11] [decimal](18, 2) NULL, [Volume_D12] [decimal](18, 2) NULL, [Volume_D13] [decimal](18, 2) NULL, [Volume_D14] [decimal](18, 2) NULL, [Volume_D15] [decimal](18, 2) NULL, [Volume_D16] [decimal](18, 2) NULL, [Volume_D17] [decimal](18, 2) NULL, [Volume_D18] [decimal](18, 2) NULL, [Volume_D19] [decimal](18, 2) NULL, [Volume_D20] [decimal](18, 2) NULL, [Volume_D21] [decimal](18, 2) NULL, [Volume_D22] [decimal](18, 2) NULL, [Volume_D23] [decimal](18, 2) NULL, [Volume_D24] [decimal](18, 2) NULL, [Volume_D25] [decimal](18, 2) NULL, [Volume_D26] [decimal](18, 2) NULL, [Volume_D27] [decimal](18, 2) NULL, [Volume_D28] [decimal](18, 2) NULL, [Volume_D29] [decimal](18, 2) NULL, [Volume_D30] [decimal](18, 2) NULL, [Range_D1] [decimal](18, 2) NULL, [Range_D2] [decimal](18, 2) NULL, [Range_D3] [decimal](18, 2) NULL, [Range_D4] [decimal](18, 2) NULL, [Range_D5] [decimal](18, 2) NULL, [Range_D6] [decimal](18, 2) NULL, [Range_D7] [decimal](18, 2) NULL, [Range_D8] [decimal](18, 2) NULL, [Range_D9] [decimal](18, 2) NULL, [Range_D10] [decimal](18, 2) NULL, [Range_D11] [decimal](18, 2) NULL, [Range_D12] [decimal](18, 2) NULL, [Range_D13] [decimal](18, 2) NULL, [Range_D14] [decimal](18, 2) NULL, [Range_D15] [decimal](18, 2) NULL, [Range_D16] [decimal](18, 2) NULL, [Range_D17] [decimal](18, 2) NULL, [Range_D18] [decimal](18, 2) NULL, [Range_D19] [decimal](18, 2) NULL, [Range_D20] [decimal](18, 2) NULL, [Range_D21] [decimal](18, 2) NULL, [Range_D22] [decimal](18, 2) NULL, [Range_D23] [decimal](18, 2) NULL, [Range_D24] [decimal](18, 2) NULL, [Range_D25] [decimal](18, 2) NULL, [Range_D26] [decimal](18, 2) NULL, [Range_D27] [decimal](18, 2) NULL, [Range_D28] [decimal](18, 2) NULL, [Range_D29] [decimal](18, 2) NULL, [Range_D30] [decimal](18, 2) NULL, [DailyChange_D1] [decimal](18, 2) NULL, [DailyChange_D2] [decimal](18, 2) NULL, [DailyChange_D3] [decimal](18, 2) NULL, [DailyChange_D4] [decimal](18, 2) NULL, [DailyChange_D5] [decimal](18, 2) NULL, [DailyChange_D6] [decimal](18, 2) NULL, [DailyChange_D7] [decimal](18, 2) NULL, [DailyChange_D8] [decimal](18, 2) NULL, [DailyChange_D9] [decimal](18, 2) NULL, [DailyChange_D10] [decimal](18, 2) NULL, [DailyChange_D11] [decimal](18, 2) NULL, [DailyChange_D12] [decimal](18, 2) NULL, [DailyChange_D13] [decimal](18, 2) NULL, [DailyChange_D14] [decimal](18, 2) NULL, [DailyChange_D15] [decimal](18, 2) NULL, [DailyChange_D16] [decimal](18, 2) NULL, [DailyChange_D17] [decimal](18, 2) NULL, [DailyChange_D18] [decimal](18, 2) NULL, [DailyChange_D19] [decimal](18, 2) NULL, [DailyChange_D20] [decimal](18, 2) NULL, [DailyChange_D21] [decimal](18, 2) NULL, [DailyChange_D22] [decimal](18, 2) NULL, [DailyChange_D23] [decimal](18, 2) NULL, [DailyChange_D24] [decimal](18, 2) NULL, [DailyChange_D25] [decimal](18, 2) NULL, [DailyChange_D26] [decimal](18, 2) NULL, [DailyChange_D27] [decimal](18, 2) NULL, [DailyChange_D28] [decimal](18, 2) NULL, [DailyChange_D29] [decimal](18, 2) NULL, [DailyChange_D30] [decimal](18, 2) NULL, [DailyRangeRatio_D1] [decimal](18, 2) NULL, [DailyRangeRatio_D2] [decimal](18, 2) NULL, [DailyRangeRatio_D3] [decimal](18, 2) NULL, [DailyRangeRatio_D4] [decimal](18, 2) NULL, [DailyRangeRatio_D5] [decimal](18, 2) NULL, [DailyRangeRatio_D6] [decimal](18, 2) NULL, [DailyRangeRatio_D7] [decimal](18, 2) NULL, [DailyRangeRatio_D8] [decimal](18, 2) NULL, [DailyRangeRatio_D9] [decimal](18, 2) NULL, [DailyRangeRatio_D10] [decimal](18, 2) NULL, [DailyRangeRatio_D11] [decimal](18, 2) NULL, [DailyRangeRatio_D12] [decimal](18, 2) NULL, [DailyRangeRatio_D13] [decimal](18, 2) NULL, [DailyRangeRatio_D14] [decimal](18, 2) NULL, [DailyRangeRatio_D15] [decimal](18, 2) NULL, [DailyRangeRatio_D16] [decimal](18, 2) NULL, [DailyRangeRatio_D17] [decimal](18, 2) NULL, [DailyRangeRatio_D18] [decimal](18, 2) NULL, [DailyRangeRatio_D19] [decimal](18, 2) NULL, [DailyRangeRatio_D20] [decimal](18, 2) NULL, [DailyRangeRatio_D21] [decimal](18, 2) NULL, [DailyRangeRatio_D22] [decimal](18, 2) NULL, [DailyRangeRatio_D23] [decimal](18, 2) NULL, [DailyRangeRatio_D24] [decimal](18, 2) NULL, [DailyRangeRatio_D25] [decimal](18, 2) NULL, [DailyRangeRatio_D26] [decimal](18, 2) NULL, [DailyRangeRatio_D27] [decimal](18, 2) NULL, [DailyRangeRatio_D28] [decimal](18, 2) NULL, [DailyRangeRatio_D29] [decimal](18, 2) NULL, [DailyRangeRatio_D30] [decimal](18, 2) NULL, [5dMA_High_D1] [decimal](18, 2) NULL, [5dMA_High_D2] [decimal](18, 2) NULL, [5dMA_High_D3] [decimal](18, 2) NULL, [5dMA_High_D4] [decimal](18, 2) NULL, [5dMA_High_D5] [decimal](18, 2) NULL, [5dMA_High_D6] [decimal](18, 2) NULL, [5dMA_High_D7] [decimal](18, 2) NULL, [5dMA_High_D8] [decimal](18, 2) NULL, [5dMA_High_D9] [decimal](18, 2) NULL, [5dMA_High_D10] [decimal](18, 2) NULL, [5dMA_High_D11] [decimal](18, 2) NULL, [5dMA_High_D12] [decimal](18, 2) NULL, [5dMA_High_D13] [decimal](18, 2) NULL, [5dMA_High_D14] [decimal](18, 2) NULL, [5dMA_High_D15] [decimal](18, 2) NULL, [5dMA_High_D16] [decimal](18, 2) NULL, [5dMA_High_D17] [decimal](18, 2) NULL, [5dMA_High_D18] [decimal](18, 2) NULL, [5dMA_High_D19] [decimal](18, 2) NULL, [5dMA_High_D20] [decimal](18, 2) NULL, [5dMA_High_D21] [decimal](18, 2) NULL, [5dMA_High_D22] [decimal](18, 2) NULL, [5dMA_High_D23] [decimal](18, 2) NULL, [5dMA_High_D24] [decimal](18, 2) NULL, [5dMA_High_D25] [decimal](18, 2) NULL, [5dMA_High_D26] [decimal](18, 2) NULL, [5dMA_High_D27] [decimal](18, 2) NULL, [5dMA_High_D28] [decimal](18, 2) NULL, [5dMA_High_D29] [decimal](18, 2) NULL, [5dMA_High_D30] [decimal](18, 2) NULL, [10dMA_High_D1] [decimal](18, 2) NULL, [10dMA_High_D2] [decimal](18, 2) NULL, [10dMA_High_D3] [decimal](18, 2) NULL, [10dMA_High_D4] [decimal](18, 2) NULL, [10dMA_High_D5] [decimal](18, 2) NULL, [10dMA_High_D6] [decimal](18, 2) NULL, [10dMA_High_D7] [decimal](18, 2) NULL, [10dMA_High_D8] [decimal](18, 2) NULL, [10dMA_High_D9] [decimal](18, 2) NULL, [10dMA_High_D10] [decimal](18, 2) NULL, [10dMA_High_D11] [decimal](18, 2) NULL, [10dMA_High_D12] [decimal](18, 2) NULL, [10dMA_High_D13] [decimal](18, 2) NULL, [10dMA_High_D14] [decimal](18, 2) NULL, [10dMA_High_D15] [decimal](18, 2) NULL, [10dMA_High_D16] [decimal](18, 2) NULL, [10dMA_High_D17] [decimal](18, 2) NULL, [10dMA_High_D18] [decimal](18, 2) NULL, [10dMA_High_D19] [decimal](18, 2) NULL, [10dMA_High_D20] [decimal](18, 2) NULL, [10dMA_High_D21] [decimal](18, 2) NULL, [10dMA_High_D22] [decimal](18, 2) NULL, [10dMA_High_D23] [decimal](18, 2) NULL, [10dMA_High_D24] [decimal](18, 2) NULL, [10dMA_High_D25] [decimal](18, 2) NULL, [10dMA_High_D26] [decimal](18, 2) NULL, [10dMA_High_D27] [decimal](18, 2) NULL, [10dMA_High_D28] [decimal](18, 2) NULL, [10dMA_High_D29] [decimal](18, 2) NULL, [10dMA_High_D30] [decimal](18, 2) NULL, [15dMA_High_D1] [decimal](18, 2) NULL, [15dMA_High_D2] [decimal](18, 2) NULL, [15dMA_High_D3] [decimal](18, 2) NULL, [15dMA_High_D4] [decimal](18, 2) NULL, [15dMA_High_D5] [decimal](18, 2) NULL, [15dMA_High_D6] [decimal](18, 2) NULL, [15dMA_High_D7] [decimal](18, 2) NULL, [15dMA_High_D8] [decimal](18, 2) NULL, [15dMA_High_D9] [decimal](18, 2) NULL, [15dMA_High_D10] [decimal](18, 2) NULL, [15dMA_High_D11] [decimal](18, 2) NULL, [15dMA_High_D12] [decimal](18, 2) NULL, [15dMA_High_D13] [decimal](18, 2) NULL, [15dMA_High_D14] [decimal](18, 2) NULL, [15dMA_High_D15] [decimal](18, 2) NULL, [15dMA_High_D16] [decimal](18, 2) NULL, [15dMA_High_D17] [decimal](18, 2) NULL, [15dMA_High_D18] [decimal](18, 2) NULL, [15dMA_High_D19] [decimal](18, 2) NULL, [15dMA_High_D20] [decimal](18, 2) NULL, [15dMA_High_D21] [decimal](18, 2) NULL, [15dMA_High_D22] [decimal](18, 2) NULL, [15dMA_High_D23] [decimal](18, 2) NULL, [15dMA_High_D24] [decimal](18, 2) NULL, [15dMA_High_D25] [decimal](18, 2) NULL, [15dMA_High_D26] [decimal](18, 2) NULL, [15dMA_High_D27] [decimal](18, 2) NULL, [15dMA_High_D28] [decimal](18, 2) NULL, [15dMA_High_D29] [decimal](18, 2) NULL, [15dMA_High_D30] [decimal](18, 2) NULL, [50dMA_High_D1] [decimal](18, 2) NULL, [50dMA_High_D2] [decimal](18, 2) NULL, [50dMA_High_D3] [decimal](18, 2) NULL, [50dMA_High_D4] [decimal](18, 2) NULL, [50dMA_High_D5] [decimal](18, 2) NULL, [50dMA_High_D6] [decimal](18, 2) NULL, [50dMA_High_D7] [decimal](18, 2) NULL, [50dMA_High_D8] [decimal](18, 2) NULL, [50dMA_High_D9] [decimal](18, 2) NULL, [50dMA_High_D10] [decimal](18, 2) NULL, [50dMA_High_D11] [decimal](18, 2) NULL, [50dMA_High_D12] [decimal](18, 2) NULL, [50dMA_High_D13] [decimal](18, 2) NULL, [50dMA_High_D14] [decimal](18, 2) NULL, [50dMA_High_D15] [decimal](18, 2) NULL, [50dMA_High_D16] [decimal](18, 2) NULL, [50dMA_High_D17] [decimal](18, 2) NULL, [50dMA_High_D18] [decimal](18, 2) NULL, [50dMA_High_D19] [decimal](18, 2) NULL, [50dMA_High_D20] [decimal](18, 2) NULL, [50dMA_High_D21] [decimal](18, 2) NULL, [50dMA_High_D22] [decimal](18, 2) NULL, [50dMA_High_D23] [decimal](18, 2) NULL, [50dMA_High_D24] [decimal](18, 2) NULL, [50dMA_High_D25] [decimal](18, 2) NULL, [50dMA_High_D26] [decimal](18, 2) NULL, [50dMA_High_D27] [decimal](18, 2) NULL, [50dMA_High_D28] [decimal](18, 2) NULL, [50dMA_High_D29] [decimal](18, 2) NULL, [50dMA_High_D30] [decimal](18, 2) NULL, [200dMA_High_D1] [decimal](18, 2) NULL, [200dMA_High_D2] [decimal](18, 2) NULL, [200dMA_High_D3] [decimal](18, 2) NULL, [200dMA_High_D4] [decimal](18, 2) NULL, [200dMA_High_D5] [decimal](18, 2) NULL, [200dMA_High_D6] [decimal](18, 2) NULL, [200dMA_High_D7] [decimal](18, 2) NULL, [200dMA_High_D8] [decimal](18, 2) NULL, [200dMA_High_D9] [decimal](18, 2) NULL, [200dMA_High_D10] [decimal](18, 2) NULL, [200dMA_High_D11] [decimal](18, 2) NULL, [200dMA_High_D12] [decimal](18, 2) NULL, [200dMA_High_D13] [decimal](18, 2) NULL, [200dMA_High_D14] [decimal](18, 2) NULL, [200dMA_High_D15] [decimal](18, 2) NULL, [200dMA_High_D16] [decimal](18, 2) NULL, [200dMA_High_D17] [decimal](18, 2) NULL, [200dMA_High_D18] [decimal](18, 2) NULL, [200dMA_High_D19] [decimal](18, 2) NULL, [200dMA_High_D20] [decimal](18, 2) NULL, [200dMA_High_D21] [decimal](18, 2) NULL, [200dMA_High_D22] [decimal](18, 2) NULL, [200dMA_High_D23] [decimal](18, 2) NULL, [200dMA_High_D24] [decimal](18, 2) NULL, [200dMA_High_D25] [decimal](18, 2) NULL, [200dMA_High_D26] [decimal](18, 2) NULL, [200dMA_High_D27] [decimal](18, 2) NULL, [200dMA_High_D28] [decimal](18, 2) NULL, [200dMA_High_D29] [decimal](18, 2) NULL, [200dMA_High_D30] [decimal](18, 2) NULL, [5dMA_Low_D1] [decimal](18, 2) NULL, [5dMA_Low_D2] [decimal](18, 2) NULL, [5dMA_Low_D3] [decimal](18, 2) NULL, [5dMA_Low_D4] [decimal](18, 2) NULL, [5dMA_Low_D5] [decimal](18, 2) NULL, [5dMA_Low_D6] [decimal](18, 2) NULL, [5dMA_Low_D7] [decimal](18, 2) NULL, [5dMA_Low_D8] [decimal](18, 2) NULL, [5dMA_Low_D9] [decimal](18, 2) NULL, [5dMA_Low_D10] [decimal](18, 2) NULL, [5dMA_Low_D11] [decimal](18, 2) NULL, [5dMA_Low_D12] [decimal](18, 2) NULL, [5dMA_Low_D13] [decimal](18, 2) NULL, [5dMA_Low_D14] [decimal](18, 2) NULL, [5dMA_Low_D15] [decimal](18, 2) NULL, [5dMA_Low_D16] [decimal](18, 2) NULL, [5dMA_Low_D17] [decimal](18, 2) NULL, [5dMA_Low_D18] [decimal](18, 2) NULL, [5dMA_Low_D19] [decimal](18, 2) NULL, [5dMA_Low_D20] [decimal](18, 2) NULL, [5dMA_Low_D21] [decimal](18, 2) NULL, [5dMA_Low_D22] [decimal](18, 2) NULL, [5dMA_Low_D23] [decimal](18, 2) NULL, [5dMA_Low_D24] [decimal](18, 2) NULL, [5dMA_Low_D25] [decimal](18, 2) NULL, [5dMA_Low_D26] [decimal](18, 2) NULL, [5dMA_Low_D27] [decimal](18, 2) NULL, [5dMA_Low_D28] [decimal](18, 2) NULL, [5dMA_Low_D29] [decimal](18, 2) NULL, [5dMA_Low_D30] [decimal](18, 2) NULL, [10dMA_Low_D1] [decimal](18, 2) NULL, [10dMA_Low_D2] [decimal](18, 2) NULL, [10dMA_Low_D3] [decimal](18, 2) NULL, [10dMA_Low_D4] [decimal](18, 2) NULL, [10dMA_Low_D5] [decimal](18, 2) NULL, [10dMA_Low_D6] [decimal](18, 2) NULL, [10dMA_Low_D7] [decimal](18, 2) NULL, [10dMA_Low_D8] [decimal](18, 2) NULL, [10dMA_Low_D9] [decimal](18, 2) NULL, [10dMA_Low_D10] [decimal](18, 2) NULL, [10dMA_Low_D11] [decimal](18, 2) NULL, [10dMA_Low_D12] [decimal](18, 2) NULL, [10dMA_Low_D13] [decimal](18, 2) NULL, [10dMA_Low_D14] [decimal](18, 2) NULL, [10dMA_Low_D15] [decimal](18, 2) NULL, [10dMA_Low_D16] [decimal](18, 2) NULL, [10dMA_Low_D17] [decimal](18, 2) NULL, [10dMA_Low_D18] [decimal](18, 2) NULL, [10dMA_Low_D19] [decimal](18, 2) NULL, [10dMA_Low_D20] [decimal](18, 2) NULL, [10dMA_Low_D21] [decimal](18, 2) NULL, [10dMA_Low_D22] [decimal](18, 2) NULL, [10dMA_Low_D23] [decimal](18, 2) NULL, [10dMA_Low_D24] [decimal](18, 2) NULL, [10dMA_Low_D25] [decimal](18, 2) NULL, [10dMA_Low_D26] [decimal](18, 2) NULL, [10dMA_Low_D27] [decimal](18, 2) NULL, [10dMA_Low_D28] [decimal](18, 2) NULL, [10dMA_Low_D29] [decimal](18, 2) NULL, [10dMA_Low_D30] [decimal](18, 2) NULL, [15dMA_Low_D1] [decimal](18, 2) NULL, [15dMA_Low_D2] [decimal](18, 2) NULL, [15dMA_Low_D3] [decimal](18, 2) NULL, [15dMA_Low_D4] [decimal](18, 2) NULL, [15dMA_Low_D5] [decimal](18, 2) NULL, [15dMA_Low_D6] [decimal](18, 2) NULL, [15dMA_Low_D7] [decimal](18, 2) NULL, [15dMA_Low_D8] [decimal](18, 2) NULL, [15dMA_Low_D9] [decimal](18, 2) NULL, [15dMA_Low_D10] [decimal](18, 2) NULL, [15dMA_Low_D11] [decimal](18, 2) NULL, [15dMA_Low_D12] [decimal](18, 2) NULL, [15dMA_Low_D13] [decimal](18, 2) NULL, [15dMA_Low_D14] [decimal](18, 2) NULL, [15dMA_Low_D15] [decimal](18, 2) NULL, [15dMA_Low_D16] [decimal](18, 2) NULL, [15dMA_Low_D17] [decimal](18, 2) NULL, [15dMA_Low_D18] [decimal](18, 2) NULL, [15dMA_Low_D19] [decimal](18, 2) NULL, [15dMA_Low_D20] [decimal](18, 2) NULL, [15dMA_Low_D21] [decimal](18, 2) NULL, [15dMA_Low_D22] [decimal](18, 2) NULL, [15dMA_Low_D23] [decimal](18, 2) NULL, [15dMA_Low_D24] [decimal](18, 2) NULL, [15dMA_Low_D25] [decimal](18, 2) NULL, [15dMA_Low_D26] [decimal](18, 2) NULL, [15dMA_Low_D27] [decimal](18, 2) NULL, [15dMA_Low_D28] [decimal](18, 2) NULL, [15dMA_Low_D29] [decimal](18, 2) NULL, [15dMA_Low_D30] [decimal](18, 2) NULL, [50dMA_Low_D1] [decimal](18, 2) NULL, [50dMA_Low_D2] [decimal](18, 2) NULL, [50dMA_Low_D3] [decimal](18, 2) NULL, [50dMA_Low_D4] [decimal](18, 2) NULL, [50dMA_Low_D5] [decimal](18, 2) NULL, [50dMA_Low_D6] [decimal](18, 2) NULL, [50dMA_Low_D7] [decimal](18, 2) NULL, [50dMA_Low_D8] [decimal](18, 2) NULL, [50dMA_Low_D9] [decimal](18, 2) NULL, [50dMA_Low_D10] [decimal](18, 2) NULL, [50dMA_Low_D11] [decimal](18, 2) NULL, [50dMA_Low_D12] [decimal](18, 2) NULL, [50dMA_Low_D13] [decimal](18, 2) NULL, [50dMA_Low_D14] [decimal](18, 2) NULL, [50dMA_Low_D15] [decimal](18, 2) NULL, [50dMA_Low_D16] [decimal](18, 2) NULL, [50dMA_Low_D17] [decimal](18, 2) NULL, [50dMA_Low_D18] [decimal](18, 2) NULL, [50dMA_Low_D19] [decimal](18, 2) NULL, [50dMA_Low_D20] [decimal](18, 2) NULL, [50dMA_Low_D21] [decimal](18, 2) NULL, [50dMA_Low_D22] [decimal](18, 2) NULL, [50dMA_Low_D23] [decimal](18, 2) NULL, [50dMA_Low_D24] [decimal](18, 2) NULL, [50dMA_Low_D25] [decimal](18, 2) NULL, [50dMA_Low_D26] [decimal](18, 2) NULL, [50dMA_Low_D27] [decimal](18, 2) NULL, [50dMA_Low_D28] [decimal](18, 2) NULL, [50dMA_Low_D29] [decimal](18, 2) NULL, [50dMA_Low_D30] [decimal](18, 2) NULL, [200dMA_Low_D1] [decimal](18, 2) NULL, [200dMA_Low_D2] [decimal](18, 2) NULL, [200dMA_Low_D3] [decimal](18, 2) NULL, [200dMA_Low_D4] [decimal](18, 2) NULL, [200dMA_Low_D5] [decimal](18, 2) NULL, [200dMA_Low_D6] [decimal](18, 2) NULL, [200dMA_Low_D7] [decimal](18, 2) NULL, [200dMA_Low_D8] [decimal](18, 2) NULL, [200dMA_Low_D9] [decimal](18, 2) NULL, [200dMA_Low_D10] [decimal](18, 2) NULL, [200dMA_Low_D11] [decimal](18, 2) NULL, [200dMA_Low_D12] [decimal](18, 2) NULL, [200dMA_Low_D13] [decimal](18, 2) NULL, [200dMA_Low_D14] [decimal](18, 2) NULL, [200dMA_Low_D15] [decimal](18, 2) NULL, [200dMA_Low_D16] [decimal](18, 2) NULL, [200dMA_Low_D17] [decimal](18, 2) NULL, [200dMA_Low_D18] [decimal](18, 2) NULL, [200dMA_Low_D19] [decimal](18, 2) NULL, [200dMA_Low_D20] [decimal](18, 2) NULL, [200dMA_Low_D21] [decimal](18, 2) NULL, [200dMA_Low_D22] [decimal](18, 2) NULL, [200dMA_Low_D23] [decimal](18, 2) NULL, [200dMA_Low_D24] [decimal](18, 2) NULL, [200dMA_Low_D25] [decimal](18, 2) NULL, [200dMA_Low_D26] [decimal](18, 2) NULL, [200dMA_Low_D27] [decimal](18, 2) NULL, [200dMA_Low_D28] [decimal](18, 2) NULL, [200dMA_Low_D29] [decimal](18, 2) NULL, [200dMA_Low_D30] [decimal](18, 2) NULL, [5dMA_Volume_D1] [decimal](18, 2) NULL, [5dMA_Volume_D2] [decimal](18, 2) NULL, [5dMA_Volume_D3] [decimal](18, 2) NULL, [5dMA_Volume_D4] [decimal](18, 2) NULL, [5dMA_Volume_D5] [decimal](18, 2) NULL, [5dMA_Volume_D6] [decimal](18, 2) NULL, [5dMA_Volume_D7] [decimal](18, 2) NULL, [5dMA_Volume_D8] [decimal](18, 2) NULL, [5dMA_Volume_D9] [decimal](18, 2) NULL, [5dMA_Volume_D10] [decimal](18, 2) NULL, [5dMA_Volume_D11] [decimal](18, 2) NULL, [5dMA_Volume_D12] [decimal](18, 2) NULL, [5dMA_Volume_D13] [decimal](18, 2) NULL, [5dMA_Volume_D14] [decimal](18, 2) NULL, [5dMA_Volume_D15] [decimal](18, 2) NULL, [5dMA_Volume_D16] [decimal](18, 2) NULL, [5dMA_Volume_D17] [decimal](18, 2) NULL, [5dMA_Volume_D18] [decimal](18, 2) NULL, [5dMA_Volume_D19] [decimal](18, 2) NULL, [5dMA_Volume_D20] [decimal](18, 2) NULL, [5dMA_Volume_D21] [decimal](18, 2) NULL, [5dMA_Volume_D22] [decimal](18, 2) NULL, [5dMA_Volume_D23] [decimal](18, 2) NULL, [5dMA_Volume_D24] [decimal](18, 2) NULL, [5dMA_Volume_D25] [decimal](18, 2) NULL, [5dMA_Volume_D26] [decimal](18, 2) NULL, [5dMA_Volume_D27] [decimal](18, 2) NULL, [5dMA_Volume_D28] [decimal](18, 2) NULL, [5dMA_Volume_D29] [decimal](18, 2) NULL, [5dMA_Volume_D30] [decimal](18, 2) NULL, [10dMA_Volume_D1] [decimal](18, 2) NULL, [10dMA_Volume_D2] [decimal](18, 2) NULL, [10dMA_Volume_D3] [decimal](18, 2) NULL, [10dMA_Volume_D4] [decimal](18, 2) NULL, [10dMA_Volume_D5] [decimal](18, 2) NULL, [10dMA_Volume_D6] [decimal](18, 2) NULL, [10dMA_Volume_D7] [decimal](18, 2) NULL, [10dMA_Volume_D8] [decimal](18, 2) NULL, [10dMA_Volume_D9] [decimal](18, 2) NULL, [10dMA_Volume_D10] [decimal](18, 2) NULL, [10dMA_Volume_D11] [decimal](18, 2) NULL, [10dMA_Volume_D12] [decimal](18, 2) NULL, [10dMA_Volume_D13] [decimal](18, 2) NULL, [10dMA_Volume_D14] [decimal](18, 2) NULL, [10dMA_Volume_D15] [decimal](18, 2) NULL, [10dMA_Volume_D16] [decimal](18, 2) NULL, [10dMA_Volume_D17] [decimal](18, 2) NULL, [10dMA_Volume_D18] [decimal](18, 2) NULL, [10dMA_Volume_D19] [decimal](18, 2) NULL, [10dMA_Volume_D20] [decimal](18, 2) NULL, [10dMA_Volume_D21] [decimal](18, 2) NULL, [10dMA_Volume_D22] [decimal](18, 2) NULL, [10dMA_Volume_D23] [decimal](18, 2) NULL, [10dMA_Volume_D24] [decimal](18, 2) NULL, [10dMA_Volume_D25] [decimal](18, 2) NULL, [10dMA_Volume_D26] [decimal](18, 2) NULL, [10dMA_Volume_D27] [decimal](18, 2) NULL, [10dMA_Volume_D28] [decimal](18, 2) NULL, [10dMA_Volume_D29] [decimal](18, 2) NULL, [10dMA_Volume_D30] [decimal](18, 2) NULL, [15dMA_Volume_D1] [decimal](18, 2) NULL, [15dMA_Volume_D2] [decimal](18, 2) NULL, [15dMA_Volume_D3] [decimal](18, 2) NULL, [15dMA_Volume_D4] [decimal](18, 2) NULL, [15dMA_Volume_D5] [decimal](18, 2) NULL, [15dMA_Volume_D6] [decimal](18, 2) NULL, [15dMA_Volume_D7] [decimal](18, 2) NULL, [15dMA_Volume_D8] [decimal](18, 2) NULL, [15dMA_Volume_D9] [decimal](18, 2) NULL, [15dMA_Volume_D10] [decimal](18, 2) NULL, [15dMA_Volume_D11] [decimal](18, 2) NULL, [15dMA_Volume_D12] [decimal](18, 2) NULL, [15dMA_Volume_D13] [decimal](18, 2) NULL, [15dMA_Volume_D14] [decimal](18, 2) NULL, [15dMA_Volume_D15] [decimal](18, 2) NULL, [15dMA_Volume_D16] [decimal](18, 2) NULL, [15dMA_Volume_D17] [decimal](18, 2) NULL, [15dMA_Volume_D18] [decimal](18, 2) NULL, [15dMA_Volume_D19] [decimal](18, 2) NULL, [15dMA_Volume_D20] [decimal](18, 2) NULL, [15dMA_Volume_D21] [decimal](18, 2) NULL, [15dMA_Volume_D22] [decimal](18, 2) NULL, [15dMA_Volume_D23] [decimal](18, 2) NULL, [15dMA_Volume_D24] [decimal](18, 2) NULL, [15dMA_Volume_D25] [decimal](18, 2) NULL, [15dMA_Volume_D26] [decimal](18, 2) NULL, [15dMA_Volume_D27] [decimal](18, 2) NULL, [15dMA_Volume_D28] [decimal](18, 2) NULL, [15dMA_Volume_D29] [decimal](18, 2) NULL, [15dMA_Volume_D30] [decimal](18, 2) NULL, [50dMA_Volume_D1] [decimal](18, 2) NULL, [50dMA_Volume_D2] [decimal](18, 2) NULL, [50dMA_Volume_D3] [decimal](18, 2) NULL, [50dMA_Volume_D4] [decimal](18, 2) NULL, [50dMA_Volume_D5] [decimal](18, 2) NULL, [50dMA_Volume_D6] [decimal](18, 2) NULL, [50dMA_Volume_D7] [decimal](18, 2) NULL, [50dMA_Volume_D8] [decimal](18, 2) NULL, [50dMA_Volume_D9] [decimal](18, 2) NULL, [50dMA_Volume_D10] [decimal](18, 2) NULL, [50dMA_Volume_D11] [decimal](18, 2) NULL, [50dMA_Volume_D12] [decimal](18, 2) NULL, [50dMA_Volume_D13] [decimal](18, 2) NULL, [50dMA_Volume_D14] [decimal](18, 2) NULL, [50dMA_Volume_D15] [decimal](18, 2) NULL, [50dMA_Volume_D16] [decimal](18, 2) NULL, [50dMA_Volume_D17] [decimal](18, 2) NULL, [50dMA_Volume_D18] [decimal](18, 2) NULL, [50dMA_Volume_D19] [decimal](18, 2) NULL, [50dMA_Volume_D20] [decimal](18, 2) NULL, [50dMA_Volume_D21] [decimal](18, 2) NULL, [50dMA_Volume_D22] [decimal](18, 2) NULL, [50dMA_Volume_D23] [decimal](18, 2) NULL, [50dMA_Volume_D24] [decimal](18, 2) NULL, [50dMA_Volume_D25] [decimal](18, 2) NULL, [50dMA_Volume_D26] [decimal](18, 2) NULL, [50dMA_Volume_D27] [decimal](18, 2) NULL, [50dMA_Volume_D28] [decimal](18, 2) NULL, [50dMA_Volume_D29] [decimal](18, 2) NULL, [50dMA_Volume_D30] [decimal](18, 2) NULL, [200dMA_Volume_D1] [decimal](18, 2) NULL, [200dMA_Volume_D2] [decimal](18, 2) NULL, [200dMA_Volume_D3] [decimal](18, 2) NULL, [200dMA_Volume_D4] [decimal](18, 2) NULL, [200dMA_Volume_D5] [decimal](18, 2) NULL, [200dMA_Volume_D6] [decimal](18, 2) NULL, [200dMA_Volume_D7] [decimal](18, 2) NULL, [200dMA_Volume_D8] [decimal](18, 2) NULL, [200dMA_Volume_D9] [decimal](18, 2) NULL, [200dMA_Volume_D10] [decimal](18, 2) NULL, [200dMA_Volume_D11] [decimal](18, 2) NULL, [200dMA_Volume_D12] [decimal](18, 2) NULL, [200dMA_Volume_D13] [decimal](18, 2) NULL, [200dMA_Volume_D14] [decimal](18, 2) NULL, [200dMA_Volume_D15] [decimal](18, 2) NULL, [200dMA_Volume_D16] [decimal](18, 2) NULL, [200dMA_Volume_D17] [decimal](18, 2) NULL, [200dMA_Volume_D18] [decimal](18, 2) NULL, [200dMA_Volume_D19] [decimal](18, 2) NULL, [200dMA_Volume_D20] [decimal](18, 2) NULL, [200dMA_Volume_D21] [decimal](18, 2) NULL, [200dMA_Volume_D22] [decimal](18, 2) NULL, [200dMA_Volume_D23] [decimal](18, 2) NULL, [200dMA_Volume_D24] [decimal](18, 2) NULL, [200dMA_Volume_D25] [decimal](18, 2) NULL, [200dMA_Volume_D26] [decimal](18, 2) NULL, [200dMA_Volume_D27] [decimal](18, 2) NULL, [200dMA_Volume_D28] [decimal](18, 2) NULL, [200dMA_Volume_D29] [decimal](18, 2) NULL, [200dMA_Volume_D30] [decimal](18, 2) NULL, [5dMA_Range_D1] [decimal](18, 2) NULL, [5dMA_Range_D2] [decimal](18, 2) NULL, [5dMA_Range_D3] [decimal](18, 2) NULL, [5dMA_Range_D4] [decimal](18, 2) NULL, [5dMA_Range_D5] [decimal](18, 2) NULL, [5dMA_Range_D6] [decimal](18, 2) NULL, [5dMA_Range_D7] [decimal](18, 2) NULL, [5dMA_Range_D8] [decimal](18, 2) NULL, [5dMA_Range_D9] [decimal](18, 2) NULL, [5dMA_Range_D10] [decimal](18, 2) NULL, [5dMA_Range_D11] [decimal](18, 2) NULL, [5dMA_Range_D12] [decimal](18, 2) NULL, [5dMA_Range_D13] [decimal](18, 2) NULL, [5dMA_Range_D14] [decimal](18, 2) NULL, [5dMA_Range_D15] [decimal](18, 2) NULL, [5dMA_Range_D16] [decimal](18, 2) NULL, [5dMA_Range_D17] [decimal](18, 2) NULL, [5dMA_Range_D18] [decimal](18, 2) NULL, [5dMA_Range_D19] [decimal](18, 2) NULL, [5dMA_Range_D20] [decimal](18, 2) NULL, [5dMA_Range_D21] [decimal](18, 2) NULL, [5dMA_Range_D22] [decimal](18, 2) NULL, [5dMA_Range_D23] [decimal](18, 2) NULL, [5dMA_Range_D24] [decimal](18, 2) NULL, [5dMA_Range_D25] [decimal](18, 2) NULL, [5dMA_Range_D26] [decimal](18, 2) NULL, [5dMA_Range_D27] [decimal](18, 2) NULL, [5dMA_Range_D28] [decimal](18, 2) NULL, [5dMA_Range_D29] [decimal](18, 2) NULL, [5dMA_Range_D30] [decimal](18, 2) NULL, [10dMA_Range_D1] [decimal](18, 2) NULL, [10dMA_Range_D2] [decimal](18, 2) NULL, [10dMA_Range_D3] [decimal](18, 2) NULL, [10dMA_Range_D4] [decimal](18, 2) NULL, [10dMA_Range_D5] [decimal](18, 2) NULL, [10dMA_Range_D6] [decimal](18, 2) NULL, [10dMA_Range_D7] [decimal](18, 2) NULL, [10dMA_Range_D8] [decimal](18, 2) NULL, [10dMA_Range_D9] [decimal](18, 2) NULL, [10dMA_Range_D10] [decimal](18, 2) NULL, [10dMA_Range_D11] [decimal](18, 2) NULL, [10dMA_Range_D12] [decimal](18, 2) NULL, [10dMA_Range_D13] [decimal](18, 2) NULL, [10dMA_Range_D14] [decimal](18, 2) NULL, [10dMA_Range_D15] [decimal](18, 2) NULL, [10dMA_Range_D16] [decimal](18, 2) NULL, [10dMA_Range_D17] [decimal](18, 2) NULL, [10dMA_Range_D18] [decimal](18, 2) NULL, [10dMA_Range_D19] [decimal](18, 2) NULL, [10dMA_Range_D20] [decimal](18, 2) NULL, [10dMA_Range_D21] [decimal](18, 2) NULL, [10dMA_Range_D22] [decimal](18, 2) NULL, [10dMA_Range_D23] [decimal](18, 2) NULL, [10dMA_Range_D24] [decimal](18, 2) NULL, [10dMA_Range_D25] [decimal](18, 2) NULL, [10dMA_Range_D26] [decimal](18, 2) NULL, [10dMA_Range_D27] [decimal](18, 2) NULL, [10dMA_Range_D28] [decimal](18, 2) NULL, [10dMA_Range_D29] [decimal](18, 2) NULL, [10dMA_Range_D30] [decimal](18, 2) NULL, [15dMA_Range_D1] [decimal](18, 2) NULL, [15dMA_Range_D2] [decimal](18, 2) NULL, [15dMA_Range_D3] [decimal](18, 2) NULL, [15dMA_Range_D4] [decimal](18, 2) NULL, [15dMA_Range_D5] [decimal](18, 2) NULL, [15dMA_Range_D6] [decimal](18, 2) NULL, [15dMA_Range_D7] [decimal](18, 2) NULL, [15dMA_Range_D8] [decimal](18, 2) NULL, [15dMA_Range_D9] [decimal](18, 2) NULL, [15dMA_Range_D10] [decimal](18, 2) NULL, [15dMA_Range_D11] [decimal](18, 2) NULL, [15dMA_Range_D12] [decimal](18, 2) NULL, [15dMA_Range_D13] [decimal](18, 2) NULL, [15dMA_Range_D14] [decimal](18, 2) NULL, [15dMA_Range_D15] [decimal](18, 2) NULL, [15dMA_Range_D16] [decimal](18, 2) NULL, [15dMA_Range_D17] [decimal](18, 2) NULL, [15dMA_Range_D18] [decimal](18, 2) NULL, [15dMA_Range_D19] [decimal](18, 2) NULL, [15dMA_Range_D20] [decimal](18, 2) NULL, [15dMA_Range_D21] [decimal](18, 2) NULL, [15dMA_Range_D22] [decimal](18, 2) NULL, [15dMA_Range_D23] [decimal](18, 2) NULL, [15dMA_Range_D24] [decimal](18, 2) NULL, [15dMA_Range_D25] [decimal](18, 2) NULL, [15dMA_Range_D26] [decimal](18, 2) NULL, [15dMA_Range_D27] [decimal](18, 2) NULL, [15dMA_Range_D28] [decimal](18, 2) NULL, [15dMA_Range_D29] [decimal](18, 2) NULL, [15dMA_Range_D30] [decimal](18, 2) NULL, [50dMA_Range_D1] [decimal](18, 2) NULL, [50dMA_Range_D2] [decimal](18, 2) NULL, [50dMA_Range_D3] [decimal](18, 2) NULL, [50dMA_Range_D4] [decimal](18, 2) NULL, [50dMA_Range_D5] [decimal](18, 2) NULL, [50dMA_Range_D6] [decimal](18, 2) NULL, [50dMA_Range_D7] [decimal](18, 2) NULL, [50dMA_Range_D8] [decimal](18, 2) NULL, [50dMA_Range_D9] [decimal](18, 2) NULL, [50dMA_Range_D10] [decimal](18, 2) NULL, [50dMA_Range_D11] [decimal](18, 2) NULL, [50dMA_Range_D12] [decimal](18, 2) NULL, [50dMA_Range_D13] [decimal](18, 2) NULL, [50dMA_Range_D14] [decimal](18, 2) NULL, [50dMA_Range_D15] [decimal](18, 2) NULL, [50dMA_Range_D16] [decimal](18, 2) NULL, [50dMA_Range_D17] [decimal](18, 2) NULL, [50dMA_Range_D18] [decimal](18, 2) NULL, [50dMA_Range_D19] [decimal](18, 2) NULL, [50dMA_Range_D20] [decimal](18, 2) NULL, [50dMA_Range_D21] [decimal](18, 2) NULL, [50dMA_Range_D22] [decimal](18, 2) NULL, [50dMA_Range_D23] [decimal](18, 2) NULL, [50dMA_Range_D24] [decimal](18, 2) NULL, [50dMA_Range_D25] [decimal](18, 2) NULL, [50dMA_Range_D26] [decimal](18, 2) NULL, [50dMA_Range_D27] [decimal](18, 2) NULL, [50dMA_Range_D28] [decimal](18, 2) NULL, [50dMA_Range_D29] [decimal](18, 2) NULL, [50dMA_Range_D30] [decimal](18, 2) NULL, [200dMA_Range_D1] [decimal](18, 2) NULL, [200dMA_Range_D2] [decimal](18, 2) NULL, [200dMA_Range_D3] [decimal](18, 2) NULL, [200dMA_Range_D4] [decimal](18, 2) NULL, [200dMA_Range_D5] [decimal](18, 2) NULL, [200dMA_Range_D6] [decimal](18, 2) NULL, [200dMA_Range_D7] [decimal](18, 2) NULL, [200dMA_Range_D8] [decimal](18, 2) NULL, [200dMA_Range_D9] [decimal](18, 2) NULL, [200dMA_Range_D10] [decimal](18, 2) NULL, [200dMA_Range_D11] [decimal](18, 2) NULL, [200dMA_Range_D12] [decimal](18, 2) NULL, [200dMA_Range_D13] [decimal](18, 2) NULL, [200dMA_Range_D14] [decimal](18, 2) NULL, [200dMA_Range_D15] [decimal](18, 2) NULL, [200dMA_Range_D16] [decimal](18, 2) NULL, [200dMA_Range_D17] [decimal](18, 2) NULL, [200dMA_Range_D18] [decimal](18, 2) NULL, [200dMA_Range_D19] [decimal](18, 2) NULL, [200dMA_Range_D20] [decimal](18, 2) NULL, [200dMA_Range_D21] [decimal](18, 2) NULL, [200dMA_Range_D22] [decimal](18, 2) NULL, [200dMA_Range_D23] [decimal](18, 2) NULL, [200dMA_Range_D24] [decimal](18, 2) NULL, [200dMA_Range_D25] [decimal](18, 2) NULL, [200dMA_Range_D26] [decimal](18, 2) NULL, [200dMA_Range_D27] [decimal](18, 2) NULL, [200dMA_Range_D28] [decimal](18, 2) NULL, [200dMA_Range_D29] [decimal](18, 2) NULL, [200dMA_Range_D30] [decimal](18, 2) NULL, [5dMA_DailyChange_D1] [decimal](18, 2) NULL, [5dMA_DailyChange_D2] [decimal](18, 2) NULL, [5dMA_DailyChange_D3] [decimal](18, 2) NULL, [5dMA_DailyChange_D4] [decimal](18, 2) NULL, [5dMA_DailyChange_D5] [decimal](18, 2) NULL, [5dMA_DailyChange_D6] [decimal](18, 2) NULL, [5dMA_DailyChange_D7] [decimal](18, 2) NULL, [5dMA_DailyChange_D8] [decimal](18, 2) NULL, [5dMA_DailyChange_D9] [decimal](18, 2) NULL, [5dMA_DailyChange_D10] [decimal](18, 2) NULL, [5dMA_DailyChange_D11] [decimal](18, 2) NULL, [5dMA_DailyChange_D12] [decimal](18, 2) NULL, [5dMA_DailyChange_D13] [decimal](18, 2) NULL, [5dMA_DailyChange_D14] [decimal](18, 2) NULL, [5dMA_DailyChange_D15] [decimal](18, 2) NULL, [5dMA_DailyChange_D16] [decimal](18, 2) NULL, [5dMA_DailyChange_D17] [decimal](18, 2) NULL, [5dMA_DailyChange_D18] [decimal](18, 2) NULL, [5dMA_DailyChange_D19] [decimal](18, 2) NULL, [5dMA_DailyChange_D20] [decimal](18, 2) NULL, [5dMA_DailyChange_D21] [decimal](18, 2) NULL, [5dMA_DailyChange_D22] [decimal](18, 2) NULL, [5dMA_DailyChange_D23] [decimal](18, 2) NULL, [5dMA_DailyChange_D24] [decimal](18, 2) NULL, [5dMA_DailyChange_D25] [decimal](18, 2) NULL, [5dMA_DailyChange_D26] [decimal](18, 2) NULL, [5dMA_DailyChange_D27] [decimal](18, 2) NULL, [5dMA_DailyChange_D28] [decimal](18, 2) NULL, [5dMA_DailyChange_D29] [decimal](18, 2) NULL, [5dMA_DailyChange_D30] [decimal](18, 2) NULL, [10dMA_DailyChange_D1] [decimal](18, 2) NULL, [10dMA_DailyChange_D2] [decimal](18, 2) NULL, [10dMA_DailyChange_D3] [decimal](18, 2) NULL, [10dMA_DailyChange_D4] [decimal](18, 2) NULL, [10dMA_DailyChange_D5] [decimal](18, 2) NULL, [10dMA_DailyChange_D6] [decimal](18, 2) NULL, [10dMA_DailyChange_D7] [decimal](18, 2) NULL, [10dMA_DailyChange_D8] [decimal](18, 2) NULL, [10dMA_DailyChange_D9] [decimal](18, 2) NULL, [10dMA_DailyChange_D10] [decimal](18, 2) NULL, [10dMA_DailyChange_D11] [decimal](18, 2) NULL, [10dMA_DailyChange_D12] [decimal](18, 2) NULL, [10dMA_DailyChange_D13] [decimal](18, 2) NULL, [10dMA_DailyChange_D14] [decimal](18, 2) NULL, [10dMA_DailyChange_D15] [decimal](18, 2) NULL, [10dMA_DailyChange_D16] [decimal](18, 2) NULL, [10dMA_DailyChange_D17] [decimal](18, 2) NULL, [10dMA_DailyChange_D18] [decimal](18, 2) NULL, [10dMA_DailyChange_D19] [decimal](18, 2) NULL, [10dMA_DailyChange_D20] [decimal](18, 2) NULL, [10dMA_DailyChange_D21] [decimal](18, 2) NULL, [10dMA_DailyChange_D22] [decimal](18, 2) NULL, [10dMA_DailyChange_D23] [decimal](18, 2) NULL, [10dMA_DailyChange_D24] [decimal](18, 2) NULL, [10dMA_DailyChange_D25] [decimal](18, 2) NULL, [10dMA_DailyChange_D26] [decimal](18, 2) NULL, [10dMA_DailyChange_D27] [decimal](18, 2) NULL, [10dMA_DailyChange_D28] [decimal](18, 2) NULL, [10dMA_DailyChange_D29] [decimal](18, 2) NULL, [10dMA_DailyChange_D30] [decimal](18, 2) NULL, [15dMA_DailyChange_D1] [decimal](18, 2) NULL, [15dMA_DailyChange_D2] [decimal](18, 2) NULL, [15dMA_DailyChange_D3] [decimal](18, 2) NULL, [15dMA_DailyChange_D4] [decimal](18, 2) NULL, [15dMA_DailyChange_D5] [decimal](18, 2) NULL, [15dMA_DailyChange_D6] [decimal](18, 2) NULL, [15dMA_DailyChange_D7] [decimal](18, 2) NULL, [15dMA_DailyChange_D8] [decimal](18, 2) NULL, [15dMA_DailyChange_D9] [decimal](18, 2) NULL, [15dMA_DailyChange_D10] [decimal](18, 2) NULL, [15dMA_DailyChange_D11] [decimal](18, 2) NULL, [15dMA_DailyChange_D12] [decimal](18, 2) NULL, [15dMA_DailyChange_D13] [decimal](18, 2) NULL, [15dMA_DailyChange_D14] [decimal](18, 2) NULL, [15dMA_DailyChange_D15] [decimal](18, 2) NULL, [15dMA_DailyChange_D16] [decimal](18, 2) NULL, [15dMA_DailyChange_D17] [decimal](18, 2) NULL, [15dMA_DailyChange_D18] [decimal](18, 2) NULL, [15dMA_DailyChange_D19] [decimal](18, 2) NULL, [15dMA_DailyChange_D20] [decimal](18, 2) NULL, [15dMA_DailyChange_D21] [decimal](18, 2) NULL, [15dMA_DailyChange_D22] [decimal](18, 2) NULL, [15dMA_DailyChange_D23] [decimal](18, 2) NULL, [15dMA_DailyChange_D24] [decimal](18, 2) NULL, [15dMA_DailyChange_D25] [decimal](18, 2) NULL, [15dMA_DailyChange_D26] [decimal](18, 2) NULL, [15dMA_DailyChange_D27] [decimal](18, 2) NULL, [15dMA_DailyChange_D28] [decimal](18, 2) NULL, [15dMA_DailyChange_D29] [decimal](18, 2) NULL, [15dMA_DailyChange_D30] [decimal](18, 2) NULL, [50dMA_DailyChange_D1] [decimal](18, 2) NULL, [50dMA_DailyChange_D2] [decimal](18, 2) NULL, [50dMA_DailyChange_D3] [decimal](18, 2) NULL, [50dMA_DailyChange_D4] [decimal](18, 2) NULL, [50dMA_DailyChange_D5] [decimal](18, 2) NULL, [50dMA_DailyChange_D6] [decimal](18, 2) NULL, [50dMA_DailyChange_D7] [decimal](18, 2) NULL, [50dMA_DailyChange_D8] [decimal](18, 2) NULL, [50dMA_DailyChange_D9] [decimal](18, 2) NULL, [50dMA_DailyChange_D10] [decimal](18, 2) NULL, [50dMA_DailyChange_D11] [decimal](18, 2) NULL, [50dMA_DailyChange_D12] [decimal](18, 2) NULL, [50dMA_DailyChange_D13] [decimal](18, 2) NULL, [50dMA_DailyChange_D14] [decimal](18, 2) NULL, [50dMA_DailyChange_D15] [decimal](18, 2) NULL, [50dMA_DailyChange_D16] [decimal](18, 2) NULL, [50dMA_DailyChange_D17] [decimal](18, 2) NULL, [50dMA_DailyChange_D18] [decimal](18, 2) NULL, [50dMA_DailyChange_D19] [decimal](18, 2) NULL, [50dMA_DailyChange_D20] [decimal](18, 2) NULL, [50dMA_DailyChange_D21] [decimal](18, 2) NULL, [50dMA_DailyChange_D22] [decimal](18, 2) NULL, [50dMA_DailyChange_D23] [decimal](18, 2) NULL, [50dMA_DailyChange_D24] [decimal](18, 2) NULL, [50dMA_DailyChange_D25] [decimal](18, 2) NULL, [50dMA_DailyChange_D26] [decimal](18, 2) NULL, [50dMA_DailyChange_D27] [decimal](18, 2) NULL, [50dMA_DailyChange_D28] [decimal](18, 2) NULL, [50dMA_DailyChange_D29] [decimal](18, 2) NULL, [50dMA_DailyChange_D30] [decimal](18, 2) NULL, [200dMA_DailyChange_D1] [decimal](18, 2) NULL, [200dMA_DailyChange_D2] [decimal](18, 2) NULL, [200dMA_DailyChange_D3] [decimal](18, 2) NULL, [200dMA_DailyChange_D4] [decimal](18, 2) NULL, [200dMA_DailyChange_D5] [decimal](18, 2) NULL, [200dMA_DailyChange_D6] [decimal](18, 2) NULL, [200dMA_DailyChange_D7] [decimal](18, 2) NULL, [200dMA_DailyChange_D8] [decimal](18, 2) NULL, [200dMA_DailyChange_D9] [decimal](18, 2) NULL, [200dMA_DailyChange_D10] [decimal](18, 2) NULL, [200dMA_DailyChange_D11] [decimal](18, 2) NULL, [200dMA_DailyChange_D12] [decimal](18, 2) NULL, [200dMA_DailyChange_D13] [decimal](18, 2) NULL, [200dMA_DailyChange_D14] [decimal](18, 2) NULL, [200dMA_DailyChange_D15] [decimal](18, 2) NULL, [200dMA_DailyChange_D16] [decimal](18, 2) NULL, [200dMA_DailyChange_D17] [decimal](18, 2) NULL, [200dMA_DailyChange_D18] [decimal](18, 2) NULL, [200dMA_DailyChange_D19] [decimal](18, 2) NULL, [200dMA_DailyChange_D20] [decimal](18, 2) NULL, [200dMA_DailyChange_D21] [decimal](18, 2) NULL, [200dMA_DailyChange_D22] [decimal](18, 2) NULL, [200dMA_DailyChange_D23] [decimal](18, 2) NULL, [200dMA_DailyChange_D24] [decimal](18, 2) NULL, [200dMA_DailyChange_D25] [decimal](18, 2) NULL, [200dMA_DailyChange_D26] [decimal](18, 2) NULL, [200dMA_DailyChange_D27] [decimal](18, 2) NULL, [200dMA_DailyChange_D28] [decimal](18, 2) NULL, [200dMA_DailyChange_D29] [decimal](18, 2) NULL, [200dMA_DailyChange_D30] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D1] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D2] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D3] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D4] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D5] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D6] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D7] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D8] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D9] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D10] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D11] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D12] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D13] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D14] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D15] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D16] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D17] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D18] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D19] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D20] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D21] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D22] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D23] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D24] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D25] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D26] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D27] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D28] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D29] [decimal](18, 2) NULL, [5dMA_DailyRangeRatio_D30] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D1] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D2] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D3] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D4] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D5] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D6] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D7] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D8] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D9] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D10] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D11] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D12] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D13] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D14] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D15] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D16] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D17] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D18] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D19] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D20] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D21] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D22] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D23] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D24] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D25] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D26] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D27] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D28] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D29] [decimal](18, 2) NULL, [10dMA_DailyRangeRatio_D30] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D1] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D2] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D3] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D4] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D5] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D6] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D7] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D8] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D9] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D10] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D11] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D12] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D13] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D14] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D15] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D16] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D17] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D18] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D19] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D20] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D21] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D22] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D23] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D24] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D25] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D26] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D27] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D28] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D29] [decimal](18, 2) NULL, [15dMA_DailyRangeRatio_D30] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D1] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D2] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D3] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D4] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D5] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D6] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D7] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D8] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D9] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D10] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D11] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D12] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D13] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D14] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D15] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D16] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D17] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D18] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D19] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D20] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D21] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D22] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D23] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D24] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D25] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D26] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D27] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D28] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D29] [decimal](18, 2) NULL, [50dMA_DailyRangeRatio_D30] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D1] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D2] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D3] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D4] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D5] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D6] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D7] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D8] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D9] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D10] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D11] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D12] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D13] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D14] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D15] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D16] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D17] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D18] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D19] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D20] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D21] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D22] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D23] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D24] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D25] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D26] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D27] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D28] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D29] [decimal](18, 2) NULL, [200dMA_DailyRangeRatio_D30] [decimal](18, 2) NULL,
    [5DayWindowBestLongBuyPrice] [decimal](18, 2) NULL, [5DayWindowBestLongSellPrice] [decimal](18, 2) NULL, [5DayWindowBestShortBuyPrice] [decimal](18, 2) NULL, [5DayWindowBestShortSellPrice] [decimal](18, 2) NULL, [10DayWindowBestLongBuyPrice] [decimal](18, 2) NULL, [10DayWindowBestLongSellPrice] [decimal](18, 2) NULL, [10DayWindowBestShortBuyPrice] [decimal](18, 2) NULL, [10DayWindowBestShortSellPrice] [decimal](18, 2) NULL, [15DayWindowBestLongBuyPrice] [decimal](18, 2) NULL, [15DayWindowBestLongSellPrice] [decimal](18, 2) NULL, [15DayWindowBestShortBuyPrice] [decimal](18, 2) NULL, [15DayWindowBestShortSellPrice] [decimal](18, 2) NULL, [20DayWindowBestLongBuyPrice] [decimal](18, 2) NULL, [20DayWindowBestLongSellPrice] [decimal](18, 2) NULL, [20DayWindowBestShortBuyPrice] [decimal](18, 2) NULL, [20DayWindowBestShortSellPrice] [decimal](18, 2) NULL
 CONSTRAINT [PK_rpt_MarketStream] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE INDEX IDX_RptMarketInfo_Ticker ON rpt_MarketInfo(Ticker, FullDate);

SET ANSI_PADDING OFF
GO

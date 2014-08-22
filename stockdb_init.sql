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
	[feature_text] [varchar](50) NOT NULL,
	[feature_value] [float] NOT NULL,
 CONSTRAINT [PK_stg_raw_data] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


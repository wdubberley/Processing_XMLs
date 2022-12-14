USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Lapsed_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************************************************
  Created:	KPHAM (20190215)
  Desc:		This USP corrects/inserts the lapsed dates records to make sure there is only 1440 minutes per day
  20220223(v002)- Added Pump_Operator
*******************************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Lapsed_Insert]
AS
BEGIN

	declare @tbl_xTT_lapsed 
				AS TABLE (ID_Record INT, PadName VARCHAR(255)
						, StartDateTime DATETIME, EndDateTime DATETIME, EventStartDate DATE, EventEndDate DATE
						, FracTime_MIN FLOAT, RecordNo INT
						, days_Lapsed INT)

	/***** GET ONLY records with lapsed dates *****/
	INSERT INTO @tbl_xTT_lapsed
	SELECT ID_Record		= xT.ID_Record
		, PadName			= xT.Pad
		, [StartDateTime]	= xT.[Date/Time]
		, [EndDateTime]		= xT.[EndDate/Time]
		, [EventStartDate]	= CONVERT(DATE, DATEADD(MINUTE,1,xT.[Date/Time]))
		, [EventEndDate]	= CONVERT(DATE, DATEADD(MINUTE,-1,xT.[EndDate/Time]))
		, FracTime_min		= xT.[Minutes]

		, [RecordNo]	= xT.[Record#]

		, days_Lapsed	= DATEDIFF(DD, CONVERT(DATE, DATEADD(MINUTE,1,xT.[Date/Time])), CONVERT(DATE, DATEADD(MINUTE,-1,xT.[EndDate/Time]))) 

		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
	
		WHERE DATEDIFF(DD, CONVERT(DATE, DATEADD(MINUTE,1,xT.[Date/Time])), CONVERT(DATE, DATEADD(MINUTE,-1,xT.[EndDate/Time]))) > 0

	--SELECT * FROM @tbl_xTT_lapsed xL

	DECLARE @tbl_Replace 
				AS TABLE (ID_Record INT, PadName VARCHAR(255)
						, StartDateTime DATETIME, EndDateTime DATETIME
						, RecordNo INT)
	
	/**** CREATE records to replace ****/
	INSERT INTO @tbl_Replace
	SELECT ID_Record= xL.ID_Record 
		, PadName	= xL.PadName
		, StartDateTime	= case when xL.startdatetime >= DATEADD(MINUTE, -1, eD.theDate) THEN xL.StartDateTime ELSE DATEADD(MINUTE, -1, eD.theDate) END
		, EndDateTime	= case when xL.enddatetime <= DATEADD(MINUTE, 1439, eD.theDate) THEN xL.enddatetime ELSE DATEADD(MINUTE, 1439, eD.theDate) END
		, RecordNo	= xL.RecordNo

		/****** TESTING Parameters 
		, s = case when xL.startdatetime >= DATEADD(MINUTE, -1, eD.theDate) THEN xL.StartDateTime ELSE DATEADD(MINUTE, -1, eD.theDate) END
		, e = case when xL.enddatetime <= DATEADD(MINUTE, 1439, eD.theDate) THEN xL.enddatetime ELSE DATEADD(MINUTE, 1439, eD.theDate) END
		
		, tStart	= DATEADD(MINUTE, -1, eD.theDate)
		, tStop		= DATEADD(MINUTE, 1439, eD.theDate)

		, r			= ROW_NUMBER() OVER(PARTITION BY xL.PadName, xL.RecordNo ORDER BY xL.RecordNo)
		--*****************************************************/

		FROM @tbl_xTT_lapsed xL
			INNER JOIN dbo.ExplodeDates((SELECT MIN(EventStartDate) FROM @tbl_xTT_lapsed), (SELECT MAX(EventEndDate) FROM @tbl_xTT_lapsed)) eD 
				ON eD.thedate BETWEEN xL.EventStartDate AND xL.EventEndDate

	/**** INSERT new records into SSIS.xmlImport_TT_TimeLogs if it hasn't been added already *****/
	INSERT INTO [SSIS_ENG].xmlImport_TT_TimeLogs
	SELECT xT.[Customer]
		,xT.[Pad]
		,xT.[TotalWellsOnPad]
		,xT.[WellsToStimulate]
		,xT.[TotalStagesOnPad]
		,xT.[Pad_No]
		,xT.[Camp]
		,xT.[Crew]
		,xT.[QAQC]
		,xT.[Engineer]
		,xT.[Supervisor]
		,xT.[CustomerRep]
		,xT.[Well]
		,xT.[Stage]
		,xT.[Type]
		
		,[Date/Time]	= xL.[StartDateTime]
		,xT.[Party]
		,xT.[Main Event]
		,xT.[Time]
		,xT.[Complete]
		,xT.[MHHP]
		,xT.[LOS/3rd]
		
		,[Minutes]	= DATEDIFF(MINUTE, xL.[StartDateTime], xL.[EndDateTime])
		,[Month]	= DATEPART(MONTH, xL.[EndDateTime])
		,[Day]		= DATEPART(DAY, xL.[EndDateTime])
		,[Year]		= DATEPART(YEAR, xL.[EndDateTime])
		,[QTR]		= 'Q' + CONVERT(VARCHAR(5), DATEPART(QUARTER, xL.[EndDateTime]))
		
		,[Start Date]	= CONVERT(DATE, xL.[StartDateTime])
		,[End Date]		= CONVERT(DATE, xL.[EndDateTime])
		,[EndDate/Time]	= xL.[EndDateTime]
		
		,xT.[EventofDay]
		,xT.[Vnum]
		,xT.[Alias]
		,xT.[Gen Main Event]
		,xT.[StageCount]
		,xT.[QTRYR]
		,xT.[PumpTime]
		,xT.[Notes]
		,xT.[Record#]
		,xT.[Yes Indicator]
		,xT.[Yes/stage]
		,xT.[StickNum]
		,xT.[InProgRef]
		,xT.[Time Charge]
		,xT.[InProgress]
		,xT.[FilePath]
		,xT.[FileDate]
		,xT.[xmlFileSize]
		,xT.[Pump_Operator]

		FROM @tbl_Replace xL
			INNER JOIN [SSIS_ENG].xmlImport_TT_TimeLogs xT
				ON xT.ID_Record = xL.ID_Record
		WHERE NOT EXISTS (SELECT t.ID_Record 
							FROM [SSIS_ENG].xmlImport_TT_TimeLogs t 
							WHERE t.Pad					= xL.PadName 
								AND t.Record#			= xL.RecordNo 
								AND t.[Date/Time]		= xL.[StartDateTime]
								AND t.[EndDate/Time]	= xL.[EndDateTime]
							)
		
	/******* REMOVE Lapsed records ******/
	--SELECT x.ID_Record, x.Pad, x.Well, x.[Date/Time], x.[EndDate/Time]
	DELETE x
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs x
			INNER JOIN @tbl_xTT_lapsed l ON l.ID_Record = x.ID_Record

	;

END 

GO

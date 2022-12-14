USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTT_TimeLogs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************
  Created:	KPHAM (2018)
  20211022(v008)- Modified tmp_Pads to limit only recent/re-open Pads for TTs
  20220223(v009)- Added ID_PumpOperator per DK
  20220623(v010)- Added DECIMAL(18,10) conversion to MINUTES
***************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTT_TimeLogs]()
RETURNS TABLE
AS
RETURN 

	WITH tmp_Pads AS
			(SELECT p.ID_Pad, fPadName = p.Field_PadName, ID_Operator = p.ID_Operator, maxDate = p.tTo
				FROM [dbo].fnREFs_Pads('') p
				WHERE p.db_Current = 1
					OR ISNULL(p.cPad_FracTime,0) = 0
					OR DATEDIFF(dd, ISNULL(p.tTo, p.tFr), GETDATE()) <= 30
			--UNION
			--	SELECT DISTINCT 
			--	  ID_Pad		= tt.ID_Pad
			--	, fPadName		= rP.Field_PadName
			--	, ID_Operator	= rP.ID_Operator
			--	, maxDate		= MAX(ISNULL(tt.EventEndDateTime, tt.StartDateTime))
			--	FROM [dbo].FracTime tt
			--		INNER JOIN [dbo].[LOS_Pads]	rP ON rP.ID_Pad = tt.ID_Pad
			--	GROUP BY tt.ID_Pad
			--		, rP.Field_PadName
			--		, rP.ID_Operator
			--	HAVING DATEDIFF(dd, MAX(ISNULL(tt.EventEndDateTime, tt.StartDateTime)), GETDATE()) <= 30
			)	/* 20211022 */

		/***** OLD/Removed 20211022 *********************************
		, tmp_Pads AS
			(SELECT ID_Pad = 0, fPadName = '', ID_Operator = 0 UNION
			SELECT p.ID_Pad, fPadName = p.Field_PadName, ID_Operator = p.ID_Operator
				FROM [dbo].LOS_Pads p)
		******************************************************************/
		,cte_Wells AS
			(SELECT DISTINCT Customer
				, Pad
				, WellName
				, tt_Well
				, minPadRecord
				, splitCount
				FROM [SSIS_ENG].fnRPT_xmlTT_Wells() wTT)
		,tmp_Crews AS
			(SELECT ID_Crew = 0, CrewName = '', ID_District = 0 UNION 
			SELECT ID_Crew, CrewName = CrewNameAlt, ID_District FROM dbo.ref_Crews WHERE CrewNameAlt <> '' UNION
			SELECT ID_Crew, CrewName, ID_District FROM dbo.ref_Crews WHERE IsActive = 1)
		,tmp_Employees AS
			(SELECT ID_Employee = 0, EmployeeName = '' UNION 
			SELECT ID_Employee, EmployeeName FROM [SSIS_ENG].mapping_Employees)
		,tmp_CustReps AS
			(SELECT ID_Record = 0, CustRep = '' UNION 
			SELECT ID_Record, CustRep = t.FirstName + ' ' + t.LastName FROM dbo.ref_Representatives t)
		,tmp_CompType AS 
			(SELECT ID_Record = 0, ItemName = '' UNION
			SELECT ID_Record, ItemName FROM dbo.ref_Categories WHERE ID_Parent = 9)
		,tmp_Party AS 
			(SELECT ID_TimeParty = 0, PartyName = '' UNION
			SELECT ID_TimeParty, PartyName FROM dbo.ref_TimeParties)
		,tmp_mEvents AS 
			(SELECT ID_MainEvent = 0, EventName = '' UNION
			SELECT ID_MainEvent = ID_TimeEvent, EventName FROM dbo.ref_TimeEvents)
		,tmp_gEvents AS 
			(SELECT ID_GenMainEvent = 0, genEvent = '' UNION
			SELECT ID_GenMainEvent, genEvent = EventDesc FROM dbo.ref_GenMainEvents)
		,tmp_tClasses AS 
			(SELECT ID_TimeClass = 0, TimeClass = '' UNION
			SELECT ID_TimeClass, TimeClass = TimeClass_Abbr FROM dbo.ref_TimeClasses)
		,tmp_tTypes AS 
			(SELECT ID_TimeType = 0, TimeType = '' UNION
			SELECT ID_TimeType, TimeType FROM dbo.ref_TimeTypes)
		,tmp_Alias AS 
			(SELECT ID_Alias = 0, AliasName = '' UNION
			SELECT ID_Alias, AliasName FROM dbo.ref_Alias)

	SELECT ID_Record	= xT.ID_Record
		, rNo			= RANK() OVER(PARTITION BY xT.Customer, xT.Pad
										ORDER BY xT.Customer, xT.Pad, xT.[Date/Time], xT.[Record#], xW.WellName)		/* 20181017 */
		
		, ID_Operator	= mO.ID_Operator
		, ID_Pad		= ISNULL(xP.ID_Pad, 0)
		, ID_Camp		= ISNULL(xT.Camp, rC.ID_District) /* If cannot map District by Camp, map ID_District to Crew's district */
		, ID_Crew		= rC.ID_Crew
		, ID_Well		= rW.ID_Well

		, Customer	= xT.Customer
		, Pad		= xT.Pad
		, Pad_No	= xT.Pad_No
		, Crew		= xT.Crew

		, ID_PumpOperator	= CASE WHEN xT.Pump_Operator IS NULL THEN 0 ELSE rPumpOp.ID_Employee END
		, ID_QAQC		= CASE WHEN xT.QAQC = 'Yes' OR xT.QAQC IS NULL THEN 0 ELSE rQAQC.ID_Employee END
		, ID_Engineer	= rEng.ID_Employee
		, ID_Supervisor	= rSup.ID_Employee
		, ID_CustomerRep= rRep.ID_Record

		, StageNo		= ISNULL(xT.Stage, 0)
		, ID_CompletionType	= rCompType.ID_Record
		, StartDateTime		= xT.[Date/Time]
		, [EndDateTime]		= xT.[EndDate/Time]
		, [EventStartDate]	= CONVERT(DATE, xT.[Start Date])
		, [EventEndDate]	= CONVERT(DATE, xT.[End Date])
		
		, ID_Party		= rParty.ID_TimeParty
		, ID_MainEvent	= mEvent.ID_MainEvent
		, ID_TimeClass	= tClass.ID_TimeClass
		, IsComplete	= CASE WHEN xT.Complete LIKE 'Y%' THEN 16 
							WHEN xT.Complete LIKE 'N%' OR xT.Complete = '0' THEN 17 
							ELSE 15 END 

		, MHHP		= xT.[MHHP]						/* Obsolete in 2019; data will be recorded in TS-Inputs */
		, LOS3rd	= CASE WHEN xT.Party IN ('3rd Party LOS') AND xT.[LOS/3rd] <> 'LOS' THEN 2						/* 20200122 */
						ELSE ISNULL(tType.ID_TimeType, 1) END
		
		, FracTime_min = CASE WHEN xT.Well <> xW.WellName  THEN xT.[Minutes] / xW.splitCount ELSE CONVERT(DECIMAL(18,10),xT.[Minutes]) END

		/* Hidden as calculated on TT-TimeLog */
		, [Month]	= DATEPART(MM, xT.[EndDate/Time])
		, [Day]		= DATEPART(DD, xT.[EndDate/Time]) 
		, [Year]	= DATEPART(YYYY, xT.[EndDate/Time])
		, [QTR]		= 'Q' + CONVERT(VARCHAR(5), DATEPART(QUARTER, xT.[EndDate/Time]))

		, EventofDay	= xT.[EventofDay]
		, ID_Alias		= tAlias.ID_Alias
		, ID_GenMainEvent	= gEvent.ID_GenMainEvent
		
		, YrQtr		= CONVERT(VARCHAR(5), DATEPART(YYYY, xT.[EndDate/Time])) 
					+ 'Q' + CONVERT(VARCHAR(5), DATEPART(QUARTER, xT.[EndDate/Time]))
		, StageCount		= xT.StageCount
		, PumpTime			= xT.PumpTime
		, Notes				= xT.Notes
		, RecordNo			= xT.[Record#]
		, StickNum			= xT.StickNum

		, xmlFileName		= xT.FilePath
		, xmlFileDate		= xT.FileDate
		, xmlFileSize		= xT.xmlFileSize

		, Archive_Notes		= CASE WHEN xT.Well <> xW.WellName  
									THEN 'RecordNo: ' + CONVERT(VARCHAR(10), xT.[Record#]) 
										+ '| Mult-Well (' + CONVERT(VARCHAR(10), xW.splitCount) + '): ' + xW.tt_Well  /* 20181016 */
								ELSE '' END 
		, minPadRecord		= xW.minPadRecord
				
		/* Actual values from XMLs */
		, TotalWellsOnPad	= xT.TotalWellsOnPad
		, WellsToStimulate	= xT.WellsToStimulate
		, TotalStagesOnPad	= xT.TotalStagesOnPad
		, Camp		= xT.Camp					/* OBSOLETE */
		, QAQC		= xT.QAQC
		, Engineer	= xT.Engineer
		, Supervisor= xT.Supervisor
		, CustomerRep= xT.CustomerRep
		
		, Well		= CASE WHEN xT.Well <> xW.WellName THEN xW.WellName ELSE xW.WellName END
		, [Type]	= xT.[Type]
		, Party		= xT.Party
		, [Main Event]		= xT.[Main Event]
		, [TimeClass]		= xT.[Time]
		, Complete			= xT.[Complete]
		, [LOS/3rd]			= xT.[LOS/3rd]
		, [Minutes]			= xT.[Minutes]		
		
		, Vnum				= ISNULL(xT.Vnum, 0)
		, Alias				= xT.Alias
		, [Gen Main Event]	= xT.[Gen Main Event]
		, QTRYR				= xT.QTRYR
		--, [Yes Indicator]	= xT.[Yes Indicator]
		--, [Yes/stage]		= xT.[Yes/stage]
		--, InProgRef			= xT.InProgRef
		--, [Time Charge]		= xT.[Time Charge]
		--, InProgress		= xT.InProgress

		, countSync	= CASE WHEN xT.Well <> xW.WellName THEN xW.splitCount ELSE 1 END /* 20190806 */

		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
			INNER JOIN [SSIS_ENG].mapping_Customer_Operator mO ON mO.Customer = xT.Customer
			INNER JOIN cte_Wells	xW ON xW.Pad = xT.Pad AND xW.tt_Well = xT.Well	
			INNER JOIN tmp_Pads		xP ON xP.ID_Operator = mO.ID_Operator AND xP.fPadName = xT.Pad 
												
			INNER JOIN dbo.LOS_Wells	rW ON rW.WellName = xW.WellName
			INNER JOIN tmp_Crews		rC ON xT.Crew = ISNULL(rC.CrewName, '')
			
			/* 20220223 */
			INNER JOIN tmp_Employees	rPumpOp	ON rPumpOp.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xT.Pump_Operator))) = 0 
																			THEN LTRIM(RTRIM(ISNULL(xT.Pump_Operator, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xT.Pump_Operator, '')))
																		ELSE LTRIM(RTRIM(ISNULL(xT.Pump_Operator, ''))) END		--LTRIM(RTRIM(ISNULL(xT.QAQC, '')))
			/* 20190312 */
			INNER JOIN tmp_Employees	rQAQC	ON rQAQC.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xT.QAQC))) = 0 
																			THEN LTRIM(RTRIM(ISNULL(xT.QAQC, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xT.QAQC, '')))
																		ELSE LTRIM(RTRIM(ISNULL(xT.QAQC, ''))) END		--LTRIM(RTRIM(ISNULL(xT.QAQC, '')))
			INNER JOIN tmp_Employees	rEng	ON rEng.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xT.Engineer))) = 0 
																			THEN LTRIM(RTRIM(ISNULL(xT.Engineer, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xT.Engineer, '')))
																		ELSE LTRIM(RTRIM(ISNULL(xT.Engineer, ''))) END	--LTRIM(RTRIM(ISNULL(xT.Engineer, '')))
			INNER JOIN tmp_Employees	rSup	ON rSup.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xT.Supervisor))) = 0 
																			THEN LTRIM(RTRIM(ISNULL(xT.Supervisor, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xT.Supervisor, '')))
																		ELSE LTRIM(RTRIM(ISNULL(xT.Supervisor, ''))) END --LTRIM(RTRIM(ISNULL(xT.Supervisor, '')))
			INNER JOIN tmp_CustReps		rRep	ON rRep.CustRep = LTRIM(RTRIM(ISNULL(xT.CustomerRep, '')))

			INNER JOIN tmp_CompType	rCompType	ON rCompType.ItemName = ISNULL(xT.[Type], '')
			INNER JOIN tmp_Party	rParty		ON rParty.PartyName = ISNULL(xT.Party, '')

			INNER JOIN tmp_mEvents	mEvent	ON mEvent.EventName = ISNULL(xT.[Main Event], '')
			INNER JOIN tmp_gEvents	gEvent	ON gEvent.genEvent = ISNULL(xT.[Gen Main Event], '')
			INNER JOIN tmp_tClasses	tClass	ON tClass.TimeClass = ISNULL(xT.[Time], '')
			INNER JOIN tmp_tTypes	tType	ON tType.TimeType = ISNULL(xT.[LOS/3rd], 'Unk')
			INNER JOIN tmp_Alias	tAlias	ON tAlias.AliasName = ISNULL(xT.[Alias], '')	

GO

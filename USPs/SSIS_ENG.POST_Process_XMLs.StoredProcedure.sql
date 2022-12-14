USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[POST_Process_XMLs]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************
  Created:	KPHAM
  20190117- Changed SSIS_ENG.fnRPT_xmlTS_FracStages_Designs_ChemSP() to phase out old FN
  20190118- Changed SSIS_ENG.fnRPT_xmlTS_FracStages_Designs() & SSIS_ENG.fnRPT_xmlTS_FracStages_ChemTotals()to phase out old FN
  20190201(v002)- Update code to filter correct rows for skipped/unprocessed rows from SSIS.fnRPT_xmlTT_TimeLogs()
  20190219(v003)- Update code to add Records & Pads section being skipped in TT process
  20190305(v004)- Update code to read from SSIS.fnRPT_xmlTS_FracQuotes(); (SSIS.fnRPT_xmlTQ_FracQuotes() expired)
  20201113(v005)- Update code to record unprocessed CSs
  20200104(v006)- Remove  CHEM
**************************************************************/
CREATE PROCEDURE [SSIS_ENG].[POST_Process_XMLs]	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vUserAction	AS VARCHAR(255) = 'Unable to Process'
		, @pID_Process		AS INT = 0

	SELECT @pID_Process = [SSIS_ENG].[fnSSIS_GetProcess_START]()
	;

	WITH cte_diffINFO AS 
		(SELECT rOrder = 2, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracInfo()'
			, xInfo = (SELECT COUNT(*) from [SSIS_ENG].[xmlImport_TS_FracInfo])
			, fInfo = (SELECT COUNT(*) from [SSIS_ENG].[fnRPT_xmlTS_FracInfo] ())
		)
		,cte_diffTT AS		/* 20190219 */
		(SELECT rOrder = 1, TableName	= 'SSIS_ENG.fnRPT_xmlTT_TimeLogs()'
			, xTT = (SELECT COUNT(*) FROM [SSIS_ENG].xmlImport_TT_TimeLogs)
			, fTT = (SELECT COUNT(*) FROM [SSIS_ENG].fnRPT_xmlTT_TimeLogs())

			, xP	= (SELECT COUNT(DISTINCT Pad) FROM [SSIS_ENG].xmlImport_TT_TimeLogs)
			, fP	= (SELECT COUNT(DISTINCT ID_Pad) FROM [SSIS_ENG].fnRPT_xmlTT_TimeLogs())
		)
		, cteHistory AS
		(/****** TimeTracker (TT) ***********/
		SELECT rOrder = 1, TableName	= 'SSIS_ENG.fnRPT_xmlTT_TimeLogs()', rCount = COUNT(*)
			from SSIS_ENG.fnRPT_xmlTT_TimeLogs() 
			where (id_pad is null OR ID_Pad = 0
					or id_crew is null OR ID_Crew = 0
					or id_well is null OR ID_Well = 0
					or id_operator is null OR ID_Operator = 0)
				or (RecordNo < StickNum) 
		UNION 		/* 20190219 */
		SELECT rOrder = 1, TableName	= 'SSIS_ENG.fnRPT_xmlTT_TimeLogs() - Records', rCount = xTT - fTT
			FROM cte_diffTT
			WHERE xTT <> fTT
		UNION 
		SELECT rOrder = 1, TableName	= 'SSIS_ENG.fnRPT_xmlTT_TimeLogs() - Pads', rCount = xP - fP
			FROM cte_diffTT
			WHERE xP <> fP
		
		/****** TechSheet header info (TS) ***********/
		UNION ALL
		SELECT rOrder = 2, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracInfo()', rCount = COUNT(*)
			from SSIS_ENG.fnRPT_xmlTS_FracInfo()
			WHERE ID_Pad IS null or ID_Well is null or ID_District is null
		UNION 
		SELECT rOrder = 2, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracInfo()', rCount = xInfo - fInfo
			from cte_diffINFO
			WHERE xInfo <> fInfo
		
		/****** Stages header (TS) ***********/
		UNION
		SELECT rOrder = 3, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_FracStages()
			WHERE ID_FracInfo is null or ID_Crew is null or ID_CustRep is null or ID_Supervisor is null or ID_Engineer is null
		
		/****** Injections per stage (TS) ***********/
		UNION
		SELECT rOrder = 4, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages_Chemicals()', rCount = COUNT(*) 
			FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Chemicals]()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Chemical IS NULL
		UNION
		SELECT rOrder = 5, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages_Proppants()', rCount = COUNT(*)
			from SSIS_ENG.fnRPT_xmlTS_FracStages_Proppants()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Proppant IS NULL
		UNION
		SELECT rOrder = 6, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages_Fluids()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_FracStages_Fluids()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Fluid IS NULL
		
		/****** Charges per stage (TS) ***********/
		UNION
		SELECT rOrder = 7, TableName	= 'SSIS_ENG.fnRPT_xmlTS_Charge_Chemicals()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_Charge_Chemicals()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Chemical IS NULL
		UNION
		SELECT rOrder = 8, TableName	= 'SSIS_ENG.fnRPT_xmlTS_Charge_Proppants()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_Charge_Proppants()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Proppant IS NULL
		UNION
		SELECT rOrder = 9, TableName	= 'SSIS_ENG.fnRPT_xmlTS_Charge_Services()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_Charge_Services()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_ChargeService IS NULL
		
		/****** Analysis data (TS) ***********/
		UNION
		SELECT rOrder = 10, TableName	= 'SSIS_ENG.fnRPT_xmlTS_ComparisonChemicals()', rCount = COUNT(*)
			FROM [SSIS_ENG].[fnRPT_xmlTS_ComparisonChemicals] ()
			WHERE ID_FracInfo is null OR StageNo IS NULL OR ID_Chemical IS NULL
		UNION
		SELECT rOrder = 11, TableName	= 'SSIS_ENG.fnRPT_xmlTS_DiverterPressureAnalysis()', rCount = COUNT(*)
			FROM [SSIS_ENG].[fnRPT_xmlTS_DiverterPressureAnalysis] ()
			WHERE ID_FracInfo is null OR StageNo IS NULL 

		/****** Final Designs (TS) ***********/
		UNION
		SELECT rOrder = 12, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages_Designs()', rCount = COUNT(*)				/* 20190118 */
			FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs]()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL 
		UNION
		SELECT rOrder = 13, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages_Designs_ChemSP()', rCount = COUNT(*)			/* 20190117 */
			FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs_ChemSP]()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Chemical IS NULL
		UNION
		SELECT rOrder = 14, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracStages_ChemTotals()', rCount = COUNT(*)					/* 20190118 */
			FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_ChemTotals]()
			WHERE ID_FracInfo is null OR ID_FracStage IS NULL OR ID_Chemical IS NULL

		/****** Customer Surveys (CS) ***********/
		UNION		/* 20201113 */
		SELECT rOrder = 15, TableName	= 'SSIS_ENG.xmlImport_CustomerSurveys' , rCount = COUNT(*) - COUNT(i.ID_FracInfo)
			FROM [SSIS_ENG].xmlImport_CustomerSurveys	x
				LEFT JOIN dbo.LOS_Wells	w on w.WellName = x.Well_Name
				LEFT JOIN dbo.FracInfo	i on i.ID_Well = w.ID_Well
											AND i.LOS_ProjectNo	= CASE WHEN CHARINDEX('-', Ticket_No,1) = 0 THEN Ticket_No
																	ELSE SUBSTRING(Ticket_No,CHARINDEX('-', Ticket_No,1)+1, LEN(Ticket_No)) END

		/****** Ticket/Quote (TQ) ***********/
		UNION
		SELECT rOrder = 16, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracTickets()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_FracTickets ()
			WHERE ID_FracInfo IS NULL 
		
		UNION
		SELECT rOrder = 17, TableName	= 'SSIS_ENG.fnRPT_xmlTS_FracQuotes()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlTS_FracQuotes ()
			WHERE ID_FracInfo IS NULL

		/****** Material Tracker (MAT) ***********/
		UNION
		SELECT rOrder = 18, TableName	= 'SSIS_ENG.fnRPT_xmlMAT_Info()', rCount = COUNT(*)
			FROM SSIS_ENG.fnRPT_xmlMAT_Info ()
			WHERE ID_MaterialInfo IS NULL OR ID_Pad IS NULL
		
		/****** Chemical Inventory (CHEM) ***********/
		--UNION
		--SELECT rOrder = 19, TableName	= 'SSIS_ENG.fnRPT_xmlCHEM_Info()', rCount = COUNT(*)
		--	FROM [SSIS_ENG].[fnRPT_xmlCHEM_Info] ()
		--	WHERE ID_ChemInventoryInfo IS NULL OR ID_Pad IS NULL
		
		
		/****** Location Straps (CHEM) ***********/
		UNION
		SELECT rOrder = 20, TableName	= 'SSIS_ENG.fnRPT_xmlLCS_Info()', rCount = COUNT(*)
			FROM [SSIS_ENG].[fnRPT_xmlLCS_Info] ()
			WHERE ID_LocStrapInfo IS NULL OR ID_Pad IS NULL
		
		/****** Lab Data (LAB) ***********/
		UNION
		SELECT rOrder = 21, TableName	= 'SSIS_ENG.fnRPT_xmlLAB_Info()', rCount = COUNT(*)
			FROM [SSIS_ENG].[fnRPT_xmlLAB_Info] ()
			WHERE ID_LabInfo IS NULL OR ID_Pad IS NULL
		)

		INSERT INTO [SSIS_ENG].[ref_UserHistory] (TableName, UserAction, RecordDetail, UserID, ID_Parent)
		SELECT TableName, @vUserAction, rCount, ORIGINAL_LOGIN(), @pID_Process
			FROM cteHistory
			WHERE rCount > 0

	UPDATE dbo.FracStageSummary 
		SET StartFracTime = StartFracDate  
		WHERE YEAR(StartFracTime) < 1900 AND StartFracDate IS NOT NULL

	UPDATE dbo.FracStageSummary 
		SET StartFracDate = StartFracTime
		WHERE StartFracDate is null and StartFracTime is not null

	SET NOCOUNT OFF;

END 

GO

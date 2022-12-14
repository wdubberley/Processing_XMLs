USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLOG_FilePaths]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM
  Modified:	20190202(v002)- Correct column name on SSIS.fnRPT_xmlTT_TimeLogs()
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLOG_FilePaths]()
RETURNS TABLE
AS
RETURN 
	WITH cte_Surveys_v2016 AS
		(SELECT DISTINCT eI.ID_FracInfo
			, FilePath		= xCS.FilePath
			FROM [SSIS_ENG].[xmlImport_CustomerSurveys] xCS
				INNER JOIN dbo.LOS_Wells rW ON rW.WellName = xCS.Well_Name
				LEFT JOIN dbo.FracInfo eI 
					ON eI.ID_Well	= rW.ID_Well
						AND eI.LOS_ProjectNo = CASE WHEN CHARINDEX('-', Ticket_No,1) = 0 THEN Ticket_No
												ELSE SUBSTRING(Ticket_No,CHARINDEX('-', Ticket_No,1)+1, LEN(Ticket_No)) END 
			WHERE xCS.Pad IS NULL
		)
		,cte_Surveys_v2017 AS
		(SELECT DISTINCT eI.ID_FracInfo
			, FilePath		= xCS.FilePath
			, FileDate		= xCS.FileDate
			FROM [SSIS_ENG].[xmlImport_CustomerSurveys] xCS
				INNER JOIN dbo.LOS_Wells rW ON rW.WellName = xCS.Well_Name
				LEFT JOIN dbo.FracInfo eI 
					ON eI.ID_Well	= rW.ID_Well
						AND eI.LOS_ProjectNo = CASE WHEN CHARINDEX('-', Ticket_No,1) = 0 THEN Ticket_No
												ELSE SUBSTRING(Ticket_No,CHARINDEX('-', Ticket_No,1)+1, LEN(Ticket_No)) END 
			WHERE xCS.Pad IS NOT NULL
		)
		, cteFilePaths AS
		(SELECT DISTINCT ID_Record	= ID_FracInfo
			, ReferenceTo			= 'dbo.FracInfo'
			, FilePath				= xmlFileName
			, FileDate				= xmlFileDate
			FROM [SSIS_ENG].[fnRPT_xmlTS_FracInfo] ()
			--WHERE ID_FracInfo IS NOT NULL

		UNION ALL
		SELECT DISTINCT ID_Record	= ID_Pad
			, ReferenceTo			= 'dbo.LOS_Pads'
			, FilePath				= xmlFileName			/* 20190202  */	
			, FileDate				= xmlFileDate			/* 20190202  */	
			FROM [SSIS_ENG].fnRPT_xmlTT_TimeLogs()

		UNION ALL
		SELECT DISTINCT ID_Record	= ID_FracInfo
			, ReferenceTo			= 'dbo.FracInfo'
			, FilePath				
			, FileDate				= FileDate
			FROM [SSIS_ENG].fnRPT_xmlTS_FracTickets()

		UNION ALL
		SELECT ID_Record	= ID_FracInfo
			, ReferenceTo	= 'dbo.FracInfo'
			, FilePath
			, FileDate		= NULL
			FROM cte_Surveys_v2016
		UNION ALL
		SELECT ID_Record	= ID_FracInfo
			, ReferenceTo	= 'dbo.FracInfo'
			, FilePath
			, FileDate		= FileDate
			FROM cte_Surveys_v2017
	
		UNION ALL
		SELECT DISTINCT ID_Record	= ID_MaterialInfo
			, ReferenceTo			= 'dbo.MaterialInfo'
			, FilePath				= xmlFileName
			, FileDate				= xmlDate

			FROM [SSIS_ENG].[fnRPT_xmlMAT_Info]() xM
			--WHERE ID_MaterialInfo IS NOT NULL
		UNION ALL
		SELECT DISTINCT ID_Record	= ID_ChemInventoryInfo
			, ReferenceTo			= 'dbo.Chemical_InventoryInfo'
			, FilePath				= xmlFileName
			, FileDate				= xmlDate

			FROM [SSIS_ENG].[fnRPT_xmlCHEM_Info]() xCI
			--WHERE ID_ChemInventoryInfo IS NOT NULL
		UNION ALL
		SELECT DISTINCT ID_Record	= ID_LocStrapInfo
			, ReferenceTo			= 'dbo.Location_StrapInfo'
			, FilePath				= xmlFileName
			, FileDate				= xmlDate

			FROM [SSIS_ENG].[fnRPT_xmlLCS_Info]() xCI
			--WHERE ID_LocStrapInfo IS NOT NULL
		UNION ALL
		SELECT DISTINCT ID_Record	= ID_LabInfo
			, ReferenceTo			= 'dbo.LAB_Info'
			, FilePath				= xmlFileName
			, FileDate				= xmlDate

			FROM [SSIS_ENG].[fnRPT_xmlLAB_Info]() xCI
			--WHERE ID_LabInfo IS NOT NULL
		)

	SELECT ID_Record	= ID_Record
		, TableName		= ReferenceTo
		, xmlFileName	= CASE WHEN CHARINDEX('\',REVERSE(FilePath)) = 0 THEN FilePath 
							ELSE substring(FilePath, LEN(FilePath) - CHARINDEX('\',REVERSE(FilePath)) + 2, LEN(FilePath)) END
		, xmlFileDate	= FileDate

		FROM cteFilePaths


GO

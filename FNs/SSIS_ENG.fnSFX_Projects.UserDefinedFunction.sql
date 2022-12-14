USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnSFX_Projects]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************
  Created:	KPHAM (20201210)
  20210203(v002)- Added JobTypes
  20210207(v003)- Added additional columns for AMIGO/ORBIT
  20210319(v004)- Added ID_Operator/ID_District for mapping
************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnSFX_Projects]()
RETURNS TABLE
AS
RETURN 

	SELECT DISTINCT 
		  CustomerName	= p.CustName
		, Crews			= STUFF((SELECT DISTINCT ',' + x.[CrewName] -- Add a comma (,) before each value
								FROM  [Salesforce_Data_Dump].[dbo].[tmptblAllJobs] x 
								WHERE x.TempOracleNumber = p.TempOracleNumber AND x.ProjectName = p.ProjectName
								GROUP BY x.TempOracleNumber, x.ProjectName, x.[CrewName]
							FOR XML PATH('') -- Select it as XML
							), 1, 1, '' )
		, Basin			= p.Basin_Text__c
		, ProjectStatus	= p.Project_Status__c
		, DateStart		= MIN(p.FX5__Projected_Start_Date__c)
		, DateEnd		= MAX(p.FX5__Projected_End_Date__c)
		, Direction		= ISNULL(p.FX5__Driving_Directions__c,'')
		, Latitude		= MIN(p.FX5__Latitude__c)
		, Longitude		= MIN(p.FX5__Longitude__c)
		, NumberStages	= SUM(ISNULL(p.Number_of_Stages__c, 0))
		, WellDepth		= MAX(ISNULL(p.Measured_Depth__c, 0))

		, Project	= p.TempOracleNumber
		, ProjectName	= p.ProjectName
		, HighPressure	= MAX(CONVERT(INT, p.HighPressure))
		, cQuotes		= COUNT(DISTINCT p.[QuoteName])
		, dateProject	= CONVERT(DATE, MIN(p.CreateDate))

		, rowID		= ROW_NUMBER() OVER(ORDER BY MAX(CreateDate))
		, QuoteNos	= STUFF((SELECT DISTINCT ',' + x.[QuoteName] -- Add a comma (,) before each value
								FROM  [Salesforce_Data_Dump].[dbo].[tmptblAllJobs] x 
								WHERE x.TempOracleNumber = p.TempOracleNumber AND x.ProjectName = p.ProjectName
								GROUP BY x.TempOracleNumber, x.ProjectName, x.[QuoteName]
							FOR XML PATH('') -- Select it as XML
							), 1, 1, '' )


		, TicketNos	= STUFF((SELECT DISTINCT ',' + x.[TicketNo] -- Add a comma (,) before each value
								FROM  [Salesforce_Data_Dump].[dbo].[tmptblAllJobs] x 
								WHERE x.TempOracleNumber = p.TempOracleNumber AND x.ProjectName = p.ProjectName
								GROUP BY x.TempOracleNumber, x.ProjectName, x.[TicketNo]
							FOR XML PATH('') -- Select it as XML
							), 1, 1, '' )

		, JobTypes	= STUFF((SELECT DISTINCT ',' + x.[RecordType] -- Add a comma (,) before each value
								FROM  [Salesforce_Data_Dump].[dbo].[tmptblAllJobs] x 
								WHERE x.TempOracleNumber = p.TempOracleNumber AND x.ProjectName = p.ProjectName
								GROUP BY x.TempOracleNumber, x.ProjectName, x.[RecordType]
							FOR XML PATH('') -- Select it as XML
							), 1, 1, '' )

		, ID_Operator	= ISNULL(mO.ID_Operator, 0)
		, ID_District	= ISNULL(rD.ID_District, 0)
		--, 

		FROM [Salesforce_Data_Dump].[dbo].[tmptblAllJobs]	p
			LEFT JOIN [SSIS_ENG].mapping_Customer_Operator	mO ON mO.Customer = p.CustName
			LEFT JOIN [dbo].ref_Districts					rD ON rD.SFX_Basin = p.Basin_Text__c

		WHERE ISNUMERIC(p.TempOracleNumber) = 1
			--AND TempOracleNumber IS NOT NULL

		GROUP BY p.CustName
			, ISNULL(mO.ID_Operator, 0)
			, ISNULL(rD.ID_District, 0)
			, p.Basin_Text__c
			, p.Project_Status__c
			, ISNULL(p.FX5__Driving_Directions__c,'')
			
			, p.ProjectName
			, p.TempOracleNumber
			--, HighPressure

		HAVING MAX(p.CreateDate) >= DATEADD(DD,-365,getdate())

GO

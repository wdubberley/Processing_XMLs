USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_WaterAnalysisSamples]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
  CREATED:	20180815 
  Modified:	20190415- Added SampleLocation, RunID; Modified link to fnLABInfo by ID_Pad
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_WaterAnalysisSamples]()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LabInfo	= xI.ID_LabInfo
		, SampleID		= xWA.SampleID

		, SampleLocation	= xWA.WASampleLocation
		, RunID				= xWA.WARunID

		, AnalysisType	= xWA.AnalysisType
		, AnalysisValue	= xWA.AnalysisValue
		, AnalysisUnit	= xWA.AnalysisUnit

		--, xWA.*
		, rowID		= ROW_NUMBER() OVER(ORDER BY xWA.ID_RecordNo)
		, PadName	= xI.PadName
		, PadNumber	= xWA.PadNumber
		, ID_Pad	= xI.ID_Pad
		
		FROM [SSIS_ENG].xmlImport_LAB_WaterAnalysis_SampleData	xWA
			INNER JOIN [SSIS_ENG].fnRPT_xmlLAB_Info()			xI ON xI.ID_Pad = xWA.ID_Pad

	;

GO

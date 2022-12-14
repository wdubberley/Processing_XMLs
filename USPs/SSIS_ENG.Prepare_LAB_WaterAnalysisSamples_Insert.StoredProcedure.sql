USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_WaterAnalysisSamples_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******
  Created:	20180915 (KPHAM)
  Modified:	20190415- Added SampleLocation, RunID; Remove joins to allow insert new when ID_LabInfo exists
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_WaterAnalysisSamples_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_WaterAnalysisSamples]
		([ID_LabInfo]
		,[SampleID]
		,[AnalysisType]
		,[AnalysisValue]
		,[AnalysisUnit]
		,[WASampleLocation]
		,[WARunID])

	SELECT [ID_LabInfo]		= xWA.[ID_LabInfo]
		, [SampleID]		= xWA.[SampleID]

		, [AnalysisType]	= xWA.AnalysisType
		, [AnalysisValue]	= xWA.[AnalysisValue]
		, [AnalysisUnit]	= xWA.[AnalysisUnit]

		, [SampleLocation]	= xWA.[SampleLocation]
		, [RunID]			= xWA.[RunID]
		
		FROM [SSIS_ENG].[fnRPT_xmlLAB_WaterAnalysisSamples]()	xWA
			LEFT JOIN dbo.LAB_WaterAnalysisSamples				eWA ON eWA.ID_LabInfo = xWA.ID_LabInfo AND eWA.WARunID = xWA.RunID

		WHERE xWA.ID_LabInfo IS NOT NULL
			AND eWA.ID_WaterSample IS NULL
	;

END 

GO

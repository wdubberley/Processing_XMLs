USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_CustomerSurveys]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  20190917(v002)- Removed EXEC to v2016 (no longer needed)
  20220117(v003)- Added rW.DateModified for well update; Switch call to [SSIS_ENG].[Prepare_Surveys]	
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_CustomerSurveys]	
AS
BEGIN

	DECLARE @rValue AS INT;

	/*************** OBSOLETE **************************************
	EXEC [SSIS].[Prepare_CustomerSurveys_v2016]	
	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.CustomerSurveys', 'Insert (v2016)', @rValue;
	*****************************************************************/
	
	/*** Handling newer version of Survey XMLs ****/
	--EXEC [SSIS_ENG].[Prepare_CustomerSurveys_v2017]	
	EXEC [SSIS_ENG].[Prepare_Surveys]				/* 20220117 */
	
	/***** UPDATE ID_Basin on Well if Well.ID_Basin is empty *****/
	UPDATE rW 
		SET rW.ID_Basin			= rB.ID_Basin
			, rW.DateModified	= GETDATE()
	--select *
		FROM [SSIS_ENG].xmlImport_CustomerSurveys xCS
			INNER JOIN dbo.LOS_Wells	rW ON rW.WellName = xCS.Well_Name AND rW.ID_Basin = 0
			INNER JOIN dbo.LOS_Basins	rB ON rB.Basin = xCS.Basin

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.CustomerSurveys', 'Update-ID_Basin', @rValue

END 

GO

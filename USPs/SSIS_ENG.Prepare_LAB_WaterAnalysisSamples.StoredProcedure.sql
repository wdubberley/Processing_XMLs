USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_WaterAnalysisSamples]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/******
  Created:	20180915 (KPHAM)
  Modified:	20190415- Remove update section; No longer needed
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_WaterAnalysisSamples]	
AS
BEGIN
	DECLARE @rValue AS INT = 0
		, @rTblName AS VARCHAR(100) = 'dbo.LAB_WaterAnalysisSamples'
	
	/***** REMOVE 20190415 **************************************************************
	EXEC [SSIS].[Prepare_LAB_WaterAnalysisSamples_Update]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [Liberty].[SSIS].[uspREF_History_Insert] @rTblName, 'Update', @rValue
	***********************************************************************************/

	EXEC [SSIS_ENG].[Prepare_LAB_WaterAnalysisSamples_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

END 



GO

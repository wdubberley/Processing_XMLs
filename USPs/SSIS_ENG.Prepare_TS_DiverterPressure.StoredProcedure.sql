USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_DiverterPressure]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************
  Created:	KPHAM
  20201204(v002)- Removed update USP (no longer needed)
***************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_DiverterPressure]	
AS
BEGIN

	DECLARE @rValue AS INT
		, @rTable	AS VARCHAR(100) = 'dbo.DiverterPressureAnalysis' 

	EXEC [SSIS_ENG].[Prepare_TS_DiverterPressure_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTable, 'Insert', @rValue;

	/***** REMOVED: 20201204 RECORD INSERT HISTORY 
	EXEC [SSIS_ENG].[Prepare_TS_DiverterPressure_Update]
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTable, 'Update', @rValue;
	***************************************************************************/
END 

GO

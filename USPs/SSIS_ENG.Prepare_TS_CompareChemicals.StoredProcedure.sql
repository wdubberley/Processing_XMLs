USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_CompareChemicals]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_CompareChemicals]	
AS
BEGIN

	DECLARE @rValue AS INT 
		, @rTableName	AS VARCHAR(255) = 'dbo.Comparison_Chemicals'

	EXEC [SSIS_ENG].[Prepare_TS_CompareChemicals_Update]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTableName, 'Update', @rValue;
	
	EXEC [SSIS_ENG].[Prepare_TS_CompareChemicals_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTableName, 'Insert', @rValue;
	
END 



GO

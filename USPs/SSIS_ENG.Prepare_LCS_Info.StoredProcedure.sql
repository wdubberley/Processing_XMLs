USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_Info]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_Info]	
AS
BEGIN
	DECLARE @rValue AS INT = 0
		, @rTblName AS VARCHAR(100) = 'dbo.Location_StrapInfo'
	
	EXEC [SSIS_ENG].[Prepare_LCS_Info_Update]
	/***** RECORD UPDATE HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Update', @rValue

	EXEC [SSIS_ENG].[Prepare_LCS_Info_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

END 



GO

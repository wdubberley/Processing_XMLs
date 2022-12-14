USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TT_FracTime]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************************************
  Created:	KPHAM
*****************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TT_FracTime]	
AS
BEGIN
	
	DECLARE @rValue AS INT = 0;

	EXEC [SSIS_ENG].[Prepare_TT_FracTime_Update]
	/***** RECORD INSERT HISTORY *****/
	SET @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracTime', 'Update', @rValue

	EXEC [SSIS_ENG].[Prepare_TT_FracTime_Insert]
	/***** RECORD INSERT HISTORY *****/
	SET @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracTime', 'Insert', @rValue

END 

GO

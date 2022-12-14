USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracProppant]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracProppant]	
AS
BEGIN

	DECLARE @rValue AS INT = 0;

	/**************************************************************************
	EXEC [SSIS_ENG].[Prepare_TS_FracProppant_Update]
	SELECT @rValue = @@ROWCOUNT
	
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracProppants', 'Update', @rValue;
	**************************************************************************/
	
	EXEC [SSIS_ENG].[Prepare_TS_FracProppant_Insert]
	SELECT @rValue = @@ROWCOUNT

	EXEC [SSIS_ENG].[Prepare_TS_FracProppant_Insert_ZeroCurrent]
	SELECT @rValue = @@ROWCOUNT + @rValue

	/***** RECORD INSERT HISTORY *****/
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracProppants', 'Insert', @rValue;
	
END 


GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInfo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  20200728(v002)- Added UPS call to Update-TaskNo to run before Insert
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInfo]	
AS
BEGIN
	DECLARE @rValue AS INT 

	EXEC [SSIS_ENG].[Prepare_TS_FracInfo_CorrectTicketNo]	
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInfo', 'Update-TaskNo', @rValue

	EXEC [SSIS_ENG].[Prepare_TS_FracInfo_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInfo', 'Insert', @rValue

	EXEC [SSIS_ENG].[Prepare_TS_FracInfo_Update]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInfo', 'Update', @rValue

END 

GO

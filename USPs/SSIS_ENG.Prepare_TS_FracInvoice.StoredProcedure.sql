USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInvoice]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  Created: KPHAM (20210428)
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInvoice]
AS
BEGIN 
	DECLARE @rValue AS INT 

	EXEC [SSIS_ENG].[Prepare_TS_FracInvoice_Unload]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInvoices', 'Unload', @rValue;

	EXEC [SSIS_ENG].[Prepare_TS_FracInvoice_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInvoices', 'Insert', @rValue;

	EXEC [SSIS_ENG].[Prepare_TS_FracInvoice_Items]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracInvoice_Items', 'Insert', @rValue;

	;

END

GO

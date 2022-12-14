USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracFluid]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM (2016)
  Modified:	20190204(v002)- Implemented _ZeroCurrent USP to record Fluid_volumes by Stage Version
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracFluid]	
AS
BEGIN

	DECLARE @rValue AS INT = 0

	/**************************************************************************
	EXEC [SSIS_ENG].[Prepare_TS_FracFluid_Update]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracFluids', 'Update', @rValue;
	**************************************************************************/
	
	EXEC [SSIS_ENG].[Prepare_TS_FracFluid_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	
	EXEC [SSIS_ENG].[Prepare_TS_FracFluid_Insert_ZeroCurrent]
	SELECT @rValue = @@ROWCOUNT + @rValue

	/***** RECORD INSERT HISTORY *****/
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracFluids', 'Insert', @rValue;
	
END 

GO

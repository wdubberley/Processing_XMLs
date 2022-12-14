USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracChem]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  20190510- Removed UPDATE section (No longer needed)
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracChem]	
AS
BEGIN

	DECLARE @rValue AS INT 

	/********** remove 20190510 ****************************
	EXEC [SSIS_ENG].[Prepare_TS_FracChem_Update]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracChemicals', 'Update', @rValue;
	********************************************************/
	
	EXEC [SSIS_ENG].[Prepare_TS_FracChem_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT,0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracChemicals', 'Insert', @rValue;
	
END 


GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_FuelBOLs]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20201030)
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_FuelBOLs]	
AS
BEGIN

	DECLARE @rValue AS INT 

	EXEC [SSIS_ENG].[Prepare_MAT_FuelBOL_Update]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Material_FuelBOLs', 'Update', @rValue;
	
	EXEC [SSIS_ENG].[Prepare_MAT_FuelBOL_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Material_FuelBOLs', 'Insert', @rValue;
	
END 

GO

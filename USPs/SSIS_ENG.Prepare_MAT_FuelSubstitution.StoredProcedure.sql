USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_FuelSubstitution]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20210421)
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_FuelSubstitution]	
AS
BEGIN

	DECLARE @rValue AS INT 

	EXEC [SSIS_ENG].[Prepare_MAT_FuelSubstitution_UPDATE]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Material_FuelSubstitution', 'Update', @rValue;
	
	EXEC [SSIS_ENG].[Prepare_MAT_FuelSubstitution_INSERT]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Material_FuelSubstitution', 'Insert', @rValue;
	
END 

GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracChemSP]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM (20190117)
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracChemSP]	
AS
BEGIN

	DECLARE @rValue AS INT 
	
	EXEC [SSIS_ENG].[Prepare_TS_FracChemSP_Insert]

	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT,0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracChemSP', 'Insert', @rValue;
	
END 


GO

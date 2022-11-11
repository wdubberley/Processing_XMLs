USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_TECHStudy]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  Created:	20200325 (KPHAM)
******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_TECHStudy]	
AS
BEGIN

	DECLARE @rValue AS INT 

	EXEC [SSIS_ENG].[Prepare_TS_TECHStudy_Insert]

	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.TechSheet_TECHStudy', 'Insert', @rValue;
	
END 



GO

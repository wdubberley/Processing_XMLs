USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM
  Modified:	20190416- Remove UPDATE section (no longer needed)
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data]	
AS
BEGIN
	DECLARE @rValue AS INT = 0
		, @rTblName AS VARCHAR(100) = 'dbo.LAB_ChandlerTest_TestData'
	
	/*****
	EXEC [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data_Update]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [Liberty].[SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Update', @rValue
	*****/

	EXEC [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

END 


GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_TestSpecs]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************
  Create:	20190423 (KPHAM)
********************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_TestSpecs]	
AS
BEGIN
	DECLARE @rValue AS INT = 0
		, @rTblName AS VARCHAR(100) = 'dbo.LAB_HydrationTest_TestSpecs'

	/***** HYDRATION TEST *****/
	EXEC [SSIS_ENG].[Prepare_LAB_HydrationTest_TestSpecs_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** CHANDLER TEST *****/
	SET @rTblName = 'dbo.LAB_ChandlerTest_TestSpecs'
	EXEC [SSIS_ENG].[Prepare_LAB_ChandlerTest_TestSpecs_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** FLOWLOOP TEST *****/
	SET @rTblName = 'dbo.LAB_FlowLoop_TestSpecs'
	EXEC [SSIS_ENG].[Prepare_LAB_FlowLoop_TestSpecs_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** FLOWLOOP TEST *****/
	SET @rTblName = 'dbo.LAB_ShearStress_TestSpecs'
	EXEC [SSIS_ENG].[Prepare_LAB_ShearStress_TestSpecs_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

END 

GO

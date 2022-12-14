USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_TestData]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************
  Created:	20180423 (KPHAM)
****************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_TestData]	
AS
BEGIN
	DECLARE @rValue AS INT = 0
		, @rTblName AS VARCHAR(100) = 'dbo.LAB_HydrationTest_TestData'

	/***** HYDRATION TEST *****/
	EXEC [SSIS_ENG].[Prepare_LAB_HydrationTest_Data_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** CHANDLER TEST *****/
	SET @rTblName = 'dbo.LAB_ChandlerTest_TestData'
	EXEC [SSIS_ENG].[Prepare_LAB_ChandlerTest_Data_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** FLOWLOOP TEST *****/
	SET @rTblName = 'dbo.LAB_FlowLoop_TestData'
	EXEC [SSIS_ENG].[Prepare_LAB_FlowLoop_Data_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** SHEARSTRESS TEST *****/
	SET @rTblName = 'dbo.LAB_ShearStress_ViscData'
	EXEC [SSIS_ENG].[Prepare_LAB_ShearStress_ViscData_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** OSCILLATING RHEOMETER TEST *****/
	SET @rTblName = 'dbo.LAB_OscillatingRheometer_TestData'
	EXEC [SSIS_ENG].[Prepare_LAB_OscillatingRheometer_Data_Insert]	
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

END 

GO

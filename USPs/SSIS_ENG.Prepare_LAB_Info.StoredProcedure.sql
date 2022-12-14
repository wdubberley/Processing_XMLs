USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_Info]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************************************************
  Created:	20180914 (KPHAM)
  20190415- Added Unload section; Removed Update section (no longer needed to record previous version)
  20190423- Added LAB_WellInfo section
**********************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_Info]	
AS
BEGIN
	
	DECLARE @rValue AS INT = 0
		, @rTblName AS VARCHAR(100) = 'dbo.LAB_Info'
	
	/***** UNLOAD previous version of LAB_Info *****/
	EXEC [SSIS_ENG].[Prepare_LAB_Info_Unload]	
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Unload', @rValue

	/***** INSERT new version of LAB_Info *****/
	EXEC [SSIS_ENG].[Prepare_LAB_Info_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

	/***** INSERT LAB_WellInfo *****/
	SET @rTblName = 'dbo.LAB_WellInfo'

	EXEC [SSIS_ENG].[Prepare_LAB_WellInfo]	
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTblName, 'Insert', @rValue

END 

GO

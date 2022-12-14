USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_Process_SSIS_Cleanup]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM (20180910)
  Desc:		
  Modified:	20190215- Added UPS to Insert/Correct Lapsed records in SSIS.xmlImport_TT_TimeLogs
******/
CREATE PROCEDURE [SSIS_ENG].[PRE_Process_SSIS_Cleanup]	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @rValue AS INT = 0

	/*** TT_TimeLogs insert/correct Lapsed records (20190215) ******/
	EXEC [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Lapsed_Insert]
	SET @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.xmlImport_TT_TimeLogs', 'Insert/Update', @rValue
	
	
	/*** TT_TimeLogs update miscellaneous (20180910) ******/
	UPDATE [SSIS_ENG].xmlImport_TT_TimeLogs SET [Time]='NP' WHERE [Time] IS NULL
	SET @rValue = ISNULL(@@ROWCOUNT, 0)

	EXEC [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Update]
	SET @rValue = @rValue + ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.xmlImport_TT_TimeLogs', 'Update', @rValue

	/*** TT_TimeLogs update (20181218) specific for pad 100893; ONLY ON SQL01 ******/
	EXEC [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Update_p100893]

	/*** TS update miscellaneous (20180910) ******/
	EXEC [SSIS_ENG].[PRE_Process_XMLs_FracStages_Update]	
	SET @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.xmlImport_TS_FracStages', 'Update', @rValue

	/******* obsolete (20180910) **************************************************************************
	UPDATE [SSIS_ENG].xmlImport_TS_ChargesProppants
		SET proppant_Desc = Proppant_Name 
		WHERE Proppant_Name = '100 MESH (first 2 million lbs price)'

	SET @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.xmlImport_TS_ChargesProppants', 'Update', @rValue
	***********************************************************************************************************/

	/*** CHEM_BOL_Time update (20180831) ******/
	EXEC [SSIS_ENG].[Prepare_xmlCHEM_BOLs_Update]		
	SET @rValue = ISNULL(@@ROWCOUNT,0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'SSIS_ENG.xmlImport_CHEM_BOLs', 'Update', @rValue

	SET NOCOUNT OFF;

END 

GO

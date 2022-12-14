USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_FlowLoop_TestSpecs_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM
  Modified:	20190416- Added new columns; Re-order columns to match schema; moved obsolete columns to the end
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_FlowLoop_TestSpecs_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_FlowLoop_TestSpecs]
        ([ID_LabInfo]
        ,[TestNumber],[countData])

	SELECT [ID_LabInfo]	= xF.[ID_LabInfo]

		, [TestNumber]	= xF.[TestNumber]
		, [countData]	= xF.[countData]
		
		FROM [SSIS_ENG].[fnRPT_xmlLAB_FlowLoop_TestSpecs]()	xF
			LEFT JOIN dbo.[LAB_FlowLoop_TestSpecs]		sF ON sF.ID_LabInfo = xF.ID_LabInfo AND sF.TestNumber = xF.TestNumber 

		WHERE xF.ID_LabInfo IS NOT NULL 
			AND sF.ID_TestInfo IS NULL

	;

END 



GO

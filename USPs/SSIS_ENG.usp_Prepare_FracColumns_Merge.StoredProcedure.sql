USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[usp_Prepare_FracColumns_Merge]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[usp_Prepare_FracColumns_Merge]
AS
/***********************************************************
	20171115- MERGING input column data with TechSheet_Columns
	20180216- Eliminating non-existing ID_FracInfo
************************************************************/
BEGIN

	SET NOCOUNT ON;

	UPDATE xC SET xC.ID_FracInfo = xFI.ID_FracInfo
		FROM [SSIS_ENG].[xmlImport_TS_FracStages_Columns] xC
			INNER JOIN [SSIS_ENG].[fnRPT_xmlTS_FracInfo]() xFI 
				ON xFI.WellName = xC.WellName AND xFI.TaskNo = xC.TicketNo AND xFI.ID_FracInfo IS NOT NULL;									
	
	DECLARE @rValue AS INT 

	MERGE dbo.TechSheet_InputColumns AS tsI
		USING [SSIS_ENG].[xmlImport_TS_FracStages_Columns] AS xC
		ON (tsI.ID_FracInfo = xC.ID_FracInfo AND tsI.[col_No] = xC.rowNo)

		WHEN MATCHED THEN
			UPDATE SET tsI.[col_Name]		= xC.[col_Name]
				
		WHEN NOT MATCHED AND xC.ID_FracInfo IS NOT NULL THEN							/*20180216*/
			INSERT ([ID_FracInfo], [col_No], [col_Name], [xmlFileName])
			VALUES (xC.[ID_FracInfo], xC.[rowNo], xC.[col_Name], xC.[xmlFileName])

		--WHEN NOT MATCHED BY SOURCE THEN
		--	DELETE
	; /* END MERGE Stmt */

	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.TechSheet_InputColumns', 'Update', @rValue

	SET NOCOUNT OFF;

END

GO

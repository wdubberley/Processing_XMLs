USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Process_XMLs_Logs]    Script Date: 8/24/2022 11:08:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Process_XMLs_Logs]	

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @pID_Process	AS INT = SSIS_ENG.fnSSIS_GetProcess_START()
		, @pDateStart	AS DATETIME
		, @pDateEnd		AS DATETIME
		, @vLoginName	AS VARCHAR(255)		= NULL
		
		--, @uID_Process AS UNIQUEIDENTIFIER = NEWID()
		--, DateModified	AS DATETIME = GETDATE()

	SET @vLoginName = ISNULL(@vLoginName, 'SSIS')
		
	/***** ADD record for History.tbl_ProcessLogs ******/
	SET @pDateStart	= (SELECT DateModified FROM SSIS_ENG.ref_UserHistory WHERE ID_Record = @pID_Process)
	SET @pDateEnd	= (SELECT TOP 1 DateModified FROM SSIS_ENG.ref_UserHistory WHERE ID_Parent = @pID_Process AND RecordDetail = 'END - SSIS' ORDER BY ID_Record DESC)
		
	INSERT INTO History.tbl_ProcessLogs (DateStart, DateEnd, ID_Process)
		SELECT @pDateStart, @pDateEnd, @pID_Process
	
	/**** UPDATE status for imported files *******/
	UPDATE tF 
		SET tF.Progress_Status  = 3
			, tF.DateApprove	= @pDateEnd
			, tF.ApproveBy		= @vLoginName
	--SELECT *
		FROM [SSIS_ENG].[fnRPT_xmlLOG_FilePaths]() xP
			INNER JOIN [SSIS_ENG].tbl_xmlFiles xF ON xF.xmlFileName = xP.xmlFileName 
			INNER JOIN [History].tbl_xmlFiles tF ON tF.xmlFileName = xF.xmlFileName AND tF.Progress_Status IN (2) AND tF.ID_Process = @pID_Process

		WHERE xP.ID_Record IS NOT NULL

	/**** LOG SUCCESSFUL FILES HERE ***/
	EXEC [SSIS_ENG].[Process_XMLs_FileLogs_Detail] @pID_Process

	SET NOCOUNT OFF;

END 

GO

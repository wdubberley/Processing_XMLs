USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Process_XMLs_FileLogs_Detail]    Script Date: 8/24/2022 11:08:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************
  Created: KPHAM (2018)
  20190703(v002)- Added ID_FileType
******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Process_XMLs_FileLogs_Detail]	
	 @pID_Process	INT 
AS
BEGIN
	SET NOCOUNT ON;

	/*** TEST parameters 
	DECLARE @pID_Process	INT = 99381
	--****************************************************/
	SET @pID_Process = ISNULL(@pID_Process, 0);

	INSERT INTO [SSIS_ENG].[xmlImport_FileLogs] (ID_Record, TableName, xmlFileName, xmlFileDate, xmlFileSize, ID_Process, ID_FileType)
	SELECT ID_Record
		, TableName		= cP.TableName
		, xmlFileName	= cP.xmlFileName
		, xmlFileDate	= cP.xmlFileDate
		, xmlFileSize	= xH.xmlFileSize

		, ID_Process	= @pID_Process
		, ID_FileType	= xH.ID_FileCategory			/* 20190703 */

		FROM [SSIS_ENG].[fnRPT_xmlLOG_FilePaths]()	cP
			INNER JOIN History.tbl_xmlFiles			xH ON xH.xmlFileName = cP.xmlFileName AND xH.ID_Process = @pID_Process
		WHERE ID_Record IS NOT NULL

	SET NOCOUNT OFF;

END 

GO

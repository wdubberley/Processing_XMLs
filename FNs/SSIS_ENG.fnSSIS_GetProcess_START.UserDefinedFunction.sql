USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnSSIS_GetProcess_START]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [SSIS_ENG].[fnSSIS_GetProcess_START]()
RETURNS INT
AS
BEGIN

	DECLARE @pID_Process AS INT = 0 -- output 

	SELECT TOP 1 @pID_Process = ID_Record
		FROM [SSIS_ENG].[ref_UserHistory]
		WHERE TableName		= 'SSIS_ENG.ref_UserHistory' 
			AND UserAction	= 'Processing XMLs' 
			AND RecordDetail = 'START - SSIS' 
			AND ID_Parent	= 0
		ORDER BY ID_Record DESC

	RETURN @pID_Process

END

GO

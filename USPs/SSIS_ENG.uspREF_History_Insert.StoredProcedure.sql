USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[uspREF_History_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*============================================================
	Created:	KPHAM
	Modified:	20180712- Added ID_Process/ID_Parent
==============================================================*/
CREATE PROCEDURE [SSIS_ENG].[uspREF_History_Insert]
	@vTableName VARCHAR(50),
	@vUserAction Varchar(50), 
	@vDetail Varchar(MAX)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @pID_Process	AS INT = 0
	IF @vDetail <> 'START - SSIS'
		SELECT @pID_Process = [SSIS_ENG].[fnSSIS_GetProcess_START]()
	;
	
	INSERT INTO SSIS_ENG.ref_UserHistory (TableName, UserAction, RecordDetail, UserID, ID_Parent)
	VALUES (@vTableName, @vUserAction, @vDetail, ORIGINAL_LOGIN(), @pID_Process)
	
	SET NOCOUNT OFF;

END 



GO

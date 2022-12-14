USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATInfo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_MATInfo]	
AS
BEGIN
	DECLARE @rValue AS INT = 0
		, @rTable	AS VARCHAR(100) = 'dbo.MAT_Info'
	
	EXEC [SSIS_ENG].[Prepare_MATInfo_Update]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTable, 'Update', @rValue

	EXEC [SSIS_ENG].[Prepare_MATInfo_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @rTable, 'Insert', @rValue

END 

GO

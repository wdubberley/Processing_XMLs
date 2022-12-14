USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATSandInfo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************
  20191028(v002)- Clean up code
*************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATSandInfo]	
AS
BEGIN

	SET ANSI_WARNINGS OFF;

	DECLARE @rValue AS INT = 0
		, @tblName	AS VARCHAR(255) = 'dbo.Material_SandInfo'

	/***** Update Existing SandInfo *****/
	EXEC [SSIS_ENG].[Prepare_MATSandInfo_Update]
	
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @tblName, 'Update', @rValue;
	
	/***** Inserting new SandInfo *****/
	EXEC [SSIS_ENG].[Prepare_MATSandInfo_Insert]
	
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] @tblName, 'Insert', @rValue;

	SET ANSI_WARNINGS ON;
	
END 

GO

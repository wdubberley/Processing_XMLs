USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_BOLDetail]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************
  20191028(v002)- Clean up code
  20210104(v003)- Update code to change naming convention to MAT_
******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_BOLDetail]	
AS
BEGIN

	DECLARE @rValue AS INT = 0
		, @tblName	AS VARCHAR(255) = 'dbo.Material_BOLDetails'

	/***** Update Existing BOLs *****/
	EXEC [SSIS_ENG].[Prepare_MAT_BOLDetail_Update]

	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @tblName, 'Update', @rValue;
	
	/***** Insert new BOLs *****/
	EXEC [SSIS_ENG].[Prepare_MAT_BOLDetail_Insert]
	
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @tblName, 'Insert', @rValue;

END 

GO

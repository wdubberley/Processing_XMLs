USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATWellInfo]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_MATWellInfo]	
AS
BEGIN

	DECLARE @rValue AS INT 

	--EXEC [SSIS].[Prepare_MATSandInfo_Update]
	--/***** RECORD INSERT HISTORY *****/
	--SELECT @rValue = @@ROWCOUNT
	--IF @rValue > 0 
	--	EXEC [SSIS].[uspREF_History_Insert] 'SupplyChain.Material_SandInfo', 'Update', @rValue;
	
	EXEC [SSIS_ENG].[Prepare_MATWellInfo_Insert]
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Material_WellInfo', 'Insert', @rValue;
	
END 



GO

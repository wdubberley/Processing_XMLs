USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeService]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Modified:	20190305(v004)- Clean up code; Changed secondpass USP name
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeService]	
AS
BEGIN

	DECLARE @rValue AS INT 

	/******************************************************************************************
	EXEC [SSIS_ENG].[Prepare_ChargeService_Update]	
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Charge_Services', 'Update', @rValue;
	******************************************************************************************/

	/* first pass */
	EXEC [SSIS_ENG].[Prepare_TS_ChargeService_Insert]	
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)

	/* second pass; insert chem charges that did not exist in current version but exist in previous version */
	EXEC [SSIS_ENG].[Prepare_TS_ChargeService_Insert_ZeroCurrent]	
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0) + @rValue
	
	/***** RECORD INSERT HISTORY *****/
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Charge_Services', 'Insert', @rValue;
	
END 

GO

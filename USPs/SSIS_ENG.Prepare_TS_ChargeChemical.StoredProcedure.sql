USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeChemical]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
 Modified:	20181212- Remove USP for Update
			20190301(v002)- Clean up code; Changed secondpass USP name
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeChemical]	
AS
BEGIN

	DECLARE @rValue AS INT 

	/***** 20181212 ***************************************************
	EXEC [SSIS_ENG].[Prepare_ChargeChemical_Update]	
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Charge_Chemicals', 'Update', @rValue;
	*******************************************************************/
	
	/* first pass */
	EXECUTE [SSIS_ENG].[Prepare_TS_ChargeChemical_Insert]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	
	/* second pass; insert chem charges that did not exist in current version but exist in previous version */
	EXECUTE [SSIS_ENG].[Prepare_TS_ChargeChemical_Insert_ZeroCurrent] 
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0) + @rValue
	
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Charge_Chemicals', 'Insert', @rValue;
	
END 

GO

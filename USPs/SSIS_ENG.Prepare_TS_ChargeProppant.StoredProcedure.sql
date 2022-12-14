USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeProppant]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Modified:	20190301(v002)- Clean up code; Changed secondpass USP name
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeProppant]	
AS
BEGIN

	DECLARE @rValue AS INT = 0;
	
	/*******************************************************************
	EXEC [SSIS_ENG].[Prepare_ChargeProppant_Update]	
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Charge_Proppants', 'Update', @rValue;
	*******************************************************************/

	/* first pass */
	EXEC [SSIS_ENG].[Prepare_TS_ChargeProppant_Insert]	
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0)
	
	/* second pass; insert chem charges that did not exist in current version but exist in previous version */
	EXEC [SSIS_ENG].[Prepare_TS_ChargeProppant_Insert_ZeroCurrent]
	SELECT @rValue = ISNULL(@@ROWCOUNT, 0) + @rValue
	
	/***** RECORD INSERT HISTORY *****/
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.Charge_Proppants', 'Insert', @rValue;
	
END 

GO

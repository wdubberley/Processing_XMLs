USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_QuoteItem_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************************************
  20220117(v004)- Added DateModified
  20220513(v005)- Added Bonus_Eligible
************************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_QuoteItem_Update]	
AS
BEGIN

	DECLARE @rValue AS INT = 0;

	UPDATE eQ
		SET eQ.QuoteDate			= xQ.QuoteDate
			, eQ.ID_ChargeType		= xQ.ID_ChargeType
			, eQ.ChargeDescription	= xQ.ChargeDescription
			, eQ.ChargeCode			= xQ.ChargeCode
			, eQ.ChargeQty			= xQ.ChargeQty
			, eQ.ChargeUnitPrice	= xQ.ChargeUnitPrice
			, eQ.ChargeUnit			= xQ.ChargeUnit
			, eQ.Discount			= xQ.Discount
			, eQ.WellTotal			= xQ.WellTotal
			, eQ.IsPassthrough		= CASE WHEN xQ.IsPassthrough IN (66,67) THEN 1 ELSE 0 END
			, eQ.ID_ChargeOption	= CASE WHEN xQ.IsPassthrough IN (66) THEN 67 ELSE xQ.IsPassthrough END
	
			, eQ.AlternateName		= xQ.AlternateName
			, eQ.ClientProvided		= xQ.ClientProvided
			, eQ.Bonus_Eligible		= xQ.Bonus_Eligible								/* 20220513 */

			, eQ.DateModified		= GETDATE()										/* 20220117 */
		
	/**** 
	select ID_FracInfo			= xQ.ID_FracInfo
		, TicketDate			= xQ.QuoteDate
		, SequenceNo			= xQ.SequenceNo
		, ID_ChargeType			= xQ.ID_ChargeType
		, ChargeDescription		= xQ.ChargeDescription
		, ChargeCode			= xQ.ChargeCode
		, ChargeQty				= xQ.ChargeQty
		, ChargeUnitPrice		= xQ.ChargeUnitPrice
		, ChargeUnit			= xQ.ChargeUnit
		, WellTotal				= xQ.WellTotal
		, IsPassthrough			= CASE WHEN xQ.IsPassthrough IN (66,67) THEN 1 ELSE 0 END
		, ID_ChargeOption		= CASE WHEN xQ.IsPassthrough IN (66) THEN 67 ELSE xQ.IsPassthrough END
		, AlternateName			= xQ.AlternateName
	--****/

		FROM [SSIS_ENG].fnRPT_xmlTS_FracQuotes()	xQ
			INNER JOIN dbo.FieldQuote_Items			eQ ON eQ.ID_FracInfo = xQ.ID_FracInfo AND eQ.SequenceNo = xQ.SequenceNo

		--WHERE xQ.ID_FracInfo = 9042--9035

	SET @rValue = ISNULL(@@ROWCOUNT, 0)

	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FieldQuote_Items', 'Update', @rValue;
	
	;
	
END 

GO

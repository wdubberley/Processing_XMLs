USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_QuoteItem_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  20200211(v004)- Added statement to record rows affected
  20220513(v005)- Added Bonus_Eligible
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_QuoteItem_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT 

	INSERT INTO dbo.FieldQuote_Items
		(ID_FracInfo
		, QuoteDate
		, SequenceNo
		, ID_ChargeType
		, ChargeDescription
		, ChargeCode
		, ChargeQty
		, ChargeUnitPrice
		, ChargeUnit
		, Discount
		, WellTotal
		, IsPassthrough
		, ID_ChargeOption
		, AlternateName
		, ClientProvided
		, Bonus_Eligible
		)

	SELECT ID_FracInfo			= xQ.ID_FracInfo
		, QuoteDate				= xQ.QuoteDate
		, SequenceNo			= xQ.SequenceNo
		, ID_ChargeType			= xQ.ID_ChargeType
		, ChargeDescription		= xQ.ChargeDescription
		, ChargeCode			= xQ.ChargeCode
		, ChargeQty				= xQ.ChargeQty
		, ChargeUnitPrice		= xQ.ChargeUnitPrice
		, ChargeUnit			= xQ.ChargeUnit
		, Discount				= xQ.Discount
		, WellTotal				= xQ.WellTotal
		, IsPassthrough			= CASE WHEN xQ.IsPassthrough IN (66,67) THEN 1 ELSE 0 END
		, ID_ChargeOption		= CASE WHEN xQ.IsPassthrough IN (66) THEN 67 ELSE xQ.IsPassthrough END

		, AlternateName		= xQ.AlternateName
		, ClientProvided	= xQ.ClientProvided
		, Bonus_Eligible	= xQ.Bonus_Eligible								/* 20220513 */

		FROM [SSIS_ENG].fnRPT_xmlTS_FracQuotes()	xQ
			LEFT JOIN dbo.FieldQuote_Items		eQ ON eQ.ID_FracInfo = xQ.ID_FracInfo AND eQ.SequenceNo = xQ.SequenceNo
			
		WHERE eQ.ID_QuoteItem IS NULL

		ORDER BY xQ.ID_FracInfo
			, xQ.SequenceNo

	SET @rValue = ISNULL(@@ROWCOUNT, 0)

	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FieldQuote_Items', 'Insert', @rValue;
	;

END 

GO

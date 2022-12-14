USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TQ_TicketItem_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************
 Created:	KPHAM
 20220513(v002)- Added Bonus_Eligible
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TQ_TicketItem_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT 

	INSERT INTO dbo.FieldTicket_Items
		(ID_FracInfo
		, TicketDate
		, SequenceNo
		, ID_ChargeType
		, ChargeDescription
		, ChargeCode
		, ChargeQty
		, ChargeUnitPrice
		, ChargeUnit
		, Discount
		, WellTotal
		, TotalWellsOnPad 
		, TotalStagesPlanned
		, TotalStagesCompleted
		, IsPassthrough
		, ID_ChargeOption
		, Bonus_Eligible
	)

	SELECT ID_FracInfo			= xT.ID_FracInfo
		, TicketDate			= xT.TicketDate
		, SequenceNo			= xT.SequenceNo
		, ID_ChargeType			= rType.ID_Record
		, ChargeDescription		= xT.ChargeDescription
		, ChargeCode			= xT.ChargeCode
		, ChargeQty				= xT.ChargeQty
		, ChargeUnitPrice		= xT.ChargeUnitPrice
		, ChargeUnit			= xT.ChargeUnit
		, Discount				= xT.Discount
		, WellTotal				= xT.WellTotal

		, TotalWellsOnPad		= xT.TotalWellsOnPad
		, TotalStagesPlanned	= xT.TotalStagesPlanned
		, TotalStagesCompleted	= xT.TotalStagesCompleted

		, IsPassthrough			= CASE WHEN xT.IsPassthrough IN (66,67) THEN 1 ELSE 0 END
		, ID_ChargeOption		= CASE WHEN xT.IsPassthrough IN (66) THEN 67 ELSE xT.IsPassthrough END

		, Bonus_Eligible		= xT.Bonus_Eligible									/* 20220513 */

		--, xT.ChargeType

		FROM SSIS_ENG.fnRPT_xmlTS_FracTickets() xT
			INNER JOIN dbo.ref_Categories rType ON rType.ID_Parent = 22 AND rType.ItemName = xT.ChargeType
			LEFT JOIN dbo.FieldTicket_Items eT 
				ON eT.ID_FracInfo = xT.ID_FracInfo AND eT.SequenceNo=xT.SequenceNo
					--AND eT.ID_ChargeType=rType.ID_Record AND eT.ChargeCode=xT.ChargeCode 
			
		WHERE eT.ID_TicketItem IS NULL 

		ORDER BY xT.ID_FracInfo
			, xT.SequenceNo

	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FieldTicket_Items', 'Insert', @rValue;
	;

END 
GO

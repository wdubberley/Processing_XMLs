USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TQ_TicketItem_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************
 Created:	KPHAM
 20220118(v002)- Added DateModified
 20220513(v005)- Added Bonus_Eligible
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TQ_TicketItem_Update]	
AS
BEGIN

	DECLARE @rValue AS INT = 0

	UPDATE eT
		SET eT.TicketDate			= xT.TicketDate
			, eT.ID_ChargeType		= rType.ID_Record
			, eT.ChargeDescription	= xT.ChargeDescription
			, eT.ChargeCode			= xT.ChargeCode
			, eT.ChargeQty			= xT.ChargeQty
			, eT.ChargeUnitPrice	= xT.ChargeUnitPrice
			, eT.ChargeUnit			= xT.ChargeUnit
			, eT.Discount			= xT.Discount
			, eT.WellTotal			= xT.WellTotal

			, eT.TotalWellsOnPad		= xT.TotalWellsOnPad
			, eT.TotalStagesPlanned		= xT.TotalStagesPlanned
			, eT.TotalStagesCompleted	= xT.TotalStagesCompleted

			, eT.IsPassthrough		= CASE WHEN xT.IsPassthrough IN (66,67) THEN 1 ELSE 0 END
			, eT.ID_ChargeOption	= CASE WHEN xT.IsPassthrough IN (66) THEN 67 ELSE xT.IsPassthrough END
			, eT.Bonus_Eligible		= xT.Bonus_Eligible								/* 20220513 */
			, eT.DateModified	= GETDATE()
		
	--select *

		FROM SSIS_ENG.fnRPT_xmlTS_FracTickets() xT
			INNER JOIN dbo.ref_Categories rType ON rType.ID_Parent = 22 AND rType.ItemName = xT.ChargeType
			INNER JOIN dbo.FieldTicket_Items eT 
				ON eT.ID_FracInfo = xT.ID_FracInfo AND eT.SequenceNo=xT.SequenceNo
			
		--WHERE xT.ID_FracInfo = 9042

	SET @rValue = @@ROWCOUNT

	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FieldTicket_Items', 'Update', @rValue;
	
	;

END 

GO

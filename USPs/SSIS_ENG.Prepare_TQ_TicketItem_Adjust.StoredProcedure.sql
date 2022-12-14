USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TQ_TicketItem_Adjust]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
 Created:	KPHAM (20200212)
 20201120(v002)- Correct delete line to map to the correct table
				- Limit validation for duplication only to Totals section (ID_ChargeType = 26)
 20220118(v003)- Added DateModified
 20220513(v005)- Added Bonus_Eligible
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TQ_TicketItem_Adjust]
AS
BEGIN
	
	DECLARE @tblTQ_TicketItems TABLE (
		[ID_TicketItem]	[INT] NOT NULL,
		[ID_FracInfo]	[INT] NOT NULL,
		[TicketDate]	[SMALLDATETIME] NOT NULL,
		[ID_ChargeType] [INT] NOT NULL,
		[SequenceNo]	[INT] NOT NULL,
		[ChargeDesc]	[VARCHAR](255) NULL,
		[ChargeCode]	[VARCHAR](50) NULL,	
		[ChargeQty]		[FLOAT] NULL,	
		[ChargeUnitPrice]	[FLOAT] NULL,	
		[ChargeUnit]		[VARCHAR](50) NULL,
		[Discount]			[FLOAT] NULL,	
		[WellTotal]			[FLOAT] NULL,	
		[TotalWellsOnPad]		[INT] NULL,
		[TotalStagesPlanned]	[INT] NULL,
		[TotalStagesCompleted]	[INT] NULL,
		[IsPassthrough]		[BIT] NOT NULL,
		[ID_ChargeOption]	[INT] NOT NULL,
		[DateModified]		[DATETIME] NOT NULL,
		[Bonus_Eligible]	[BIT] NOT NULL,
		[rRank]				[INT]
	)

	;WITH cte_dT As
		(SELECT DISTINCT ID_FracInfo, ChargeDescription, ChargeCode, cRecords = count(*)  /* Last count : 9 (11213) */
			, rID = ROW_NUMBER() OVER(ORDER BY ID_FracInfo)
			FROM dbo.FieldTicket_Items
			WHERE ID_ChargeOption = 26		-- ONLY Check Total section
				AND ID_FracInfo > 11213 --and ID_FracInfo = 12167
			GROUP BY ID_FracInfo, ChargeDescription, ChargeCode
			HAVING COUNT(*) > 1
			----order by id_fracinfo
		)
		, cte_rDups AS
		(SELECT iT.*
			, rRank = RANK() OVER(PARTITION BY iT.ID_FracInfo, iT.ChargeDescription ORDER BY iT.ID_FracInfo, iT.ID_TicketItem)
			FROM cte_dT	t
				INNER JOIN dbo.FieldTicket_Items	iT ON iT.ID_FracInfo = t.ID_FracInfo 
														AND iT.ChargeDescription = t.ChargeDescription 
														--AND t.ChargeCode = iQ.ChargeCode

		)
	
	INSERT INTO @tblTQ_TicketItems
	SELECT * 
		FROM cte_rDups t
		WHERE rRank > 1

	--select * from @tblTQ_TicketItems

	DECLARE @rDate	AS DATETIME		= GETDATE()
		, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
		, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TQ_TicketItems_Adjust]'	--This procedure's name
		, @rParams	AS VARCHAR(Max) = 'Remove extra lines ON dbo.FieldTicket_Items'	-- Description/etc.
		, @uRecords AS INT = 0
		, @rXML		AS XML 

	IF (SELECT COUNT(*) FROM @tblTQ_TicketItems) > 0
	BEGIN
		--select ChargeCode from dbo.Charge_Chemicals

		SET @uRecords = (SELECT COUNT(*) FROM @tblTQ_TicketItems)

		SET @rParams = REPLACE(@rParams, 'Remove', 'Remove ' + CONVERT(VARCHAR(10),@uRecords))

		SET @rXML = (SELECT [ID_TicketItem], [ID_FracInfo], [TicketDate], [ID_ChargeType]
							, [SequenceNo], [ChargeDesc], [ChargeCode]
							, [ChargeQty] = CONVERT(DECIMAL(16,8),[ChargeQty])
							, [ChargeUnitPrice] = CONVERT(DECIMAL(16,8),[ChargeUnitPrice])
							, [ChargeUnit]
							, [Discount] = CONVERT(DECIMAL(16,8),[Discount])
							, [WellTotal], [TotalWellsOnPad], [TotalStagesPlanned], [TotalStagesCompleted]
							, [IsPassthrough], [ID_ChargeOption], [rRank]
							, [DateModified]= GETDATE()
					FROM @tblTQ_TicketItems t 

					FOR XML PATH ('TicketItem'), ROOT('FieldTickets'))
	END

	IF @rXML IS NOT NULL 
	BEGIN
		/*** TEST SELECT 
		select @uRecords, @rParams, @rXML
		select * 
			from @tblTQ_TicketItems t INNER JOIN dbo.FieldTicket_Items d  ON d.[ID_TicketItem] = t.[ID_TicketItem]
		--**************************************/
		
		EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

		IF @uRecords > 0
		BEGIN
			DECLARE @rValue AS INT = 0;

			DELETE FROM iQ
			--select * 
				FROM @tblTQ_TicketItems t
					INNER JOIN dbo.FieldTicket_Items iQ ON iQ.ID_TicketItem = t.ID_TicketItem

			SET @rValue = ISNULL(@@ROWCOUNT, 0)

			IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FieldTicket_Items', 'Delete', @rValue;
		END
	END

END -- end usp
GO

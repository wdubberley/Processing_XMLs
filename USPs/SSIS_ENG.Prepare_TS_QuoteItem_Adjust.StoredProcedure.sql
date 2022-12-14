USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_QuoteItem_Adjust]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
 Created:	KPHAM (20200211)
 20220118(v002)- Added DateModified
 20220513(v003)- Added Bonus_Eligible
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_QuoteItem_Adjust]
AS
BEGIN
	
	DECLARE @tblTS_QuoteItems TABLE (
		[ID_QuoteItem]	[INT] NOT NULL,
		[ID_FracInfo]	[INT] NOT NULL,
		[QuoteDate]		[SMALLDATETIME] NOT NULL,
		[ID_ChargeType] [INT] NOT NULL,
		[SequenceNo]	[INT] NOT NULL,
		[ChargeDesc]	[VARCHAR](255) NULL,
		[ChargeCode]	[VARCHAR](50) NULL,	
		[ChargeQty]		[FLOAT] NULL,	
		[ChargeUnitPrice]	[FLOAT] NULL,	
		[ChargeUnit]	[VARCHAR](50) NULL,
		[Discount]		[FLOAT] NULL,	
		[WellTotal]		[FLOAT] NULL,	
		[IsPassthrough]	[BIT] NOT NULL,
		[ID_ChargeOption]	[INT] NOT NULL,
		[AlternateName]		[VARCHAR](255) NULL,
		[ClientProvided]	[BIT] NOT NULL,
		[DateModified]	[DATETIME] NOT NULL,
		[Bonus_Eligible]	[BIT] NOT NULL,
		[rRank]			[INT]
	)

	;WITH cte_dQ As
		(SELECT DISTINCT ID_FracInfo, ChargeDescription, ChargeCode, cRecords = count(*)  /* Last count : 9 (11213) */
			, rID = ROW_NUMBER() OVER(ORDER BY ID_FracInfo)
			FROM dbo.FieldQuote_Items
			WHERE ID_FracInfo > 11213 --and ID_FracInfo = 12167
			GROUP BY ID_FracInfo, ChargeDescription, ChargeCode
			HAVING COUNT(*) > 1
			----order by id_fracinfo
		)
		, cte_rDups AS
		(SELECT iQ.*
			, rRank = RANK() OVER(PARTITION BY iQ.ID_FracInfo, iQ.ChargeDescription ORDER BY iQ.ID_FracInfo, ID_QuoteItem)
			FROM cte_dQ	t
				INNER JOIN dbo.FieldQuote_Items	iQ ON iQ.ID_FracInfo = t.ID_FracInfo 
														AND iQ.ChargeDescription = t.ChargeDescription 
														--AND t.ChargeCode = iQ.ChargeCode

		)
	
		INSERT INTO @tblTS_QuoteItems
		SELECT * 
			FROM cte_rDups t
			WHERE rRank > 1


		--select * from @tblTS_QuoteItems

		DECLARE @rDate	AS DATETIME		= GETDATE()
			, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
			, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TS_QuoteItems_Adjust]'	--This procedure's name
			, @rParams	AS VARCHAR(Max) = 'Remove extra lines ON dbo.FieldQuote_Items'	-- Description/etc.
			, @uRecords AS INT = 0
			, @rXML		AS XML 

		IF (SELECT COUNT(*) FROM @tblTS_QuoteItems) > 0
		BEGIN
			--select ChargeCode from dbo.Charge_Chemicals

			SET @uRecords = (SELECT COUNT(*) 
								FROM @tblTS_QuoteItems t 
									--INNER JOIN dbo.FieldQuote_Items d ON d.[ID_QuoteItem] = t.[ID_QuoteItem] 
							)

			SET @rParams = REPLACE(@rParams, 'Remove', 'Remove ' + CONVERT(VARCHAR(10),@uRecords))

			SET @rXML = (SELECT [ID_QuoteItem], [ID_FracInfo], [QuoteDate], [ID_ChargeType]
								, [SequenceNo], [ChargeDesc], [ChargeCode]
								, [ChargeQty] = CONVERT(DECIMAL(16,8),[ChargeQty])
								, [ChargeUnitPrice] = CONVERT(DECIMAL(16,8),[ChargeUnitPrice])
								, [ChargeUnit]
								, [Discount] = CONVERT(DECIMAL(16,8),[Discount])
								, [WellTotal],[IsPassthrough], [ID_ChargeOption], [AlternateName], [ClientProvided], [rRank]
								, [DateModified]= GETDATE()
						FROM @tblTS_QuoteItems t 
							--INNER JOIN dbo.FieldQuote_Items d  ON d.[ID_QuoteItem] = t.[ID_QuoteItem] 

						FOR XML PATH ('QuoteItem'), ROOT('FieldQuotes'))
		END

	IF @rXML IS NOT NULL 
		BEGIN
			/*** TEST SELECT 
			select @uRecords, @rParams, @rXML
			select * 
				from @tblTS_QuoteItems t INNER JOIN dbo.FieldQuote_Items d  ON d.[ID_QuoteItem] = t.[ID_QuoteItem]
			--**************************************/
		
			EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

			IF @uRecords > 0
			BEGIN
				DECLARE @rValue AS INT = 0;

				DELETE FROM iQ
				--select * 
					FROM @tblTS_QuoteItems t
						INNER JOIN dbo.FieldQuote_Items iQ ON iQ.ID_QuoteItem = t.ID_QuoteItem

				SET @rValue = ISNULL(@@ROWCOUNT, 0)

				IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FieldQuote_Items', 'Delete', @rValue;
			END
		END

	END -- end usp

GO

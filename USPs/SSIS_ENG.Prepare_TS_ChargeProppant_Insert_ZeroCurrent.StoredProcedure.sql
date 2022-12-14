USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeProppant_Insert_ZeroCurrent]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************
  Created:	KPHAM (20181212)
  20190301(v002)- Added additional join/validation by ChargeCode
  20190827(v003)- Added Xml back up values for Proppant_Price/Quantity/Cost/NoCost/UOM and Customer_Price/Quantity/Cost/NoCost/UOM
  20191112(v004)- SET INSERT DISTINCT on ID_FracInfo, ID_FracStage, ID_Proppant, Proppant_Name, Proppant_Desc, ChargeCode, , Proppant_UOM, Customer_UOM, Propant_Price
  20210213(v005)- Added Proppant_UOM  to compare changes
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeProppant_Insert_ZeroCurrent]	
AS
BEGIN

	IF	Object_ID('TempDB..#tmpTS_ChargeProppants')	IS NOT NULL	DROP TABLE #tmpTS_ChargeProppants
	CREATE TABLE #tmpTS_ChargeProppants(
		[tName]			[VARCHAR](255) NOT NULL,
		[tDesc]			[VARCHAR](255) NOT NULL,
		[TicketNo]		[VARCHAR](100) NULL,
		[WellName]		[VARCHAR](100) NULL,
		[StageNo]		[INT] NULL,
		[ProppantName]	[VARCHAR](100) NULL,
		[ChargeCode]	[INT] NULL,									/* 20190301 */
		[ChargeUnit]	[VARCHAR] (50) NULL,						/* 20210213 */
		
		[ID_Record]		[INT] NULL,
		[ID_FracInfo]	[INT] NULL,
		[ID_FracStage]	[INT] NULL,
		[ID_Proppant]	[INT] NULL,
		[nID_FracStage] [INT] NULL
	)

	;WITH vStages AS
			(SELECT * FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_versions]())
		, p_cPpt AS
			(SELECT DISTINCT ID_FracInfo	= cPpt.ID_FracInfo
				, ID_FracStage	= cPpt.ID_FracStage
				, ID_Product	= cPpt.ID_Proppant
				, StageNo		= p.StageNo
				, ChargeCode	= cPpt.ChargeCode					/* 20190301 */
				, ChargeUnit	= cPpt.Proppant_UOM					/* 20210213 */

				, VersionNo		= p.VersionNo
				, ID_Status		= p.ID_Status
				, IsPrevious	= p.IsDeleted
				, ID_Record		= cPpt.ID_ChargeProppant
				FROM dbo.Charge_Proppants	cPpt
					INNER JOIN vStages		p ON p.ID_FracStage = cPpt.ID_FracStage
			)
		, c_cPpt AS
			(SELECT DISTINCT ID_FracInfo	= cPpt.ID_FracInfo
				, ID_FracStage	= cPpt.ID_FracStage
				, ID_Product	= cPpt.ID_Proppant
				, StageNo		= p.StageNo
				, ChargeCode	= cPpt.ChargeCode					/* 20190302 */
				, ChargeUnit	= cPpt.Proppant_UOM					/* 20210213 */

				, VersionNo		= p.cVersionNo
				, ID_Status		= p.cID_Status
				, IsPrevious	= p.cIsDeleted
				, ID_Record		= cPpt.ID_ChargeProppant
				FROM dbo.Charge_Proppants cPpt
					INNER JOIN vStages p ON p.cID_FracStage = cPpt.ID_FracStage
			)
		, cte_Compare AS
		(SELECT tName		= 'Charge_Proppants'
			, tDesc			= CASE WHEN p.ID_FracInfo IS NULL THEN 'No Previous' 
								WHEN c.ID_FracInfo IS NULL THEN 'No Current' END
			, ID_FracInfo	= ISNULL(p.ID_FracInfo, c.ID_FracInfo)
			, StageNo		= ISNULL(p.StageNo, c.StageNo)
			, ID_FracStage	= ISNULL(p.ID_FracStage, c.ID_FracStage)
			, ID_Product	= ISNULL(p.ID_Product, c.ID_Product)
			, ChargeCode	= ISNULL(p.ChargeCode, c.ChargeCode)					/* 20190302 */
			, ChargeUnit	= ISNULL(p.ChargeUnit, c.ChargeUnit)					/* 20210213 */

			, VersionNo		= ISNULL(p.VersionNo, c.VersionNo)
			, IsPrevious	= ISNULL(p.IsPrevious, c.IsPrevious)
			, ID_Status		= ISNULL(p.ID_Status, c.ID_Status)
			, ID_Record		= ISNULL(p.ID_Record, c.ID_Record)
			, nID_FracStage = ISNULL(c.ID_Record, (SELECT n.cID_FracStage 
													FROM vStages n 
													WHERE n.ID_FracInfo = p.ID_FracInfo AND n.StageNo = p.StageNo AND n.cVersionNo = p.VersionNo+1))

			--, *
			FROM p_cPpt p
				FULL JOIN c_cPpt c 
					ON c.ID_FracInfo = p.ID_FracInfo 
						AND c.StageNo = p.StageNo 
						AND c.ID_Product = p.ID_Product
						AND c.ChargeCode = p.ChargeCode								/* 20190302 */
						AND c.ChargeUnit = p.ChargeUnit								/* 20210213 */

			WHERE c.ID_FracInfo is null
				or p.ID_FracInfo is null
		)
	
		--select * from cte_Compare

		INSERT INTO #tmpTS_ChargeProppants
		SELECT tName			= c.tName
			, tDesc				= c.tDesc
			, [TicketNo]		= xI.[TicketNo]
			, [WellName]		= xI.[WellName]
			, [StageNo]			= c.[StageNo]
			, [ProppantName]	= rP.[ProppantName]
			, [ChargeCode]		= c.[ChargeCode]
			, [ChargeUnit]		= c.[ChargeUnit]									/* 20210213 */

			, [ID_Record]		= c.[ID_Record]
			, [ID_FracInfo]		= c.[ID_FracInfo]
			, [ID_FracStage]	= c.[ID_FracStage]
			, [ID_Proppant]		= c.[ID_Product]
			, [nID_FracStage]	= c.[nID_FracStage]
			
			FROM cte_Compare c 
				INNER JOIN [SSIS_ENG].[fnRPT_xmlTS_FracInfo] () xI ON xI.ID_FracInfo = c.ID_FracInfo
				INNER JOIN dbo.LOS_Proppants				rP ON rP.ID_Proppant = c.ID_Product

		--select * from #tmpTS_ChargeProppants

		DECLARE @rDate	AS DATETIME		= GETDATE()
			, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
			, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TS_ChargeProppant_Insert_ZeroCurrent]' --This procedure's name
			, @rParams	AS VARCHAR(Max) = 'Insert unmatched previous version ON dbo.Charge_Proppants' -- Description/etc.
			, @uRecords AS INT = 0
			, @rXML		AS XML 

		IF (SELECT COUNT(*) FROM #tmpTS_ChargeProppants WHERE tDesc = 'No Current') > 0
		BEGIN
			SET @uRecords = (SELECT COUNT(*) 
								FROM #tmpTS_ChargeProppants t 
									INNER JOIN dbo.Charge_Proppants d 
										ON d.[ID_FracStage] = t.[ID_FracStage] 
											AND d.ID_Proppant = t.ID_Proppant
											AND d.ChargeCode = t.[ChargeCode]							/* 20190302 */
											AND d.Proppant_UOM = t.[ChargeUnit]							/* 20210213 */

								WHERE tDesc = 'No Current'
							)

			SET @rParams = REPLACE(@rParams, 'Insert', 'Insert ' + CONVERT(VARCHAR(10),@uRecords))

			SET @rXML = (SELECT tName, tDesc
						, t.TicketNo, t.WellName, t.StageNo, d.[ID_ChargeProppant], d.ID_FracInfo
						, ID_FracStage		= t.nID_FracStage
						, ID_Prooppant		= d.ID_Proppant
						, [Proppant_Name]	= d.[Proppant_Name]
						, [Proppant_Desc]	= d.[Proppant_Desc]
						, [ChargeCode]		= d.[ChargeCode]											/* 20190305 */
						, [Proppant_Price]		= CONVERT(decimal(26,8), d.[Proppant_Price])
						, [Proppant_Quantity]	= CONVERT(decimal(26,8), d.[Proppant_Quantity])
						, [Proppant_Cost]		= CONVERT(decimal(26,8), d.[Proppant_Cost])
						, [Proppant_NoCost]		= CONVERT(decimal(26,8), d.[Proppant_NoCost])
						, [Proppant_Discount]	= CONVERT(decimal(26,8), d.[Proppant_Discount])
						, [Proppant_UOM]		= d.[Proppant_UOM]
						, [Customer_Price]		= CONVERT(decimal(26,8), d.[Customer_Price])
						, [Customer_Quantity]	= CONVERT(decimal(26,8), d.[Customer_Quantity])
						, [Customer_Cost]		= CONVERT(decimal(26,8), d.[Customer_Cost])
						, [Customer_NoCost]		= CONVERT(decimal(26,8), d.[Customer_NoCost])
						, [Customer_UOM]		= d.[Customer_UOM]
						, [DateModified]		= GETDATE()
						FROM #tmpTS_ChargeProppants t 
							INNER JOIN dbo.Charge_Proppants d 
								ON d.[ID_FracStage] = t.[ID_FracStage] 
									AND d.ID_Proppant = t.ID_Proppant
									AND d.ChargeCode = t.[ChargeCode]						/* 20190301 */
									AND d.Proppant_UOM = t.[ChargeUnit]						/* 20210213 */

						WHERE tDesc = 'No Current'

						FOR XML PATH ('Charge_Proppant'), ROOT('Charge_Proppants'))
		END


	IF @rXML IS NOT NULL 
		BEGIN
			/*** TEST SELECT 
			select @uRecords, @rParams, @rXML
			select * 
				from #tmpTS_ChargeProppants t
					INNER JOIN dbo.Charge_Proppants d 
						ON d.[ID_FracStage] = t.[ID_FracStage] 
							AND d.ID_Proppant = t.ID_Proppant
							AND d.ChargeCode = t.[ChargeCode]						/* 20190305 */
				where tDesc = 'No Current'
			--**************************************/
		
			EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

			IF @uRecords > 0
			BEGIN
				INSERT INTO dbo.Charge_Proppants
					(ID_FracStage, ID_Proppant
					, Proppant_Name, Proppant_Desc, ChargeCode
					, Proppant_Price, Proppant_Quantity, Proppant_NoCost, Proppant_Cost, Proppant_Discount, Proppant_UOM
					, Customer_Price, Customer_Quantity, Customer_NoCost, Customer_Cost, Customer_UOM
					, ID_FracInfo)

				SELECT DISTINCT 
					  t.nID_FracStage
					, d.ID_Proppant
					, d.Proppant_Name
					, d.Proppant_Desc
					, d.ChargeCode															/* 20190302 */
					, d.Proppant_Price
					, 0--xCC.Proppant_Quantity
					, 0--xCC.Proppant_NoCost
					, 0--xCC.Proppant_Cost
					, 0--xCC.Proppant_Discount
					, d.Proppant_UOM

					, 0--xCC.Customer_Price
					, 0--xCC.Customer_Quantity
					, 0--xCC.Customer_NoCost
					, 0--xCC.Customer_Cost
					, d.Customer_UOM
					, t.ID_FracInfo
				 
					FROM #tmpTS_ChargeProppants t
						INNER JOIN dbo.Charge_Proppants d 
							ON d.[ID_FracStage] = t.[ID_FracStage] 
								AND d.ID_Proppant = t.ID_Proppant
								AND d.ChargeCode = t.[ChargeCode]							/* 20190302 */
								AND d.Proppant_UOM = t.[ChargeUnit]							/* 20210213 */

					WHERE tDesc = 'No Current'

					GROUP BY t.ID_FracInfo
						, t.nID_FracStage
						, d.ID_Proppant
						, d.Proppant_Name
						, d.Proppant_Desc
						, d.ChargeCode
						, d.Proppant_UOM
						, d.Customer_UOM
						, d.Proppant_Price

			END

	END
END

GO

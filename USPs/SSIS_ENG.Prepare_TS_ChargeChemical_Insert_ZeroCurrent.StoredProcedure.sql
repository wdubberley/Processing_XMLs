USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeChemical_Insert_ZeroCurrent]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  Created:	KPHAM (20181212)
  20190301(v002)- Added additional join/validation by ChargeCode
  20190827(v003)- Add Charge_Unit
  20191112(v005)- Set INSERT DISTINCT on ID_FracInfo, ID_FracStage, ID_Chemical, ChemicalDesc, ChargeCode, ChargeUnit, ChargePrice
  20210211(v006)- Added Charge_Unit to compare changes
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeChemical_Insert_ZeroCurrent]
AS
BEGIN
	
	IF	Object_ID('TempDB..#tmpTS_ChargeChemicals')	IS NOT NULL	DROP TABLE #tmpTS_ChargeChemicals
	CREATE TABLE #tmpTS_ChargeChemicals(
		[tName]			[VARCHAR](255) NOT NULL,
		[tDesc]			[VARCHAR](255) NOT NULL,
		[TicketNo]		[VARCHAR](100) NULL,
		[WellName]		[VARCHAR](100) NULL,
		[StageNo]		[INT] NULL,
		[ChemicalName]	[VARCHAR](100) NULL,
		[ChargeCode]	[INT] NULL,									/* 20190301 */
		[ChargeUnit]	[VARCHAR] (50) NULL,						/* 20210213 */
		[ID_ChargeChem]	[INT] NULL,
		[ID_FracInfo]	[INT] NULL,
		[ID_FracStage]	[INT] NULL,
		[ID_Chemical]	[INT] NULL,
		[nID_FracStage] [INT] NULL
	)

	;with vStages AS
			(SELECT * FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_versions]())
		, p_cChems AS
			(select DISTINCT ID_FracInfo	= cChems.ID_FracInfo
				, ID_FracStage	= cChems.ID_FracStage
				, ID_Product	= cChems.ID_Chemical
				, ChargeCode	= cChems.ChargeCode					/* 20190301 */
				, ChargeUnit	= cChems.Charge_Unit				/* 20210213 */

				, StageNo		= p.StageNo
				, VersionNo		= p.VersionNo
				--, p.cID_FracStage
				, ID_Status		= p.ID_Status
				, IsPrevious	= p.IsDeleted
				, ID_Record		= cChems.ID_ChargeChem
				from dbo.Charge_Chemicals cChems
					inner join vStages p ON p.ID_FracStage = cChems.ID_FracStage
			)
		, c_cChems AS
			(select DISTINCT ID_FracInfo	= cChems.ID_FracInfo
				, ID_FracStage	= cChems.ID_FracStage
				, ID_Product	= cChems.ID_Chemical
				, ChargeCode	= cChems.ChargeCode					/* 20190301 */
				, ChargeUnit	= cChems.Charge_Unit				/* 20210213 */

				, StageNo		= p.StageNo
				, VersionNo		= p.cVersionNo
				--, p.cID_FracStage
				, ID_Status		= p.cID_Status
				, IsPrevious	= p.cIsDeleted
				, ID_Record		= cChems.ID_ChargeChem
				from dbo.Charge_Chemicals cChems
					inner join vStages p ON p.cID_FracStage = cChems.ID_FracStage
			)
		, cte_Compare AS
		(select tName		= 'Charge_Chemicals'
			, tDesc			= CASE WHEN p.ID_FracInfo IS NULL THEN 'No Previous' 
								WHEN c.ID_FracInfo IS NULL THEN 'No Current' END
			, ID_FracInfo	= ISNULL(p.ID_FracInfo, c.ID_FracInfo)
			, StageNo		= ISNULL(p.StageNo, c.StageNo)
			, ID_FracStage	= ISNULL(p.ID_FracStage, c.ID_FracStage)
			, ID_Product	= ISNULL(p.ID_Product, c.ID_Product)
			, ChargeCode	= ISNULL(p.ChargeCode, c.ChargeCode)					/* 20190301 */
			, ChargeUnit	= ISNULL(p.ChargeUnit, c.ChargeUnit)					/* 20210213 */

			, VersionNo		= ISNULL(p.VersionNo, c.VersionNo)
			, IsPrevious	= ISNULL(p.IsPrevious, c.IsPrevious)
			, ID_Status		= ISNULL(p.ID_Status, c.ID_Status)
			, ID_Record		= ISNULL(p.ID_Record, c.ID_Record)
			, nID_FracStage = ISNULL(c.ID_Record, (SELECT n.cID_FracStage 
													FROM vStages n 
													WHERE n.ID_FracInfo = p.ID_FracInfo AND n.StageNo = p.StageNo AND n.cVersionNo = p.VersionNo+1))

			--, *
			from p_cChems p
				full join c_cChems c 
					ON c.ID_FracInfo = p.ID_FracInfo AND c.StageNo = p.StageNo 
						AND c.ID_Product = p.ID_Product 
						AND c.ChargeCode = p.ChargeCode								/* 20190301 */
						AND c.ChargeUnit = p.ChargeUnit								/* 20210213 */
			
			WHERE c.ID_FracInfo is null
				or p.ID_FracInfo is null
		)
	
		--select * from cte_Compare

		INSERT INTO #tmpTS_ChargeChemicals
		SELECT tName			= c.tName
			, tDesc				= c.tDesc
			, [TicketNo]		= xI.[TicketNo]
			, [WellName]		= xI.[WellName]
			, [StageNo]			= c.[StageNo]
			, [ChemicalName]	= rC.[ChemicalName]
			, [ChargeCode]		= c.[ChargeCode]									/* 20190301 */
			, [ChargeUnit]		= c.[ChargeUnit]									/* 20210213 */

			, [ID_ChargeChem]	= c.[ID_Record]
			, [ID_FracInfo]		= c.[ID_FracInfo]
			, [ID_FracStage]	= c.[ID_FracStage]
			, [ID_Chemical]		= c.[ID_Product]
			, [nID_FracStage]	= c.[nID_FracStage]
			
			FROM cte_Compare c 
				INNER JOIN [SSIS_ENG].[fnRPT_xmlTS_FracInfo] () xI ON xI.ID_FracInfo = c.ID_FracInfo
				LEFT JOIN dbo.LOS_Chemicals rC ON rC.ID_Chemical = c.ID_Product

		--select * from #tmpTS_ChargeChemicals

		DECLARE @rDate	AS DATETIME		= GETDATE()
			, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
			, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TS_ChargeChemical_Insert_ZeroCurrent]'	--This procedure's name
			, @rParams	AS VARCHAR(Max) = 'Insert unmatched previous version ON dbo.Charge_Chemicals' -- Description/etc.
			, @uRecords AS INT = 0
			, @rXML		AS XML 

		IF (SELECT COUNT(*) FROM #tmpTS_ChargeChemicals WHERE tDesc = 'No Current') > 0
		BEGIN
			--select ChargeCode from dbo.Charge_Chemicals

			SET @uRecords = (SELECT COUNT(*) 
								FROM #tmpTS_ChargeChemicals t 
									INNER JOIN dbo.Charge_Chemicals d 
										ON d.[ID_FracStage] = t.[ID_FracStage] 
											AND d.ID_Chemical = t.ID_Chemical
											AND d.ChargeCode = t.[ChargeCode]							/* 20190301 */
											AND d.[Charge_Unit] = t.[ChargeUnit]						/* 20210213 */
								WHERE tDesc = 'No Current'
							)

			SET @rParams = REPLACE(@rParams, 'Insert', 'Insert ' + CONVERT(VARCHAR(10),@uRecords))

			SET @rXML = (SELECT tName, tDesc
						, t.TicketNo, t.WellName, t.StageNo, d.[ID_ChargeChem], d.ID_FracInfo
						, ID_FracStage		= t.nID_FracStage
						, ID_Chemical		= d.ID_Chemical
						, [Chemical_Desc]	= d.[Chemical_Desc]
						, [ChargeCode]		= d.[ChargeCode]											/* 20190301 */
						, [ChargeUnit]		= d.[Charge_Unit]											/* 20210213 */
						, [Chemical_Price]		= CONVERT(decimal(26,8), d.[Chemical_Price])
						--, [Chemical_Quantity]	= CONVERT(decimal(26,8), d.[Chemical_Quantity])
						--, [Chemical_NoCost]		= CONVERT(decimal(26,8), d.[Chemical_NoCost])
						--, [Chemical_Cost]		= CONVERT(decimal(26,8), d.[Chemical_Cost])
						--, [Chemical_Discount]	= CONVERT(decimal(26,8), d.[Chemical_Discount])
						, [DateModified]= GETDATE()
						FROM #tmpTS_ChargeChemicals t 
							INNER JOIN dbo.Charge_Chemicals d 
								ON d.[ID_FracStage] = t.[ID_FracStage] 
									AND d.ID_Chemical = t.ID_Chemical 
									AND d.ChargeCode = t.[ChargeCode]						/* 20190301 */
									AND d.[Charge_Unit] = t.[ChargeUnit]					/* 20210213 */

						--WHERE tDesc = 'No Current'				/* no filtering in XML */

						FOR XML PATH ('Charge_Chemical'), ROOT('Charge_Chemicals'))
		END


	IF @rXML IS NOT NULL 
		BEGIN
			/*** TEST SELECT 
			select @uRecords, @rParams, @rXML
			select * 
				from #tmpTS_ChargeChemicals t
					INNER JOIN dbo.Charge_Chemicals d ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Chemical = t.ID_Chemical AND d.ChargeCode = t.[ChargeCode]	/* 20190301 */
				WHERE tDesc = 'No Current'
			--**************************************/
		
			EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

			IF @uRecords > 0
			BEGIN
				INSERT INTO dbo.Charge_Chemicals
					(ID_FracStage, ID_Chemical
					, Chemical_Desc, ChargeCode, Charge_Unit
					, Chemical_Price, Chemical_Quantity, Chemical_NoCost, Chemical_Cost, Chemical_Discount
					, ID_FracInfo)

				SELECT DISTINCT 
					  t.nID_FracStage
					, d.ID_Chemical
					, d.Chemical_Desc
					, d.ChargeCode
					, d.Charge_Unit

					, d.Chemical_Price
					, 0--xCC.Chemical_Quantity
					, 0--xCC.ChemicalNoCost
					, 0--xCC.ChemicalCost
					, 0--xCC.Chemical_Discount

					, t.ID_FracInfo
				 
					FROM #tmpTS_ChargeChemicals t
						INNER JOIN dbo.Charge_Chemicals d 
							ON d.[ID_FracStage] = t.[ID_FracStage] 
								AND d.ID_Chemical = t.ID_Chemical 
								AND d.ChargeCode = t.[ChargeCode]								/* 20190301 */
								AND d.Charge_Unit = t.[ChargeUnit]								/* 20210213 */
					
					WHERE tDesc = 'No Current'

					GROUP BY t.ID_FracInfo
						, t.nID_FracStage
						, d.ID_Chemical
						, d.Chemical_Desc
						, d.ChargeCode
						, d.Charge_Unit
						, d.Chemical_Price

			END

	END

END 

GO

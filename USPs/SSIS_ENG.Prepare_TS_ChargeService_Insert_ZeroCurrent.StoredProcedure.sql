USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeService_Insert_ZeroCurrent]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************************************
  Created:	KPHAM (20181212)
  20190303(v002)- Added additional join/validation by ChargeCode
  20190827(v003)- Added Charge_Unit
  20220106(v004)- Added ChargeUnit to comparison to create reversal
****************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeService_Insert_ZeroCurrent]	
AS
BEGIN

	IF	Object_ID('TempDB..#tmpTS_ChargeServices')	IS NOT NULL	DROP TABLE #tmpTS_ChargeServices
	CREATE TABLE #tmpTS_ChargeServices(
		[tName]			[VARCHAR](255) NOT NULL,
		[tDesc]			[VARCHAR](255) NOT NULL,
		[TicketNo]		[VARCHAR](100) NULL,
		[WellName]		[VARCHAR](100) NULL,
		[StageNo]		[INT] NULL,
		[ServiceName]	[VARCHAR](100) NULL,
		[ChargeCode]	[INT] NULL,									/* 20190303 */
		[ChargeUnit]	[VARCHAR] (50) NULL,						/* 20220106 */
		
		[ID_Record]		[INT] NULL,
		[ID_FracInfo]	[INT] NULL,
		[ID_FracStage]	[INT] NULL,
		[ID_Service]	[INT] NULL,
		[nID_FracStage] [INT] NULL
	)

	;WITH vStages AS
			(SELECT * FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_versions]())
		, p_cServices AS
			(SELECT DISTINCT ID_FracInfo	= cServices.ID_FracInfo
				, ID_FracStage	= cServices.ID_FracStage
				, ID_Product	= cServices.ID_Service
				, ChargeCode	= cServices.ChargeCode					/* 20190303 */
				, ChargeUnit	= cServices.Charge_Unit					/* 20220106 */

				, StageNo		= p.StageNo
				, VersionNo		= p.VersionNo
				, ID_Status		= p.ID_Status
				, IsPrevious	= p.IsDeleted
				, ID_Record		= cServices.ID_ChargeService
				FROM dbo.Charge_Services cServices
					INNER JOIN vStages p ON p.ID_FracStage = cServices.ID_FracStage
			)
		, c_cServices AS
			(SELECT DISTINCT ID_FracInfo	= cServices.ID_FracInfo
				, ID_FracStage	= cServices.ID_FracStage
				, ID_Product	= cServices.ID_Service
				, ChargeCode	= cServices.ChargeCode					/* 20190303 */
				, ChargeUnit	= cServices.Charge_Unit					/* 20220106 */

				, StageNo		= p.StageNo
				, VersionNo		= p.cVersionNo
				, ID_Status		= p.cID_Status
				, IsPrevious	= p.cIsDeleted
				, ID_Record		= cServices.ID_ChargeService
				FROM dbo.Charge_Services cServices
					INNER JOIN vStages p ON p.cID_FracStage = cServices.ID_FracStage
			)
		, cte_Compare AS
			(SELECT tName		= 'Charge_Services'
				, tDesc			= CASE WHEN p.ID_FracInfo IS NULL THEN 'No Previous' 
									WHEN c.ID_FracInfo IS NULL THEN 'No Current' END
				, ID_FracInfo	= ISNULL(p.ID_FracInfo, c.ID_FracInfo)
				, StageNo		= ISNULL(p.StageNo, c.StageNo)
				, ID_FracStage	= ISNULL(p.ID_FracStage, c.ID_FracStage)
				, ID_Product	= ISNULL(p.ID_Product, c.ID_Product)
				, ChargeCode	= ISNULL(p.ChargeCode, c.ChargeCode)					/* 20190303 */
				, ChargeUnit	= ISNULL(p.ChargeUnit, c.ChargeUnit)					/* 20220106 */

				, VersionNo		= ISNULL(p.VersionNo, c.VersionNo)
				, IsPrevious	= ISNULL(p.IsPrevious, c.IsPrevious)
				, ID_Status		= ISNULL(p.ID_Status, c.ID_Status)
				, ID_Record		= ISNULL(p.ID_Record, c.ID_Record)
				, nID_FracStage = ISNULL(c.ID_Record, (SELECT n.cID_FracStage 
														FROM vStages n 
														WHERE n.ID_FracInfo = p.ID_FracInfo AND n.StageNo = p.StageNo AND n.cVersionNo = p.VersionNo+1))

				--, *
				FROM p_cServices p
					FULL JOIN c_cServices c 
						ON c.ID_FracInfo = p.ID_FracInfo 
							AND c.StageNo = p.StageNo 
							AND c.ID_Product = p.ID_Product
							AND c.ChargeCode = p.ChargeCode								/* 20190303 */
							AND c.ChargeUnit = p.ChargeUnit								/* 20220106 */

				WHERE c.ID_FracInfo is null
					or p.ID_FracInfo is null
			)
	
		--select * from cte_Compare

		INSERT INTO #tmpTS_ChargeServices
		SELECT tName			= c.tName
			, tDesc				= c.tDesc
			, [TicketNo]		= xI.[TicketNo]
			, [WellName]		= xI.[WellName]
			, [StageNo]			= c.[StageNo]
			, [ServiceName]		= rS.[ServiceName]
			, [ChargeCode]		= c.[ChargeCode]									/* 20190303 */
			, [ChargeUnit]		= c.[ChargeUnit]									/* 20220106 */

			, [ID_Record]		= c.[ID_Record]
			, [ID_FracInfo]		= c.[ID_FracInfo]
			, [ID_FracStage]	= c.[ID_FracStage]
			, [ID_Service]		= c.[ID_Product]
			, [nID_FracStage]	= c.[nID_FracStage]
			
			FROM cte_Compare c 
				INNER JOIN [SSIS_ENG].[fnRPT_xmlTS_FracInfo] () xI ON xI.ID_FracInfo = c.ID_FracInfo
				LEFT JOIN dbo.LOS_ChargeServices rS ON rS.ID_ChargeService = c.ID_Product

		--select * from #tmpTS_ChargeServices

		DECLARE @rDate	AS DATETIME		= GETDATE()
			, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
			, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TS_ChargeService_Insert_ZeroCurrent]'	--This procedure's name
			, @rParams	AS VARCHAR(Max) = 'Insert unmatched previous version ON dbo.Charge_Services' -- Description/etc.
			, @uRecords AS INT = 0
			, @rXML		AS XML 

		IF (SELECT COUNT(*) FROM #tmpTS_ChargeServices WHERE tDesc = 'No Current') > 0
		BEGIN
			SET @uRecords = (SELECT COUNT(*) 
								FROM #tmpTS_ChargeServices t 
									INNER JOIN dbo.Charge_Services d 
										ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Service = t.ID_Service
											AND d.ChargeCode = t.[ChargeCode]							/* 20190301 */
											AND d.Charge_Unit = t.[ChargeUnit]							/* 20220106 */

								WHERE tDesc = 'No Current'
							)

			SET @rParams = REPLACE(@rParams, 'Insert', 'Insert ' + CONVERT(VARCHAR(10),@uRecords))

			SET @rXML = (SELECT tName, tDesc
						, t.TicketNo, t.WellName, t.StageNo, d.[ID_ChargeService], d.ID_FracInfo
						, ID_FracStage		= t.nID_FracStage
						, d.ID_Service
						, [Service_Desc]	= t.[ServiceName]
						, [ChargeCode]		= t.[ChargeCode]											/* 20190301 */
						, [Service_Price]	= CONVERT(decimal(26,8), d.[Service_Price])
						, [ChargeUnit]		= t.[ChargeUnit]											/* 20220106 */
						--, [Service_Quantity]	= CONVERT(decimal(26,8), d.[Service_Quantity])
						--, [Service_Cost]		= CONVERT(decimal(26,8), d.[Service_Cost])
						--, [IsPassthrough]		= CONVERT(TINYINT, d.[IsPassthrough])
						--, [Service_Discount]	= CONVERT(decimal(26,8), d.[Service_Discount])
						, [DateModified]		= GETDATE()
						FROM #tmpTS_ChargeServices t 
							INNER JOIN dbo.Charge_Services d 
								ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Service = t.ID_Service
									AND d.ChargeCode = t.[ChargeCode]								/* 20190301 */
									AND d.Charge_Unit = t.[ChargeUnit]								/* 20220106 */

						--WHERE tDesc = 'No Current'

						FOR XML PATH ('Charge_Service'), ROOT('Charge_Services'))
		END


	IF @rXML IS NOT NULL 
		BEGIN
			/*** TEST SELECT 
			select @uRecords, @rParams, @rXML
			select * 
				from #tmpTS_ChargeServices t
					INNER JOIN dbo.Charge_Services d ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Service = t.ID_Service AND d.ChargeCode = t.[ChargeCode]	/* 20190303 */
				WHERE tDesc = 'No Current'
			--**************************************/
		
			EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

			IF @uRecords > 0
			BEGIN
				INSERT INTO dbo.Charge_Services
					(ID_FracStage, ID_Service
					, ChargeCode, Charge_Unit
					, Service_Price, Service_Quantity, Service_Cost, IsPassthrough, Service_Discount
					, ID_FracInfo, ID_ChargeOption)

				SELECT t.nID_FracStage
					, d.ID_Service
					, d.ChargeCode
					, d.Charge_Unit

					, d.Service_Price
					, 0--xCC.Service_Quantity
					, 0--xCC.Service_Cost
					, 0--xCC.IsPassthrough
					, 0--xCC.Service_Discount

					, t.ID_FracInfo
					, d.ID_ChargeOption
				 
					FROM #tmpTS_ChargeServices t
						INNER JOIN dbo.Charge_Services d 
							ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Service = t.ID_Service
								AND d.ChargeCode = t.[ChargeCode]								/* 20190301 */
								AND d.Charge_Unit = t.[ChargeUnit]								/* 20220106 */

					WHERE tDesc = 'No Current'

			END

	END

END 

GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracFluid_Insert_ZeroCurrent]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM (2019)
  Modified:	
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracFluid_Insert_ZeroCurrent]	
AS
BEGIN
	
	IF	Object_ID('TempDB..#tmpTS_FracFluids')	IS NOT NULL	DROP TABLE #tmpTS_FracFluids
	CREATE TABLE #tmpTS_FracFluids(
		[tName]			[VARCHAR](255) NOT NULL,
		[tDesc]			[VARCHAR](255) NOT NULL,
		[TicketNo]		[VARCHAR](100) NULL,
		[WellName]		[VARCHAR](100) NULL,
		[StageNo]		[INT] NULL,
		[FluidName]		[VARCHAR](100) NULL,

		[ID_Record]		[INT] NULL,
		[ID_FracInfo]	[INT] NULL,
		[ID_FracStage]	[INT] NULL,
		[ID_Fluid]		[INT] NULL,
		[nID_FracStage] [INT] NULL
	)

	;WITH vStages AS
			(SELECT * FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Versions]())
		, p_cFluid AS
			(SELECT DISTINCT ID_FracInfo	= cFluid.ID_FracInfo
				, ID_FracStage	= cFluid.ID_FracStage
				, ID_Product	= cFluid.ID_Fluid
				, StageNo		= p.StageNo
				, VersionNo		= p.VersionNo
				--, p.cID_FracStage
				, ID_Status		= p.ID_Status
				, IsPrevious	= p.IsDeleted
				, ID_Record		= cFluid.ID_FracFluid
				FROM dbo.FracFluids cFluid
					INNER JOIN vStages p ON p.ID_FracStage = cFluid.ID_FracStage
			)
		, c_cFluid AS
			(SELECT DISTINCT ID_FracInfo	= cFluid.ID_FracInfo
				, ID_FracStage	= cFluid.ID_FracStage
				, ID_Product	= cFluid.ID_Fluid
				, StageNo		= p.StageNo
				, VersionNo		= p.cVersionNo
				--, p.cID_FracStage
				, ID_Status		= p.cID_Status
				, IsPrevious	= p.cIsDeleted
				, ID_Record		= cFluid.ID_FracFluid
				FROM dbo.FracFluids cFluid
					INNER JOIN vStages p ON p.cID_FracStage = cFluid.ID_FracStage
			)
		, cte_Compare AS
			(SELECT tName		= 'FracFluids'
				, tDesc			= CASE WHEN p.ID_FracInfo IS NULL THEN 'No Previous' 
									WHEN c.ID_FracInfo IS NULL THEN 'No Current' END
				, ID_FracInfo	= ISNULL(p.ID_FracInfo, c.ID_FracInfo)
				, StageNo		= ISNULL(p.StageNo, c.StageNo)
				, ID_FracStage	= ISNULL(p.ID_FracStage, c.ID_FracStage)
				, ID_Product	= ISNULL(p.ID_Product, c.ID_Product)
				, VersionNo		= ISNULL(p.VersionNo, c.VersionNo)
				, IsPrevious	= ISNULL(p.IsPrevious, c.IsPrevious)
				, ID_Status		= ISNULL(p.ID_Status, c.ID_Status)
				, ID_Record		= ISNULL(p.ID_Record, c.ID_Record)
				, nID_FracStage = ISNULL(c.ID_Record, (SELECT n.cID_FracStage 
														FROM vStages n 
														WHERE n.ID_FracInfo = p.ID_FracInfo AND n.StageNo = p.StageNo AND n.cVersionNo = p.VersionNo+1))

				--, *
				FROM p_cFluid p
					FULL JOIN c_cFluid c ON c.ID_FracInfo = p.ID_FracInfo AND c.StageNo = p.StageNo AND c.ID_Product = p.ID_Product
			

				WHERE c.ID_FracInfo is null
					or p.ID_FracInfo is null
			)
	
		--select * from cte_Compare

		INSERT INTO #tmpTS_FracFluids
		SELECT tName		= c.tName
			, tDesc			= c.tDesc
			, [TicketNo]	= xI.[TicketNo]
			, [WellName]	= xI.[WellName]
			, [StageNo]		= c.[StageNo]
			, [FluidName]	= rP.[FluidName]

			, [ID_Record]		= c.[ID_Record]
			, [ID_FracInfo]		= c.[ID_FracInfo]
			, [ID_FracStage]	= c.[ID_FracStage]
			, [ID_Fluid]		= c.[ID_Product]
			, [nID_FracStage]	= c.[nID_FracStage]
			
			FROM cte_Compare c 
				INNER JOIN [SSIS_ENG].[fnRPT_xmlTS_FracInfo] () xI ON xI.ID_FracInfo = c.ID_FracInfo
				INNER JOIN dbo.LOS_Fluids rP ON rP.ID_Fluid = c.ID_Product

		--select * from #tmpTS_FracFluids

		DECLARE @rDate	AS DATETIME		= GETDATE()
			, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
			, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[Prepare_TS_FracFluid_Insert_v2018]'	--This procedure's name
			, @rParams	AS VARCHAR(Max) = 'Insert unmatched previous version ON dbo.FracFluids' -- Description/etc.
			, @uRecords AS INT = 0
			, @rXML		AS XML 

		IF (SELECT COUNT(*) FROM #tmpTS_FracFluids WHERE tDesc = 'No Current') > 0
		BEGIN
			SET @uRecords = (SELECT COUNT(*) 
								FROM #tmpTS_FracFluids t 
									INNER JOIN dbo.FracFluids d ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Fluid = t.ID_Fluid
								WHERE tDesc = 'No Current'
							)

			SET @rParams = REPLACE(@rParams, 'Insert', 'Insert ' + CONVERT(VARCHAR(10),@uRecords))

			SET @rXML = (SELECT tName, tDesc
						, t.TicketNo, t.WellName, t.StageNo, d.[ID_FracFluid], d.ID_FracInfo
						, ID_FracStage		= t.nID_FracStage
						, ID_Fluid			= d.ID_Fluid
						, [Fluid_Volume]	= CONVERT(decimal(26,8), d.[Fluid_Volume])
						, [DateModified]	= GETDATE()
						FROM #tmpTS_FracFluids t 
							INNER JOIN dbo.FracFluids d ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Fluid = t.ID_Fluid

						--WHERE tDesc = 'No Current'

						FOR XML PATH ('FracFluid'), ROOT('FracFluids'))
		END


	IF @rXML IS NOT NULL 
		BEGIN
			--select @uRecords, @rParams, @rXML
			--select * 
			--	from #tmpTS_FracFluids t
			--		INNER JOIN dbo.FracFluids d ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Fluid = t.ID_Fluid
			--	where tDesc = 'No Current'
		
			EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

			IF @uRecords > 0
			BEGIN
				INSERT INTO dbo.FracFluids
					(ID_FracStage, ID_Fluid
					, [Fluid_Volume]
					, ID_FracInfo)

				SELECT t.nID_FracStage
					, d.ID_Fluid
					, 0--d.Fluid_Volume
					
					, t.ID_FracInfo
				 
					from #tmpTS_FracFluids t
						INNER JOIN dbo.FracFluids d ON d.[ID_FracStage] = t.[ID_FracStage] AND d.ID_Fluid = t.ID_Fluid
					WHERE tDesc = 'No Current'

			END

		END
	
	;

END 

GO

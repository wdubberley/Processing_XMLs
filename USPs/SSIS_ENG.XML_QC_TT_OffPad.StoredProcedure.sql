USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[XML_QC_TT_OffPad]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSIS_ENG].[XML_QC_TT_OffPad]	
AS
BEGIN
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;

	IF	Object_ID('TempDB..#tmpTT_FracTime')	IS NOT NULL	DROP TABLE #tmpTT_FracTime
	CREATE TABLE #tmpTT_FracTime(
		[ID_FracTime]	[INT] NULL,
		[ID_Pad]	[INT] NULL,
		[ID_Well]	[INT] NULL,
		[ID_Crew]	[INT] NULL)

	;WITH cte_TT AS
		(SELECT *
			FROM dbo.FracTime eT
			WHERE eT.EventStartDate >= '20180801'
				AND eT.ID_MainEvent IN (108,109,160,174,191) AND eT.ID_TimeClass <> 5
		)

	INSERT INTO #tmpTT_FracTime
	SELECT ID_FracTime
		, ID_Pad
		, ID_Well
		, ID_Crew
		FROM cte_TT t
	
	DECLARE @rDate	AS DATETIME		= GETDATE()
			, @rLogin	AS VARCHAR(100) = ORIGINAL_LOGIN()
			, @rSource	AS VARCHAR(255) = '[SSIS_ENG].[XML_QC_TT_OffPad]'	--This procedure's name
			, @rParams	AS VARCHAR(Max) = 'Update ID_TimeClass to Off Pad (5) on dbo.FracTime' -- Description/etc.
			, @uRecords AS INT = 0
			, @rXML		AS XML 

	IF (SELECT COUNT(*) FROM #tmpTT_FracTime) > 0
		BEGIN
			SET @uRecords = (SELECT COUNT(*) 
								FROM #tmpTT_FracTime t 
									INNER JOIN dbo.FracTime d ON d.[ID_FracTime] = t.[ID_FracTime])

			SET @rParams = REPLACE(@rParams, 'Update', 'Update ' + CONVERT(VARCHAR(10),@uRecords))

			SET @rXML = (SELECT d.[ID_FracTime]
							, d.[ID_Pad]
							, d.[ID_Well]
							, d.[ID_Crew]
							, d.[ID_QAQC]
							, d.[ID_Engineer]
							, d.[ID_Supervisor]
							, d.[ID_CustomerRep]
							, d.[StageNo]
							, d.[ID_CompletionType]
							, d.[StartDateTime]
							, d.[ID_PartyType]
							, d.[ID_MainEvent]
							, d.[ID_TimeClass]
							, d.[IsComplete]
							, d.[MHHP]
							, d.[LOS3rd]
							, FracTime_min = CONVERT(DECIMAL(18,4), d.[FracTime_min])
							, d.[EventStartDate]
							, d.[EventEndDate]
							, d.[EventEndDateTime]
							, d.[EventOfDay]
							, d.[Vnum]
							, d.[OpsAlias]
							, d.[PumpTime]
							, d.[Notes]
							, d.[RecordNo]
							, d.[ID_GenMainEvent]
							, d.[ID_Alias]
							, d.[ID_Camp]
							, [DateModified]= GETDATE()
							FROM #tmpTT_FracTime t 
								INNER JOIN dbo.FracTime d ON d.[ID_FracTime] = t.[ID_FracTime]
							FOR XML PATH ('FracTime'), ROOT('FracTimes'))
		END

	IF @rXML IS NOT NULL 
		BEGIN
			--select @rXML
			--select * from #tmpTT_FracTime
		
			EXECUTE [History].[usp_History_XML] @rDate, @rLogin, @rSource, @rParams,@rXML

			UPDATE d SET d.ID_TimeClass = 5
			--SELECT d.* 
				FROM #tmpTT_FracTime t 
					INNER JOIN dbo.FracTime d ON d.[ID_FracTime] = t.[ID_FracTime]
		END

	SET ANSI_WARNINGS ON;
	SET NOCOUNT OFF;

END 


GO

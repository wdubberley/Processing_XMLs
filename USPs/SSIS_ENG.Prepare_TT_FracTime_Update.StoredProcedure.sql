USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TT_FracTime_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************************************
  Created:	KPHAM (2016)
  20190130- Added join filter to first ID_Pad since 2018
  20190202(v002)- Recode to improve process time
  20190203(v003)- Added @tID_Pad to limit join time to just previous year pads til recent
  20190806(v004)- Added ArchiveNotes, countSync
  20220117(v005)- Added DateModified
  20220223(v006)- Added ID_PumpOperator
******************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TT_FracTime_Update]	
AS
BEGIN

	DECLARE @tID_Pad AS INT = 1;

	SET @tID_Pad = (SELECT TOP 1 ID_Pad 
						FROM [dbo].[fnREFs_Pads] ('') t
						WHERE YEAR(tFr) >= YEAR(GETDATE()) - 1
						ORDER BY t.ID_Pad);

	UPDATE eT SET
		  eT.ID_Well	= xT.ID_Well
		, eT.ID_Crew	= xT.ID_Crew

		, eT.ID_PumpOperator= xT.ID_PumpOperator				/* 20220223 */
		, eT.ID_QAQC		= xT.ID_QAQC
		, eT.ID_Engineer	= xT.ID_Engineer
		, eT.ID_Supervisor	= xT.ID_Supervisor
		, eT.ID_CustomerRep	= xT.ID_CustomerRep

		, eT.StageNo			= xT.StageNo
		, eT.ID_CompletionType	= xT.ID_CompletionType

		, eT.StartDateTime		= xT.StartDateTime
		, eT.EventEndDateTime	= xT.EndDateTime
		, eT.EventStartDate		= xT.EventStartDate
		, eT.EventEndDate		= xT.EventEndDate
		
		, eT.ID_PartyType	= xT.ID_Party
		, eT.ID_MainEvent	= xT.ID_MainEvent
		, eT.ID_TimeClass	= xT.ID_TimeClass

		, eT.IsComplete	= xT.IsComplete
		, eT.MHHP		= xT.MHHP
		, eT.LOS3rd		= xT.LOS3rd
		, eT.FracTime_min	= xT.FracTime_min

		, eT.EventMonth	= xT.[Month]
		, eT.EventDay	= xT.[Day]
		, eT.EventYear	= xT.[Year]
		, eT.EventQTR	= xT.[QTR]
		, eT.YrQtr		= xT.[YrQtr]
				
		, eT.EventofDay	= xT.[EventofDay]
		, eT.vNum		= xT.Vnum
		, eT.StageCount	= xT.StageCount
		, eT.PumpTime	= xT.PumpTime
		, eT.Notes		= xT.Notes

		, eT.ID_GenMainEvent= xT.ID_GenMainEvent
		, eT.ID_Alias		= xT.ID_Alias
		, eT.ID_Camp		= xT.ID_Camp

		, eT.Archive_Notes	= xT.Archive_Notes
		, eT.countSync		= xT.countSync

		, eT.DateModified	= GETDATE()				/* 20220117 */

		--select xT.*

		FROM [SSIS_ENG].[fnRPT_xmlTT_TimeLogs]() xT
			INNER JOIN dbo.FracTime eT 
				ON xT.ID_Pad = eT.ID_Pad AND eT.ID_Pad >= @tID_Pad
					AND xT.rNo - 1 + xT.[minPadRecord] = eT.RecordNo

		WHERE (xT.ID_Pad IS NOT NULL 
				AND xT.ID_Operator IS NOT NULL 
				AND xT.ID_Camp IS NOT NULL 
				AND xT.ID_Crew IS NOT NULL 
				AND xT.ID_Well IS NOT NULL)

		;

END


GO

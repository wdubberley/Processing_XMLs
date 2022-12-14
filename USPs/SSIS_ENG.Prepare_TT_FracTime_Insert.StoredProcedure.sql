USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TT_FracTime_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************
  Created:	KPHAM (2018)
  20190201(v002)- Recoded to optimize run time and join with new version of fnRPT_xmlTT_TimeLogs()
  20190806(v003)- Add countSync 
  20220223(v004)- Add ID_PumpOperator
***************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TT_FracTime_Insert]	
AS
BEGIN

	WITH d_FracTime AS				/* get the list of all events for the loaded XML pads */
		(SELECT fT.ID_FracTime
			, fT.ID_Pad
			, fT.RecordNo
			FROM dbo.FracTime fT
				INNER JOIN (SELECT DISTINCT ID_Pad FROM [SSIS_ENG].[fnRPT_xmlTT_TimeLogs]()) xP ON xP.ID_Pad = fT.ID_Pad
		)

	--/******** INSERT statement 
	INSERT INTO [dbo].[FracTime]
        ([ID_Pad], [ID_Well], [ID_Crew]
		,[ID_PumpOperator], [ID_QAQC], [ID_Engineer], [ID_Supervisor], [ID_CustomerRep]
        ,[StageNo]
        ,[ID_CompletionType]
        ,[StartDateTime]
        ,[ID_PartyType],[ID_MainEvent],[ID_TimeClass]
        ,[IsComplete],[MHHP]
        ,[LOS3rd]
        ,[FracTime_min]

        ,[EventMonth],[EventDay],[EventYear],[EventQTR]
        ,[EventStartDate],[EventEndDate],[EventEndDateTime]

        ,[EventOfDay],[Vnum],[StageCount],[YrQtr],[PumpTime]
        ,[Notes]
		,[RecordNo]
		,ID_GenMainEvent,ID_Alias,ID_Camp
		,Archive_Notes
		,countSync)

	--************* End of INSERT Statement *********************************************/

	SELECT 
		ID_Pad			= xT.ID_Pad	
		, ID_Well		= xT.ID_Well
		, ID_Crew		= xT.ID_Crew

		, ID_PumpOperator= xT.ID_PumpOperator		/* 20220223 */
		, ID_QAQC		= xT.ID_QAQC
		, ID_Engineer	= xT.ID_Engineer
		, ID_Supervisor	= xT.ID_Supervisor
		, ID_CustomerRep= xT.ID_CustomerRep

		, StageNo			= xT.StageNo
		, ID_CompletionType = xT.ID_CompletionType
		 
		, StartDateTime	= xT.StartDateTime
		, ID_PartyType	= xT.ID_Party
		, ID_MainEvent	= xT.ID_MainEvent
		, ID_TimeClass	= xT.ID_TimeClass
		
		, IsComplete	= xT.IsComplete
		, MHHP			= xT.MHHP

		, LOS3rd		= xT.LOS3rd		/* join to dbo.ref_TimeTypes */
		, FracTime_min	= xT.FracTime_min

		, EventMonth	= xT.[Month]
		, EventDay		= xT.[Day]
		, EventYear		= xT.[Year]
		, EventQTR		= xT.[QTR]
		, EventStartDate	= xT.EventStartDate
		, EventEndDate		= xT.EventEndDate
		, EventEndDateTime	= xT.EndDateTime

		, EventOfDay	= xT.[EventOfDay]
		, vNum			= xT.Vnum
		, StageCount	= xT.StageCount
		, YrQtr			= xT.YrQtr
		, PumpTime		= xT.PumpTime
		, Notes			= xT.Notes
		, RecordNo		= xT.rNo - 1 + xT.[minPadRecord]

		, ID_GenMainEvent	= xT.ID_GenMainEvent
		, ID_Alias			= xT.ID_Alias
		, ID_Camp			= xT.ID_Camp
		
		, Archive_Notes	= xT.Archive_Notes
		, countSync		= xT.countSync

		--, fX.*

		FROM [SSIS_ENG].[fnRPT_xmlTT_TimeLogs]() xT
			LEFT JOIN d_FracTime fT 
				ON xT.ID_Pad = fT.ID_Pad 
					AND xT.rNo - 1 + xT.[minPadRecord] = fT.RecordNo
			
		WHERE fT.ID_FracTime IS NULL
			AND (xT.ID_Pad IS NOT NULL AND xT.ID_Pad > 0)
			AND (xT.ID_Well IS NOT NULL AND xT.ID_Well > 0)

		ORDER BY xT.ID_Record

END 

GO

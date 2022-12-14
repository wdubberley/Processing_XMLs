USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************************************************
  Created:	KPHAM (2017)
  Desc:		This USP corrects/backfills the missing Customer/Camp/Crew/Pad/RecordNo in the case that it is missing
  20190202(v002)- Correct code to map correct column names to new fnRPT_xmlTT_TimeLogs() 
  20190418(v003)- Added update to make sure all rows that has minutes should have an EndDate
************************************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[PRE_Process_XMLs_TT_TimeLogs_Update]	
AS
BEGIN

	/******* Update missing EndDate but has Minutes so data isn't being skipped inadvertently *******/
	UPDATE [SSIS_ENG].xmlImport_TT_TimeLogs
		SET [End Date] = CONVERT(DATE, [EndDate/Time])
		WHERE [End Date] IS NULL
			AND [Minutes] IS NOT NULL AND [EndDate/Time] IS NOT NULL

	/******* Update Existing Well Info from tblFracInfo *******/
	UPDATE fxT
		SET Customer = (SELECT TOP 1 t.Customer 
							FROM [SSIS_ENG].xmlImport_TT_TimeLogs t 
							WHERE t.Well=fxT.Well and t.Customer is not null
							ORDER BY t.ID_Record DESC)
			, Camp	= CASE WHEN fxT.ID_Camp IS NULL 
							THEN (SELECT TOP 1 t.Camp 
									FROM [SSIS_ENG].xmlImport_TT_TimeLogs t 
									WHERE t.Well=fxT.Well and t.Camp is not null 
									ORDER BY t.ID_Record DESC) END
			, Crew	= CASE WHEN fxT.ID_Crew IS NULL OR fxT.ID_Crew=0
							THEN (SELECT TOP 1 t.Crew 
									FROM [SSIS_ENG].xmlImport_TT_TimeLogs t 
									WHERE t.Well=fxT.Well and t.Crew is not null
									ORDER BY t.ID_Record DESC) 
						ELSE fxT.Crew END
			, Pad	= CASE WHEN fxT.ID_Pad IS NULL 
							THEN (SELECT TOP 1 t.Pad 
									FROM [SSIS_ENG].xmlImport_TT_TimeLogs t 
									WHERE t.Well=fxT.Well and t.Pad is not null
									ORDER BY t.ID_Record DESC) 
						ELSE fxT.Pad END

			, RecordNo = CASE WHEN fxT.RecordNo IS NULL AND fxT.StickNum IS NOT NULL THEN fxT.StickNum 
							WHEN fxT.RecordNo IS NOT NULL AND fxT.StickNum IS NOT NULL AND fxT.RecordNo <> fxt.StickNum THEN fxT.StickNum
							ELSE fxT.RecordNo END
	--select *
		FROM [SSIS_ENG].fnRPT_xmlTT_TimeLogs() fxT
			
		WHERE fxT.id_pad is null or fxT.id_crew is null or fxT.id_camp is null or fxT.id_well is null or fxT.id_operator is null
			OR ((fxT.RecordNo IS NULL AND fxT.StickNum IS NOT NULL)
				OR (fxT.RecordNo IS NOT NULL AND fxT.StickNum IS NOT NULL AND fxT.RecordNo <> fxt.StickNum))
	;

END 

GO

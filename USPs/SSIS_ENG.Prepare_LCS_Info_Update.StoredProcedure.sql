USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_Info_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_Info_Update]	
AS
BEGIN
	
	UPDATE sI 
		SET sI.ID_Pad			= fX.ID_Pad
			, sI.MacroVersion	= fX.MacroVersion
			, sI.xmlFileName	= fX.xmlFileName
			, sI.xmlDate		= fX.xmlDate
			, sI.DateModified	= GETDATE()
			, sI.PadName		= fX.PadName
	--SELECT *

		FROM [SSIS_ENG].fnRPT_xmlLCS_Info() fX
			INNER JOIN dbo.Location_StrapInfo sI ON sI.ID_LocStrapInfo = fX.ID_LocStrapInfo
			
		WHERE fX.ID_LocStrapInfo IS NOT NULL
	;

END 


GO

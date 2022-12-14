USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LCS_Info_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LCS_Info_Insert]	
AS
BEGIN
	INSERT INTO dbo.Location_StrapInfo
		(ID_Pad, MacroVersion, xmlFileName, xmlDate, PadName)

	SELECT ID_Pad			= fX.ID_Pad
		, MacroVersion		= fX.MacroVersion
		, xmlFileName		= fX.xmlFileName
		, xmlDate			= fX.xmlDate
		, PadName			= fX.PadName

		--, *
		FROM [SSIS_ENG].fnRPT_xmlLCS_Info() fX
			
		WHERE fX.ID_LocStrapInfo IS NULL
			AND fX.ID_Pad IS NOT NULL
	;

END 



GO

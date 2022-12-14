USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLCS_Info]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************
  Created:	KPHAM (2018)
  20191001(v002)- Added rPads to limit Pads to only the recent pads
************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLCS_Info]()
RETURNS TABLE
AS
RETURN 

	WITH rPads AS 
		(SELECT ID_Pad, Field_PadName, Pad_No
			FROM dbo.fnREFs_Pads('') 
			WHERE Flag_Recent = 1)

	SELECT ID_LocStrapInfo	= sL.ID_LocStrapInfo 
		, ID_Pad			= rP.ID_Pad
		, xmlFileName		= xI.[FileName]
		, xmlDate			= xI.xmlDate
		
		, PadName			= rP.Field_PadName-- rP.PadName
		, MacroVersion		= xI.MacroVersion

		--, xI.*
		
		FROM [SSIS_ENG].xmlImport_LCS_Info	xI
			LEFT JOIN rPads					rP ON rP.Field_PadName = xI.PadName 
			LEFT JOIN [dbo].[Location_StrapInfo] sL ON sL.ID_Pad = rP.ID_Pad




GO

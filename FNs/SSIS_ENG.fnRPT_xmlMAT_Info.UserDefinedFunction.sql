USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_Info]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************
  Created:	KPHAM (2016)
  20190211(v002)- Added rPads to limit Pads to only the recent pads
  20190521(v003)- Added xmlVersion
************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_Info]()
RETURNS TABLE
AS
RETURN 

	WITH rPads AS 
		(SELECT DISTINCT ID_Pad, Field_PadName, Pad_No
			FROM dbo.fnREFs_Pads('') 
			WHERE Flag_Recent = 1
			)

	SELECT ID_MaterialInfo	= sM.ID_MaterialInfo 
		, ID_Pad			= rP.ID_Pad
		, xmlFileName		= xI.[FileName]
		, xmlDate			= xI.xmlDate
		, xmlVersion		= xI.MacroVersion

		, PadName	= rP.Field_PadName

		--, xI.*
		
		FROM [SSIS_ENG].xmlImport_MAT_Info	xI
			LEFT JOIN rPads					rP ON rP.Field_PadName = xI.PadName
			LEFT JOIN dbo.Material_Info		sM ON sM.ID_Pad = rP.ID_Pad


GO

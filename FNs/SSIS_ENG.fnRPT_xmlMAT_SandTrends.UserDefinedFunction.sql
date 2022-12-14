USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_SandTrends]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_SandTrends]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_MaterialInfo		= xI.ID_MaterialInfo
		, [ID_SandInfo]			= sSI.ID_SandInfo
		
		, [RowNo]				= xST.[RowNo]
		, [Date_Time]			= xST.[Date_Time]
		, [Well]				= xST.[Well]
		, [StageNo]				= ISNULL(xST.[Stage],0)
		, [Design]				= xST.[Design]
		, [Shut_In]				= xST.[Shut_In]
		, [Screw]				= xST.[Shut_In]
		, [lbl_Rev]				= xST.[lbl_Rev]
		, [BlenderNo]			= xST.[BlenderNo]
		, [TActPump]			= xST.[TActPump]

		, [Pad_Variance]		= xST.[Pad_Variance]
		, [Design_Qty]			= xST.[Design_Qty]
		, [Screw_Qty]			= xST.[Screw_Qty]
		, [PPR]					= xST.[PPR]

		--, [ID_FracInfo]

		, xmlFileName			= xST.[FileName]
		, SandName				= xST.SandName

		, [ID_Pad]				= sMI.ID_Pad

		--, xST.*
		--, xI.*
		
		FROM [SSIS_ENG].xmlImport_MAT_SandTrends			xST
			INNER JOIN [SSIS_ENG].fnRPT_xmlMAT_SandInfo()	xI ON xI.xmlFileName = xST.[FileName] AND xI.SandName = xST.SandName
			INNER JOIN [SSIS_ENG].mapping_Proppants			rPpt ON rPpt.ProppantName = xST.SandName
			INNER JOIN dbo.Material_SandInfo				sSI ON sSI.ID_MaterialInfo = xI.ID_MaterialInfo AND sSI.ID_Proppant = rPPt.ID_Proppant
			INNER JOIN dbo.Material_Info					sMI ON sMI.ID_MaterialInfo = sSI.ID_MaterialInfo

		WHERE xST.Date_Time IS NOT NULL
			
	;


GO

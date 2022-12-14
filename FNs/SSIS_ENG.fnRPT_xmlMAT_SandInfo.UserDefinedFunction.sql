USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_SandInfo]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************************
  Created:	KPHAM (2016)
  20191031(v002)- Correct cte_BOL_Summary to LEFT JOIN (to include 0 BOLs SandInfo)
*************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_SandInfo]()
RETURNS TABLE
AS
RETURN 

	WITH cte_BOL_Summary AS
		(SELECT DISTINCT xB.[FileName]
			, xB.SandName
			, t_BOL_Weight	= SUM(xB.BOL_Weight)
			, t_OnLocation	= SUM(xB.Left_on_Location)

			FROM [SSIS_ENG].xmlImport_MAT_BOLDetails xB
			GROUP BY xB.[FileName]
				, xB.SandName
		)

	SELECT ID_MaterialInfo		= xI.ID_MaterialInfo
		, ID_Proppant			= rPpt.ID_Proppant
		, DesignPadVariance		= xS.DesignPadVariance
		, ScrewVariance			= xS.ScrewVariance
		, ShutInVariance		= xS.ShutInVariance
		, Est_TrucksLeftToDeliver = xS.Est_TrucksLeftToDeliver
		, Vol_Delivered			= xB.t_BOL_Weight
		, Avg_DeliveryTime		= xS.Avg_DeliveryTime
		, Vol_LeftToDeliver		= CASE WHEN ISNUMERIC(xS.Vol_TotalDesign)=1 THEN xS.Vol_TotalDesign - xB.t_BOL_Weight ELSE NULL END --xS.Vol_LeftToDeliver
		, Vol_OnLocation		= CASE WHEN xB.t_OnLocation IS NULL THEN 0 ELSE xB.t_OnLocation END
		, Vol_TotalDesign		= xS.Vol_TotalDesign
		, Est_StageVolAvailable	= xS.Est_StageVolAvailable
		, Total_Records			= xS.Total_Records
		
		, xmlFileName			= xI.xmlFileName
		, SandName				= xS.SandName

		--, xS.*
				
		FROM [SSIS_ENG].xmlImport_MAT_SandInfo			xS
			INNER JOIN [SSIS_ENG].fnRPT_xmlMAT_Info()	xI ON xI.xmlFileName = xS.[FileName]
			INNER JOIN [SSIS_ENG].mapping_Proppants		rPpt ON rPpt.ProppantName = xS.SandName
			LEFT JOIN cte_BOL_Summary					xB ON xB.[FileName] = xS.[FileName] AND xB.SandName=xS.[SandName]

	;

GO

USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages_ChemTotals]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************************
  Created:	KPHAM (20190118)
  20220303(v002)- Adjusted join parameter to compare Formation on NULL as ''
******************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages_ChemTotals]()
RETURNS TABLE
AS
RETURN 
	
	SELECT xCT.*
		, ctCTE.ID_FracStage
		, ctCTE.ID_FracInfo
		, lC.ID_Chemical

		FROM [SSIS_ENG].xmlImport_TS_ChemTotals xCT
			INNER JOIN dbo.LOS_Chemicals lC ON lC.ChemicalName = xCT.ChemicalName
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header ctCTE ON ctCTE.WellName = xCT.Well AND ctCTE.StageNo = xCT.INTERVAL_No
																AND (ISNULL(ctCTE.Formation,'') = ISNULL(xCT.Formation,''))

	;

GO

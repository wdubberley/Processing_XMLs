USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_Charge_Chemicals]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************
  20190305(v002)- Added ChargeCode
  20190308(v003)- Modified ChargeCode to read only 1st matching item from FieldQuote_Items
  20190827(v004)- Add ChargeUnit from dbo.FieldQuote if exists
  20190830(v005)- Add ID_Unit
  20190830(v006)- Added ClientProvided flag from dbo.FieldQuote_Items
  20210211(v007)- Adjusted Charge_Unit to record by quoted UOM and change default to UOM_Chem if none is present
  20210427(v008)- Adjusted Discount_Percent to decimal (divide by 100) if ABS is out of range
  20220303(v009)- Adjusted join parameter to compare Formation on NULL as ''
*****************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_Charge_Chemicals]()
RETURNS TABLE
AS
RETURN 

	SELECT Stage	= xCC.Stage
		, Well		= xCC.Well
		, Formation = xCC.Formation

		, ChemicalName	= xCC.ChemicalName
		, Chemical_Desc = xCC.Chemical_Desc
		, ChargeCode	= ISNULL((SELECT TOP 1 Qi.ChargeCode 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
										AND Qi.ID_ChargeType = 24 
										AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = xCC.ChemicalName)
								, lC.PartNo)
		, ChargeUnit	= ISNULL((SELECT TOP 1 Qi.ChargeUnit 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
										AND Qi.ID_ChargeType = 24 
										AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = xCC.ChemicalName)
								, ISNULL(sCTE.UOM_Chem,'GAL'))

		, ClientProvided= ISNULL((SELECT TOP 1 Qi.ClientProvided 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
										AND Qi.ID_ChargeType = 24 
										--AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = xCC.ChemicalName)
								, 0)

		--, ID_Unit	= ISNULL((SELECT TOP 1 rU.ID_Unit -- Qi.ChargeUnit 
		--							FROM dbo.FieldQuote_Items Qi
		--								INNER JOIN dbo.ref_Units rU ON rU.UnitBase = 'GAL' AND rU.UnitName = Qi.ChargeUnit
		--							WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
		--								AND Qi.ID_ChargeType = 24 
		--								AND ISNUMERIC(Qi.ChargeCode) = 1
		--								AND Qi.AlternateName = xCC.ChemicalName)
		--						, 7)

		, Chemical_Price	= xCC.Chemical_Price
		, Chemical_Quantity	= xCC.Chemical_Quantity
		, Chemical_NoCost	= xCC.ChemicalNoCost
		, Chemical_Cost		= xCC.ChemicalCost
		, Chemical_Discount = ISNULL((SELECT TOP 1 Qi.Discount 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
										AND Qi.ID_ChargeType = 24 
										AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = xCC.ChemicalName)
								, 0)
							--CASE WHEN ABS(ISNULL(xCC.Chemical_Discount, 0)) > 1 THEN ISNULL(xCC.Chemical_Discount, 0) / 100.0000
							--	ELSE ISNULL(xCC.Chemical_Discount, 0) END

		, ID_Record		= xCC.ID_Record
		, ID_FracInfo	= sCTE.ID_FracInfo
		, ID_FracStage	= sCTE.ID_FracStage
		, ID_Chemical	= lC.ID_Chemical

		FROM [SSIS_ENG].xmlImport_TS_ChargesChems		xCC 
			LEFT JOIN [SSIS_ENG].vw_FracStages_Header	sCTE ON sCTE.WellName = xCC.Well AND sCTE.StageNo = xCC.Stage 
																AND (ISNULL(sCTE.Formation,'') = ISNULL(xCC.Formation,''))
			INNER JOIN dbo.LOS_Chemicals			lC ON lC.ChemicalName = xCC.ChemicalName
			
	;


GO

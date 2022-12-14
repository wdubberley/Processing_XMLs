USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_Charge_Proppants]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************
  20210313(v008)- Added filter to not pull Quantity zero
  20210426(v009)- Added additional quote filter to also try matching Proppant_Description
  20210427(v010)- Adjusted Discount_Percent to decimal (divide by 100) if ABS is out of range
  20210525(v011)- Adjusted Proppant_Discount to .999999 to avoid dividing by Zero (corrected code :: removed last line of test filter :: 20210601)
  20210813(v012)- Adjusted Proppant_Price to 0 to avoid dividing by Zero
  20220303(v013)- Adjusted join parameter to compare Formation on NULL as ''
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_Charge_Proppants]()
RETURNS TABLE
AS
RETURN 

	WITH cte_Ppt AS
		(SELECT DISTINCT ProppantName = REPLACE(CASE WHEN xCP.Proppant_Desc IS NULL THEN xCP.Proppant_Name ELSE xCP.Proppant_Desc END, ' Actual Weight','')	
			, proppant_DESC
			FROM [SSIS_ENG].xmlImport_TS_ChargesProppants xCP
		)
		
		SELECT ID_Record	= xCP.ID_Record
			, Well			= xCP.Well
			, Stage			= xCP.Stage
			, Formation		= xCP.Formation
			, Proppant_Name = xCP.Proppant_Name
			, Proppant_Desc = xCP.Proppant_Desc

			/**** ON Default LBS unit ****/
			, Proppant_Price	= CASE WHEN (CASE WHEN xCP.Proppant_UOM IN ('LBS','LB','KG','KGS') THEN xCP.Proppant_Quantity
																			ELSE CONVERT(DECIMAL(18,4),ISNULL(xCP.Proppant_Quantity,1)) * rUOM.Coefficient END
																* (1 - CASE WHEN xCP.Proppant_Discount = 1 THEN .999999 ELSE xcP.Proppant_Discount END)
																) = 0 THEN 0  /* 20210813 */
										ELSE CONVERT(DECIMAL(18,6), 
											CASE WHEN xcP.Proppant_UOM IN ('LBS','LB','KG','KGS') THEN xCP.Proppant_Price 
												ELSE ((xCP.Proppant_Cost 
															/ (CASE WHEN xCP.Proppant_UOM IN ('LBS','LB','KG','KGS') THEN xCP.Proppant_Quantity
																			ELSE CONVERT(DECIMAL(18,4),ISNULL(xCP.Proppant_Quantity,1)) * rUOM.Coefficient END
																* (1 - CASE WHEN xCP.Proppant_Discount = 1 THEN .999999 ELSE xcP.Proppant_Discount END) /* 20210525 */
																)
														)
													)
												END
										)
									END
			, Proppant_Quantity	= CASE WHEN xCP.Proppant_UOM IN ('LBS','LB','KG','KGS') THEN xCP.Proppant_Quantity
									ELSE CONVERT(DECIMAL(18,4),ISNULL(xCP.Proppant_Quantity,0)) * rUOM.Coefficient END
			, Proppant_NoCost	= CASE WHEN xCP.Proppant_UOM IN ('LBS','LB','KG','KGS') THEN xCP.Proppant_NoCost
									ELSE CONVERT(DECIMAL(18,4),ISNULL(xCP.Proppant_NoCost,0)) * rUOM.Coefficient END
			
			, Proppant_Discount = ISNULL((SELECT TOP 1 Qi.Discount 
										FROM dbo.FieldQuote_Items Qi
										WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
											AND Qi.ID_ChargeType = 25 
											AND ISNUMERIC(Qi.ChargeCode) = 1
											AND Qi.AlternateName = cPpt.ProppantName
											AND Qi.ChargeDescription = xCP.Proppant_Name	/* 20210426 */
											)
									, CASE WHEN ABS(ISNULL(xCP.Proppant_Discount, 0)) > 1 THEN ISNULL(xCP.Proppant_Discount, 0) / 100.0000
										ELSE ISNULL(xCP.Proppant_Discount, 0) END
									)

			, Proppant_Cost		= xCP.Proppant_Cost
			, Proppant_UOM		= sCTE.UOM_Sand

			/**** ON Quoted unit ****/
			, Customer_Price	= xCP.Proppant_Price
			, Customer_Quantity = xCP.Proppant_Quantity
			, Customer_Cost		= xCP.Proppant_Cost
			, Customer_NoCost	= xCP.Proppant_NoCost
			, Customer_UOM		= xCP.Proppant_UOM

			, ChargeCode	= ISNULL((SELECT TOP 1 Qi.ChargeCode 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
										AND Qi.ID_ChargeType = 25 
										AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = cPpt.ProppantName
										AND Qi.ChargeDescription = xCP.Proppant_Name	/* 20210426 */
										)
								, rPpt.PartNo)
			
			, ClientProvided= ISNULL((SELECT  TOP 1 Qi.ClientProvided 
									FROM dbo.FieldQuote_Items Qi
									WHERE Qi.ID_FracInfo = sCTE.ID_FracInfo
										AND Qi.ID_ChargeType = 25 
										--AND ISNUMERIC(Qi.ChargeCode) = 1
										AND Qi.AlternateName = cPpt.ProppantName)
								, 0)

			, ID_FracInfo	= sCTE.ID_FracInfo
			, ID_FracStage	= sCTE.ID_FracStage
			, ID_Proppant	= mPpt.ID_Proppant
			, ProppantName	= mPpt.ProppantName

			FROM [SSIS_ENG].xmlImport_TS_ChargesProppants	xCP
				INNER JOIN cte_Ppt							cPpt	ON cPpt.proppant_DESC = xCP.Proppant_Desc 
				INNER JOIN [SSIS_ENG].mapping_Proppants		mPpt	ON mPpt.ProppantName = cPpt.ProppantName 
				INNER JOIN [dbo].LOS_Proppants				rPpt	ON rPpt.ID_Proppant = mPpt.ID_Proppant
				LEFT JOIN [SSIS_ENG].vw_FracStages_Header	sCTE	ON sCTE.WellName = xCP.Well AND sCTE.StageNo = xCP.Stage 
																		AND (ISNULL(sCTE.Formation,'') = ISNULL(xCP.Formation,''))

				INNER JOIN [dbo].ref_Units					rUOM	ON rUOM.UnitName = xCP.Proppant_UOM AND rUOM.UnitBase = 'LBS'

		WHERE xCP.Proppant_Quantity <> 0
			--and xCP.Well like '%lkr%'
			--and xcp.proppant_discount = 1
		;

GO

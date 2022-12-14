USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeChemical_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************************************
  20190301(v003)- Added ChargeCode to start recording ChargeCode per version from updated FieldQuote_Items daily
  20190827(v004)- Added Charge_Unit from FieldQuote_Items
  20200818(v006)- Added filter to insert only non-ClientProvided items
  20210213(v007)- Added ChargeUnit to join condition to also check for UOM
**********************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeChemical_Insert]	
AS
BEGIN
	INSERT INTO dbo.Charge_Chemicals
		(ID_FracStage, ID_Chemical
		, Chemical_Desc, ChargeCode, Charge_Unit
		, Chemical_Price, Chemical_Quantity, Chemical_NoCost, Chemical_Cost, Chemical_Discount
		, ID_FracInfo)

	SELECT xCC.ID_FracStage
		, xCC.ID_Chemical
		, xCC.Chemical_Desc
		, xCC.ChargeCode
		, xCC.ChargeUnit

		, xCC.Chemical_Price
		, xCC.Chemical_Quantity
		, xCC.Chemical_NoCost
		, xCC.Chemical_Cost
		, xCC.Chemical_Discount
		
		, xCC.ID_FracInfo
	
		FROM [SSIS_ENG].[fnRPT_xmlTS_Charge_Chemicals]() xCC
			LEFT JOIN dbo.Charge_Chemicals eCC 
				ON eCC.ID_FracStage = xCC.ID_FracStage 
					AND eCC.ID_Chemical=xCC.ID_Chemical 
					AND eCC.ChargeCode = xCC.ChargeCode									/* 20190301 */
					AND eCC.Charge_Unit = xCC.ChargeUnit								/* 20210213 */
					
		WHERE (xCC.ID_FracStage IS NOT NULL AND xCC.ID_FracInfo IS NOT NULL)			/* Must have ID_FracInfo and ID_FracStage */
			AND eCC.ID_ChargeChem IS NULL
			AND (xCC.ClientProvided = 0)												/* 20200818 - ONLY LOS charge volume */


		ORDER BY xCC.ID_FracInfo, xCC.ID_FracStage, xCC.ID_Record						/* 20190301 */			
	;

END 

GO

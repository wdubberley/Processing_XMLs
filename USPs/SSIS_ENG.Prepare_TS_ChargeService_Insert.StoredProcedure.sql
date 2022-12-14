USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeService_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************************************
  20190303(v004)- Added ChargeCode to start recording ChargeCode per version from updated FieldQuote_Items daily
  20190827(v005)- Added Charge_Unit to start recording ChargeUnit per version from FieldQuote_Items
  20220512(v006)- Added Bonus_Eligible for CAN job
*******************************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeService_Insert]	
AS
BEGIN

	INSERT INTO dbo.Charge_Services
		(ID_FracStage, ID_Service
		, ChargeCode, Charge_Unit
		, Service_Price, Service_Quantity, Service_Cost, IsPassthrough, Service_Discount
		, Bonus_Eligible
		, ID_FracInfo, ID_ChargeOption)

	SELECT ID_FracStage	= xCS.ID_FracStage
		, ID_Service	= xCS.ID_ChargeService
		, ChargeCode	= xCS.ChargeCode
		, Charge_Unit	= xCS.ChargeUnit

		, Service_Price		= xCS.Service_Price
		, Service_Quantity	= xCS.ServiceQuantity
		, Service_Cost		= xCS.ServiceCost
		, IsPassthrough		= CASE WHEN xCS.Item_Passthrough IN (66,67) THEN 1 ELSE 0 END
		, Service_Discount	= xCS.Service_Discount
		, Bonus_Eligible	= xCS.Bonus_Eligible										/*20220512*/	

		, ID_FracInfo		= xCS.ID_FracInfo
		, ID_ChargeOption	= CASE WHEN xCS.Item_Passthrough IN (66) THEN 67 ELSE xCS.Item_Passthrough END

		FROM  [SSIS_ENG].[fnRPT_xmlTS_Charge_Services]()	xCS
			LEFT JOIN dbo.Charge_Services				eCS 
				ON eCS.ID_FracStage = xCS.ID_FracStage 
					AND eCS.ID_Service = xCS.ID_ChargeService
					AND eCS.ChargeCode = xCS.ChargeCode

		WHERE (xCS.ID_FracStage IS NOT NULL AND xCS.ID_FracInfo IS NOT NULL)			/* Must have ID_FracInfo and ID_FracStage */
			AND eCS.ID_ChargeService IS NULL

		ORDER BY xCS.ID_FracInfo, xCS.ID_FracStage, xCS.ID_Record
	;


END 

GO

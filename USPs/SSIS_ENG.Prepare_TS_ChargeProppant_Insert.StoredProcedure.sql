USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_ChargeProppant_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************************************
  20190302(v002)- Added ChargeCode to start recording ChargeCode per version from updated FieldQuote_Items daily
  20190827(v003)- Added Proppant_UOM, Customer_Price, Customer_Quantity, Customer_Cost, Customer_UOM
  20200818(v004)- Added filter to insert only non-ClientProvided items
  20210213(v005)- Added Proppant_UOM to join condition to also check for UOM change
**********************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_ChargeProppant_Insert]	
AS
BEGIN
	INSERT INTO dbo.Charge_Proppants
		(ID_FracStage, ID_Proppant
		, Proppant_Name, Proppant_Desc, ChargeCode
		, Proppant_Price, Proppant_Quantity, Proppant_NoCost, Proppant_Cost, Proppant_Discount, Proppant_UOM
		, Customer_Price, Customer_Quantity, Customer_Cost, Customer_NoCost, Customer_UOM
		, ID_FracInfo)

	SELECT xCP.ID_FracStage
		, xCP.ID_Proppant
		, xCP.Proppant_Name
		, xCP.Proppant_Desc
		, xCP.ChargeCode

		, xCP.Proppant_Price
		, xCP.Proppant_Quantity
		, xCP.Proppant_NoCost
		, xCP.Proppant_Cost
		, xCP.Proppant_Discount
		, xCP.Proppant_UOM

		, xCP.Customer_Price
		, xCP.Customer_Quantity
		, xCP.Customer_Cost
		, xCP.Customer_NoCost
		, xCP.Customer_UOM

		, xCP.ID_FracInfo
	
		FROM [SSIS_ENG].[fnRPT_xmlTS_Charge_Proppants]() xCP
			LEFT JOIN dbo.Charge_Proppants eCP
				ON eCP.ID_FracStage = xCP.ID_FracStage 
					AND eCP.ID_Proppant = xCP.ID_Proppant
					AND eCP.ChargeCode = xCP.ChargeCode									/* 20190302 */
					AND eCP.Proppant_UOM = xCP.Proppant_UOM								/* 20210213 */

		WHERE (xCP.ID_FracStage IS NOT NULL AND xCP.ID_FracInfo IS NOT NULL)			/* Must have ID_FracInfo and ID_FracStage */
			AND eCP.ID_ChargeProppant IS NULL
			AND (xCP.ClientProvided = 0)												/* 20200818 - ONLY LOS charge volume */

		ORDER BY xCP.ID_FracInfo, xCP.ID_FracStage, xCP.ID_Record						/* 20190301 */
	;

END 

GO

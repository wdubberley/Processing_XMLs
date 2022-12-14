USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_FuelBOL_UPDATE]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20201030)
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_FuelBOL_UPDATE]	
AS
BEGIN
	
	UPDATE mF 
	SET [Ticket_BOLNum]		= xF.[Ticket_BOLNum]
		, [UnitNo]			= xF.[UnitNo]
		, [PONum]			= xF.[PONum]
		, [BOL_Date]		= xF.[BOL_Date]
		, [Supplier]		= xF.[Supplier]
		, [ShipFrom]		= xF.[ShipFrom]
		, [ShipTo]			= xF.[ShipTo]
		, [Notes]			= xF.[Notes]
		, [Consignor_Name]	= xF.[Consignor_Name]
		, [Driver_Name]		= xF.[Driver_Name]
		, [ERP_Notes]		= xF.[ERP_Notes]
	
		, [FuelClear_gal]	= xF.[FuelClear_gal]
		, [FuelClear_price]	= xF.[FuelClear_price]
		, [FuelDye_gal]		= xF.[FuelDye_gal]	
		, [FuelDye_price]	= xF.[FuelDye_price]	
		, [FuelTotal_Cost]	= xF.[FuelTotal_Cost]
		, [FuelTotal_Gal]	= xF.[FuelTotal_Gal]

		, [CNG_MCF]	= xF.[CNG_MCF]
		, [LNG_gal]	= xF.[LNG_gal]
		
		--, xB.*
		, mF.DateModified	= GETDATE()
	
		FROM [SSIS_ENG].[fnRPT_xmlMAT_FuelBOLs]()		xF
			INNER JOIN [dbo].[Material_FuelBOLs]	mF ON (mF.ID_MaterialInfo = xF.ID_MaterialInfo AND mF.FuelTicket = xF.FuelTicket) 

		WHERE xF.BOL_Date IS NOT NULL

	;

END 

GO

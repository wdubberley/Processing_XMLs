USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_FuelBOL_INSERT]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************
  Created:	KPHAM (20201030)
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_FuelBOL_INSERT]	
AS
BEGIN
	
	INSERT INTO [dbo].[Material_FuelBOLs]
        ([ID_MaterialInfo], [FuelTicket]
		, [Ticket_BOLNum], [UnitNo], [PONum], [BOL_Date]
		, [Supplier], [ShipFrom], [ShipTo], [Notes]
		, [Consignor_Name], [Driver_Name], [ERP_Notes]
		, [FuelClear_gal], [FuelClear_price]
		, [FuelDye_gal], [FuelDye_price]	
		, [FuelTotal_Cost], [FuelTotal_Gal]
		, [CNG_MCF], [LNG_gal]
		)

	SELECT [ID_MaterialInfo]= xF.[ID_MaterialInfo]
        , [FuelTicket]		= xF.[FuelTicket]

		, [Ticket_BOLNum]	= xF.[Ticket_BOLNum]
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
		
		FROM [SSIS_ENG].[fnRPT_xmlMAT_FuelBOLs]()	xF
			LEFT JOIN [dbo].[Material_FuelBOLs]	sF ON (sF.[ID_MaterialInfo] = xF.[ID_MaterialInfo] AND sF.[FuelTicket] = xF.[FuelTicket]) 
		
		WHERE (xF.[ID_MaterialInfo] IS NOT NULL AND sF.ID_FuelBOL IS NULL)
			AND xF.BOL_Date IS NOT NULL

		ORDER BY xF.[ID_MaterialInfo]
			, xF.[FuelTicket]
	;

END 

GO

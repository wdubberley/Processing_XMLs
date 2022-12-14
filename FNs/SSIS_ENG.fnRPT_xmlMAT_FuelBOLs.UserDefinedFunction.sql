USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_FuelBOLs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20201030)
  20210105(v002)- Correct join to match xF.xmlFileName
*************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_FuelBOLs]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_MaterialInfo	= xI.ID_MaterialInfo
		, [FuelTicket]		= xF.[FuelTicket]
		
		, [Ticket_BOLNum]	= xF.[Ticket_BOLNum]
		, [UnitNo]			= xF.[UnitNo]
		, [PONum]			= xF.[PONum]
		, [BOL_Date]		= xF.[BOL_Date]
		, [Supplier]		= xF.[Supplier]
		, [ShipFrom]		= xF.[ShipFrom]
		, [ShipTo]			= xF.[ShipTo]
		, [Notes]			= xF.[Notes]
		, [Consignor_Name]	= LTRIM(RTRIM(xF.[Consignor_Name]))
		, [Driver_Name]		= LTRIM(RTRIM(xF.[Driver_Name]))
		, [ERP_Notes]		= xF.[ERP_Notes]
	
		, [FuelClear_gal]	= xF.[FuelClear_gal]
		, [FuelClear_price]	= xF.[FuelClear_price]
		, [FuelDye_gal]		= xF.[FuelDye_gal]	
		, [FuelDye_price]	= xF.[FuelDye_price]	
		, [FuelTotal_Cost]	= xF.[FuelTotal_Cost]
		, [FuelTotal_Gal]	= xF.[FuelTotal_Gal]

		, [CNG_MCF]	= xF.[CNG_MCF]
		, [LNG_gal]	= xF.[LNG_gal]

		, RowID					= ROW_NUMBER() OVER (ORDER BY xF.[ID_Record])

		, xF.xmlFileName
				
		FROM [SSIS_ENG].[xmlImport_MAT_FuelBOLs]		xF
			INNER JOIN [SSIS_ENG].fnRPT_xmlMAT_Info()	xI ON xI.xmlFileName = xF.xmlFileName
			
	;
	
GO

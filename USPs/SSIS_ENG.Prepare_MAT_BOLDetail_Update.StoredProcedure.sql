USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_BOLDetail_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************
  20190623(v002)- Add Carrier_Name
  20210104(v003)- Add Approved_Mileage; Removed Delivery_Time (not used since 2018)
  20210104(v004)- Add DateModified for tracking purpose; Removed Well/Stage
  20220331(v005)- Removed Box_Transfer
******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_BOLDetail_Update]	
AS
BEGIN

	UPDATE sB
		SET sB.[BOLDate]		= xB.[BOLDate]
		, sB.[Facility]			= xB.[Facility]
		, sB.[Ordered]			= xB.[Ordered]
		, sB.[Arrived]			= xB.[Arrived]
		--, sB.[Delivery_Time]	= xB.[Delivery_Time]
		, sB.[PO]				= xB.[PO]
		, sB.[Trucking_BOL]		= xB.[Trucking_BOL]
		, sB.[Vendor_BOL]	 	= xB.[Vendor_BOL]
		, sB.[BOL_Weight]		= xB.[BOL_Weight]
		, sB.[Left_on_Location]	= xB.[Left_on_Location]
		, sB.[Box__MB__Number]	= xB.[Box__MB__Number]
		--, sB.[Well]				= xB.[Well]
		--, sB.[Stage]			= xB.[Stage]
		, sB.[Comment]			= xB.[Comment]
		, sB.Return_Weight		= xB.[Return_Weight]
		--, sB.[Box_Transfer]		= xB.[Box_Transfer]
		, sB.[Carrier_Name]		= xB.[Carrier_Name]
		, sB.Approved_Mileage	= xB.[Approved_Mileage]		/* 20210104 */

		, sB.DateModified	= GETDATE()
	
	--select xB.*
		FROM [SSIS_ENG].[fnRPT_xmlMAT_BOLDetails]()	xB
			INNER JOIN dbo.Material_BOLDetails	sB ON sB.ID_SandInfo = xB.ID_SandInfo AND sB.SI_Number=xB.SI_Number
			INNER JOIN dbo.Material_Info		mI ON mI.ID_MaterialInfo = sB.ID_MaterialInfo 
	;

END 

GO

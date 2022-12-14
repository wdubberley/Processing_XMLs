USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_BOLDetail_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/***********************************************************************
  20190623(v002)- Add Carrier_Name
  20210104(v003)- Add Approved_Mileage; Remove Delivery_Time (not used since 2018)
  20210105(v004)- Remove Well/Stage (no longer needed)
************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_BOLDetail_Insert]	
AS
BEGIN
	
	INSERT INTO dbo.[Material_BOLDetails]
		([ID_MaterialInfo]
		, [ID_SandInfo]
		, [SI_Number]
		, [BOLDate]
		, [Facility]
		, [Ordered]
		, [Arrived]
		--, [Delivery_Time]								/* Phasing out 20180221 to PO */
		, [PO]
		, [Trucking_BOL]
		, [Vendor_BOL]
		, [BOL_Weight]
		, [Left_on_Location]
		, [Box__MB__Number]
		--, [Well]
		--, [Stage]
		, [Comment]
		, [Return_Weight]
		--, [Box_Transfer]								/* Phasing out 20190623 to Carrier_Name */
		, [Carrier_Name]
		, [Approved_Mileage]							/* 20210104- Phasing out Ordered & Replace with Approved_Mileage on XML Schema */
		)

	SELECT ID_MaterialInfo		= xB.ID_MaterialInfo
		, ID_SandInfo			= xB.ID_SandInfo

		, [SI_Number]			= xB.[SI_Number]
		, [BOLDate]				= CONVERT(DATETIME,xB.[BOLDate])
		, [Facility]			= xB.[Facility]
		, [Ordered]				= xB.[Ordered]
		, [Arrived]				= xB.[Arrived]
		--, [Delivery_Time]		= xB.[Delivery_Time]
		, [PO]					= xB.[PO]
		, [Trucking_BOL]		= xB.[Trucking_BOL]
		, [Vendor_BOL]			= xB.[Vendor_BOL]
		, [BOL_Weight]			= xB.[BOL_Weight]
		, [Left_on_Location]	= xB.[Left_on_Location]
		, [Box__MB__Number]		= xB.[Box__MB__Number]
		--, [Well]				= xB.[Well]
		--, [Stage]				= xB.[Stage]
		, [Comment]				= xB.[Comment]
		, [Return_Weight]		= xB.[Return_Weight]
		--, [Box_Transfer]		= xB.[Box_Transfer]
		, [Carrier_Name]		= xB.[Carrier_Name]
		, [Approved_Mileage]	= xB.[Approved_Mileage]

		--, xB.*
	
		FROM [SSIS_ENG].[fnRPT_xmlMAT_BOLDetails]()	xB
			LEFT JOIN dbo.Material_BOLDetails	sB ON (sB.ID_SandInfo = xB.ID_SandInfo AND sB.SI_Number=xB.SI_Number) 

		WHERE sB.ID_BOLDetail IS NULL
	;

END 

GO

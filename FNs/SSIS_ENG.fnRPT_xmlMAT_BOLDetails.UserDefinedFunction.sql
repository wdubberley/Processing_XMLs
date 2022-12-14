USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_BOLDetails]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  20190623(v002)- Added Carrier Name
  20210102(v003)- Removed filter of BOLDate (need to check why if this is on it takes longer to insert)
  20210104(v004)- Added Approved_Mileage
  20210105(v005)- Removed Well/Stage (no longer needed)
  20211103(v006)- Updated scripts to improve loading time
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_BOLDetails]()
RETURNS --TABLE
	@tblMAT_BOLs TABLE (ID_MaterialInfo INT, ID_SandInfo INT
			, [SI_Number] INT,	[BOLDate] [nvarchar](50), [Facility] [nvarchar](255), [Ordered] [datetime], [Arrived] [datetime]
			, [Delivery_Time] [datetime] NULL, [PO] [nvarchar](255) NULL, [Trucking_BOL] [nvarchar](255) NULL, [Vendor_BOL] [nvarchar](255) NULL
			, [BOL_Weight] [decimal](18, 2) NULL, [Left_on_Location] [decimal](18, 2) NULL, [Box__MB__Number] [nvarchar](50) NULL
			, [Comment] [nvarchar](max) NULL
			, [Return_Weight] [decimal](18, 2) NULL, [Box_Transfer] [nvarchar](50) NULL, [Carrier_Name] [nvarchar](255) NULL, [Approved_Mileage] [float] NULL
			, [xmlFileName] [nvarchar](255) NOT NULL, [SandName] [nvarchar](255) NOT NULL
			)
AS
BEGIN 

	/************* TEST 
	declare @tblMAT_BOLs TABLE (ID_MaterialInfo INT, ID_SandInfo INT
			, [SI_Number] INT,	[BOLDate] [nvarchar](50), [Facility] [nvarchar](255), [Ordered] [datetime], [Arrived] [datetime]
			, [Delivery_Time] [datetime] NULL, [PO] [nvarchar](255) NULL, [Trucking_BOL] [nvarchar](255) NULL, [Vendor_BOL] [nvarchar](255) NULL
			, [BOL_Weight] [decimal](18, 2) NULL, [Left_on_Location] [decimal](18, 2) NULL, [Box__MB__Number] [nvarchar](50) NULL
			, [Comment] [nvarchar](max) NULL
			, [Return_Weight] [decimal](18, 2) NULL, [Box_Transfer] [nvarchar](50) NULL, [Carrier_Name] [nvarchar](255) NULL, [Approved_Mileage] [float] NULL
			, [xmlFileName] [nvarchar](255) NOT NULL, [SandName] [nvarchar](255) NOT NULL
			)
	--*******************************************************************/

	declare @tbl_Sands as table (ID_MaterialInfo INT, ID_Proppant INT, ID_SandInfo INT, SandName VARCHAR(100), mFileName VARCHAR(MaX))

	insert into @tbl_Sands
	select ID_MaterialInfo	= mSI.ID_MaterialInfo
			, ID_Proppant	= mSI.ID_Proppant
			, ID_SandInfo	= mSI.ID_SandInfo
			, SandName		= xSI.SandName
			, mFileName		= xSI.xmlFileName
			from [SSIS_ENG].fnRPT_xmlMAT_SandInfo()		xSI
				inner join [dbo].[Material_SandInfo]	mSI On mSI.ID_MaterialInfo = xSI.ID_MaterialInfo and mSI.ID_Proppant = xSI.ID_Proppant




	insert into @tblMAT_BOLs
	SELECT ID_MaterialInfo		= xI.ID_MaterialInfo
		, ID_SandInfo			= xI.ID_SandInfo
		
		, [SI_Number]			= xB.[SI_Number]
		, [BOLDate]				= xB.[BOLDate]
		, [Facility]			= xB.[Facility]
		, [Ordered]				= xB.[Ordered]
		, [Arrived]				= xB.[Arrived]
		, [Delivery_Time]		= xB.[Delivery_Time]
		, [PO]					= xB.[PO]
		, [Trucking_BOL]		= CASE WHEN xB.[Trucking_BOL] IS NULL THEN xB.Load_Number ELSE xB.Trucking_BOL END
		, [Vendor_BOL]			= xB.[Vendor_BOL]
		, [BOL_Weight]			= xB.[BOL_Weight]
		, [Left_on_Location]	= xB.[Left_on_Location]
		, [Box__MB__Number]		= xB.[Box__MB__Number]
		--, [Well]				= xB.[Well]
		--, [Stage]				= xB.[Stage]
		, [Comment]				= xB.[Comment]
		, [Return_Weight]		= xB.[Return_Weight]
		, [Box_Transfer]		= CASE WHEN xB.[Box_Transfer] = 'Yes' THEN 1 ELSE 0 END
		, [Carrier_Name]		= xB.[Carrier_Name]
		, [Approved_Mileage]	= xB.[Approved_Mileage]
		
		, xmlFileName			= xB.[FileName]
		, SandName				= xB.SandName

		--, xB.*
		--, xI.*
		
		FROM [SSIS_ENG].[xmlImport_MAT_BOLDetails]	xB
			INNER JOIN @tbl_Sands					xI ON xI.mFileName = xB.[FileName] AND xI.SandName = xB.SandName

		--where xB.BOLDate IS NOT NULL
			
	--select * from @tblMAT_BOLs
	RETURN 
END

GO

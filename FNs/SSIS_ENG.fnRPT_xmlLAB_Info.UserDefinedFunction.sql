USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_Info]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM (20180914)
  Modified:	20190415- Added new columns; Changed ID_Pad to nvarchar to store unique ID_Pad from original file;
					  Modified code to no longer join back to dbo.LOS_Pads
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_Info]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_LabInfo	= iLab.[ID_LabInfo] 
		, ID_Pad		= xLab.ID_Pad

		, CompanyName	= xLab.CompanyName
		, PadName		= xLab.PadName	
		, PadNumber		= xLab.PadNumber
		
		, TestingLocation	= xLab.TestingLocation
		, TestingAddress	= xLab.TestingAddress
		, TestingAddress2	= xLab.TestingAddress2
		, TestPerformedBy	= ISNULL(xLab.TestPerformedBy, '')
		, Phone_Number		= xLab.Phone_Number
		, DateOfTest		= xLab.DateOfTest
		, Fluid_System		= xLab.Fluid_System
		, Developmental		= CASE WHEN xLab.Developmental LIKE 'Y%' THEN 1 ELSE 0 END 

		, xID_Record	= xLab.ID_RecordNo
		, xmlFileName	= xLab.[FileName]
		, xmlDate		= xLab.xmlDate
		, MacroVersion	= xLab.MacroVersion
		
		--, rPad.*
		--, xLab.*
		
		FROM [SSIS_ENG].xmlImport_LAB_Info	xLab
			LEFT JOIN [dbo].[LAB_Info]	iLab	
				ON iLab.IsDeleted = 0 
					AND iLab.PadName = LTRIM(RTRIM(xLab.PadName)) AND iLab.ID_Pad = xLab.ID_Pad 

GO

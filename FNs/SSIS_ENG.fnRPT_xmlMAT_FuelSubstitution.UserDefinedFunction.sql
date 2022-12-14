USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_FuelSubstitution]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20210421)
*************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_FuelSubstitution]()
RETURNS TABLE
AS
RETURN 

	SELECT ID_MaterialInfo	= xI.ID_MaterialInfo
		, RecordNo			= RANK() OVER(PARTITION BY xF.xmlFileName ORDER BY xF.xmlFileName, ID_Record)

		, [Crew]		= xF.[Crew]
		, [Well_Name]	= xF.[Well_Name]
		, [Stage]		= xF.[Stage]
		
		, [Diesel_Saved]			= xF.[Diesel_Saved]
		, [Percent_Sub_Entire_Fleet]= xF.[Percent_Sub_Entire_Fleet]
		, [Percent_Sub_DGB_Pumps]	= xF.[Percent_Sub_DGB_Pumps]
		, [Number_Pump]				= xF.[Number_Pump]
		, [Pumps_pulling_NG]		= xF.[Pumps_pulling_NG]
		, [Diesel_Pump]				= xF.[Diesel_Pump]
		, [Total_DBG_Pumps_rigged_in]	= xF.[Total_DBG_Pumps_rigged_in]
		, [Gas_Amount_SCF]			= xF.[Gas_Amount_SCF]
		, [Diesel_AmountPumps_gals]	= xF.[Diesel_AmountPumps_gals]
		, [Diesel_Total_Fleet_gals]	= xF.[Diesel_Total_Fleet_gals]
	
		, [Notes]	= xF.[Notes]
		--, RowID					= ROW_NUMBER() OVER (ORDER BY xF.[ID_Record])
		, xF.xmlFileName
				
		FROM [SSIS_ENG].[xmlImport_MAT_FuelSubstitution]	xF
			INNER JOIN [SSIS_ENG].fnRPT_xmlMAT_Info()		xI ON xI.xmlFileName = xF.xmlFileName
			
	;
	
GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_FuelSubstitution_INSERT]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20210421)
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_FuelSubstitution_INSERT]	
AS
BEGIN
	
	INSERT INTO [dbo].[Material_FuelSubstitution]
           ([ID_MaterialInfo],[RecordNo],[Crew],[Well_Name],[Stage]
           ,[Diesel_Saved],[Percent_Sub_Entire_Fleet],[Percent_Sub_DGB_Pumps]
           ,[Number_Pump],[Pumps_pulling_NG],[Diesel_Pump],[Total_DBG_Pumps_rigged_in],[Gas_Amount_SCF]
           ,[Diesel_AmountPumps_gals],[Diesel_Total_Fleet_gals]
           ,[Notes])

	SELECT ID_MaterialInfo	= xF.ID_MaterialInfo
		, RecordNo			= xF.[RecordNo]

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
		
		FROM [SSIS_ENG].[fnRPT_xmlMAT_FuelSubstitution]()	xF
			LEFT JOIN [dbo].[Material_FuelSubstitution]	sF ON (sF.[ID_MaterialInfo] = xF.[ID_MaterialInfo] AND sF.[RecordNo] = xF.[RecordNo]) 
		
		WHERE (xF.[ID_MaterialInfo] IS NOT NULL AND sF.ID_FuelSub IS NULL)
			--AND xF.BOL_Date IS NOT NULL

		ORDER BY xF.[ID_MaterialInfo]
			, xF.[RecordNo]
	;

END 

GO

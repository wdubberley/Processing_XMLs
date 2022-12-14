USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MAT_FuelSubstitution_UPDATE]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************
  Created:	KPHAM (20210421)
*************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MAT_FuelSubstitution_UPDATE]	
AS
BEGIN
	
	UPDATE mF 
	SET   [Crew]		= xF.[Crew]
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
		, [DateModified]	= GETDATE()
		
		--, xB.*
	
		FROM [SSIS_ENG].[fnRPT_xmlMAT_FuelSubstitution]()	xF
			INNER JOIN [dbo].[Material_FuelSubstitution]	mF ON mF.ID_MaterialInfo = xF.ID_MaterialInfo AND mF.RecordNo = xF.RecordNo

		WHERE (mF.[Crew] <> xF.[Crew]
			OR mF.[Well_Name] <> xF.[Well_Name]
			OR mF.[Stage] <> xF.[Stage]
			OR mF.[Diesel_Saved] <> xF.[Diesel_Saved]
			OR mF.[Percent_Sub_Entire_Fleet] <> xF.[Percent_Sub_Entire_Fleet]
			OR mF.[Percent_Sub_DGB_Pumps] <> xF.[Percent_Sub_DGB_Pumps]
			OR mF.[Number_Pump] <> xF.[Number_Pump]
			OR mF.[Pumps_pulling_NG] <> xF.[Pumps_pulling_NG]
			OR mF.[Diesel_Pump] <> xF.[Diesel_Pump]
			OR mF.[Total_DBG_Pumps_rigged_in] <> xF.[Total_DBG_Pumps_rigged_in]
			OR mF.[Gas_Amount_SCF] <> xF.[Gas_Amount_SCF]
			OR mF.[Diesel_AmountPumps_gals] <> xF.[Diesel_AmountPumps_gals]
			OR mF.[Diesel_Total_Fleet_gals] <> xF.[Diesel_Total_Fleet_gals]
			OR mF.[Notes] <> xF.[Notes])

	;

END 

GO

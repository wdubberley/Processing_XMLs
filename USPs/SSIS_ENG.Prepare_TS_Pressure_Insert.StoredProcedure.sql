USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_Pressure_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_Pressure_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[TechSheet_Pressure]
		([ID_FracInfo]
		,[ID_FracStage]

		,[AveBacksidePSI]
		,[AveBHPSI]
		,[AveCoilPSI]
		,[AveSurfacePSI]
		,[BD_Psi]
		,[BD_Rate]
		,[F_10Min]
		,[F_15Min]
		,[F_1Min]
		,[F_2Min]
		,[F_5Min]
		,[F_BHISIP]
		,[F_FG]
		,[F_ISIP]
		,[FSD_1st_WB_Fric]
		,[FSD_2nd_WB_Fric]
		,[FSD_3rd_WB_Fric]
		,[GlobalTrips]
		,[I_10Min]
		,[I_15Min]
		,[I_1Min]
		,[I_2Min]
		,[I_5Min]
		,[I_BHISIP]
		,[I_ISIP]
		,[I_FG]
		,[ISD_1st_WB_Fric]
		,[ISD_2nd_WB_Fric]
		,[ISD_3rd_WB_Fric]
		,[MaxBacksidePSI]
		,[MaxBHPSI]
		,[MaxCoilPSI]
		,[MaxFlushPSI]
		,[MaxSurfacePSI]
		,[MaxWorkingPSI]
		,[MinBacksidePSI]
		,[MinCoilPSI]
		,[MinSurfacePSI]
		,[Open_WH_Backside_PSI]
		,[PopOffSet_H]
		,[PopOffSet_L]
		,[PressureTestPsi]
		,[TVD]
		)

	SELECT xP.[ID_FracInfo]
		, xP.[ID_FracStage]

		, xP.[AveBacksidePSI]
		, xP.[AveBHPSI]
		, xP.[AveCoilPSI]
		, xP.[AveSurfacePSI]
		, xP.[BD_Psi]
		, xP.[BD_Rate]
		, xP.[F_10Min]
		, xP.[F_15Min]
		, xP.[F_1Min]
		, xP.[F_2Min]
		, xP.[F_5Min]
		, xP.[F_BHISIP]
		, xP.[F_FG]
		, xP.[F_ISIP]
		, xP.[FSD_1st_WB_Fric]
		, xP.[FSD_2nd_WB_Fric]
		, xP.[FSD_3rd_WB_Fric]
		, xP.[GlobalTrips]
		, xP.[I_10Min]
		, xP.[I_15Min]
		, xP.[I_1Min]
		, xP.[I_2Min]
		, xP.[I_5Min]
		, xP.[I_BHISIP]
		, xP.[I_ISIP]
		, xP.[I_FG]
		, xP.[ISD_1st_WB_Fric]
		, xP.[ISD_2nd_WB_Fric]
		, xP.[ISD_3rd_WB_Fric]
		, xP.[MaxBacksidePSI]
		, xP.[MaxBHPSI]
		, xP.[MaxCoilPSI]
		, xP.[MaxFlushPSI]
		, xP.[MaxSurfacePSI]
		, xP.[MaxWorkingPSI]
		, xP.[MinBacksidePSI]
		, xP.[MinCoilPSI]
		, xP.[MinSurfacePSI]
		, xP.[Open_WH_Backside_PSI]
		, xP.[PopOffSet_H]
		, xP.[PopOffSet_L]
		, xP.[PressureTestPsi]
		, xP.[TVD]
		
		FROM [SSIS_ENG].fnRPT_xmlTS_FracStages_Pressure()	xP
			LEFT JOIN dbo.TechSheet_Pressure				eP ON (eP.ID_FracInfo = xP.ID_FracInfo AND eP.ID_FracStage = xP.ID_FracStage) 

		WHERE (xP.ID_FracStage IS NOT NULL AND xP.ID_FracInfo IS NOT NULL)
			AND eP.ID_Record IS NULL
	;

END 



GO

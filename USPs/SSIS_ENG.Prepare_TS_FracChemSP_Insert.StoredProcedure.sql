USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracChemSP_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  CREATED:	KPHAM (20190117)
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracChemSP_Insert]	
AS
BEGIN

	INSERT INTO dbo.[FracChemSP]
		([ID_FracInfo]
		,[ID_FracStage]
		,[StageNo]
		,[SubStage]
		,[CumStageNo]
		,[ID_Chemical]
		,[ChemSetPoint])

	SELECT ID_FracInfo	= xSP.ID_FracInfo
		, ID_FracStage	= xSP.ID_FracStage
		, StageNo		= xSP.Interval_No
		, SubStage		= xSP.Stage_No
		, CumStageNo	= xSP.CMTV_Stage_No
		, ID_Chemical	= xSP.ID_Chemical
		, ChemSetPoint	= ChemSP_Value

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_Designs_ChemSP]() xSP
			LEFT JOIN dbo.[FracChemSP] eSP
				ON eSP.ID_FracStage = xSP.ID_FracStage 
					AND eSP.SubStage = xSP.STAGE_No AND eSP.CumStageNo = xSP.CMTV_Stage_No AND eSP.ID_Chemical = xSP.ID_Chemical
		WHERE eSP.ID_FracChemSP IS NULL
			AND xSP.ID_FracInfo IS NOT NULL

	;

END 

GO

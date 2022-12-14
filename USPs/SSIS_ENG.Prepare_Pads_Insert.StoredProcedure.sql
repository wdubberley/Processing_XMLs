USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_Pads_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************************
  Created:	KPHAM (2016)
  20190206- Omit pad creation from TechSheet XMLs
  20220513(v003)- Update Count_WellsTotal value if wells is more than 50
******************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_Pads_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT;

	WITH 
		Combine_Pad AS
			(SELECT DISTINCT 
				Operator					= xL.Customer
				, PadName					= Pad
				, Count_WellsTotal			= CASE WHEN xL.TotalWellsOnPad > 50 
													THEN (SELECT COUNT(DISTINCT w.ID_Well) 
															FROM dbo.LOS_Wells w 
																inner join dbo.LOS_Pads p ON p.ID_Pad = w.ID_Pad AND p.Field_PadName=xL.Pad)
												ELSE xL.TotalWellsOnPad END
				, Count_WellsToStimulate	= CASE WHEN xL.WellsToStimulate IS NULL THEN 0 ELSE xL.WellsToStimulate END
				, Count_StagesToStimulate	= CASE WHEN xL.TotalStagesOnPad IS NULL THEN 0 ELSE xL.TotalStagesOnPad END
				, Pad_No					= CASE WHEN xL.Pad_No IS NULL THEN 0 ELSE xL.Pad_No END
				--, Field_PadName				= Pad

				FROM [SSIS_ENG].xmlImport_TT_TimeLogs xL
			/********* (20190206) ************************************
			UNION 
			SELECT DISTINCT
				Operator					= xI.Customer_Name
				, PadName					= xI.Pad_Name
				, Count_WellsTotal			= 0
				, Count_WellsToStimulate	= 0
				, Count_StagesToStimulate	= 0
				, Pad_No					= 0
				--, Field_PadName				= xI.Pad_Name
				FROM SSIS_ENG.xmlImport_TS_FracInfo xI
				WHERE Pad_Name IS NOT NULL
			--*********************************************************/
			)

	INSERT INTO dbo.LOS_Pads 
		(ID_Operator, PadName, Count_WellsTotal, Count_WellsToStimulate, Count_StagesToStimulate, Pad_No, Field_PadName)
	SELECT DISTINCT --ID_Pad	= rPad.ID_Pad
		ID_Operator					= mO.ID_Operator
		, PadName					= UPPER(xL.PadName)
		, Count_WellsTotal			= CASE WHEN SUM(xL.Count_WellsTotal) <= SUM(xL.Count_WellsToStimulate) THEN SUM(xL.Count_WellsToStimulate) ELSE SUM(xL.Count_WellsTotal) END
		, Count_WellsToStimulate	= CASE WHEN SUM(xL.Count_WellsToStimulate) <= SUM(xL.Count_WellsTotal) THEN SUM(xL.Count_WellsToStimulate) ELSE SUM(xL.Count_WellsTotal) END
		, Count_StagesToStimulate	= CASE WHEN SUM(xL.Count_StagesToStimulate) IS NULL THEN 0 ELSE SUM(xL.Count_StagesToStimulate) END
		, Pad_No					= MAX(xL.Pad_No)
		, Field_PadName				= xL.PadName
		FROM Combine_Pad xL
			INNER JOIN SSIS_ENG.mapping_Customer_Operator mO ON (xL.Operator = mO.Customer)
			LEFT JOIN dbo.LOS_Pads rPad ON (rPad.Field_PadName = xL.PadName AND rPad.ID_Operator = mO.ID_Operator)

		WHERE rPad.ID_Pad IS NULL

		GROUP BY mO.ID_Operator, xL.PadName;

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Pads', 'Insert', @rValue

END 

GO

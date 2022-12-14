USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_Pads_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************************
  Created:	KPHAM
  20190729(v003)- Changed filter to update Pad_No to > 9999
  20190912(v004)- Changed filter to update Pad_No to > 99999; Added filter to ID_Operator
  20190912(v005)- Removed filter to update Pad_No; Created called in separate USP
  20220513(v006)- Update TotalWellsOnPad value if wells is more than 50
******************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_Pads_Update]	
AS
BEGIN

	DECLARE @rValue AS INT; 

	/******* Update Existing Pad Info from xmlTimeLogs (TimeTrackers) *******/
	WITH cte_xmlPads AS
		(SELECT DISTINCT Pad	= xTT.Pad
			, TotalWellsOnPad	= CASE WHEN xTT.TotalWellsOnPad > 50 
										THEN (SELECT COUNT(DISTINCT w.ID_Well) 
												FROM dbo.LOS_Wells w 
													inner join dbo.LOS_Pads p ON p.ID_Pad = w.ID_Pad AND p.Field_PadName=xTT.Pad)
									ELSE xTT.TotalWellsOnPad END
			, WellsToStimulate	= xTT.WellsToStimulate
			, TotalStagesOnPad	= xTT.TotalStagesOnPad
			, Pad_No		= xTT.Pad_No
			, ID_Operator	= mO.ID_Operator

			FROM [SSIS_ENG].xmlImport_TT_TimeLogs			xTT
				INNER JOIN [SSIS_ENG].mapping_Customer_Operator	mO ON mO.Customer = xTT.Customer
		)

	UPDATE rP 
		SET rP.Count_WellsTotal			= ISNULL(CASE WHEN xP.TotalWellsOnPad <= xP.WellsToStimulate THEN xP.WellsToStimulate ELSE xP.TotalWellsOnPad END, 0)
			, rP.Count_WellsToStimulate	= ISNULL(CASE WHEN xP.TotalWellsOnPad <= xP.WellsToStimulate THEN xP.WellsToStimulate ELSE xP.WellsToStimulate END, 0)
			, rP.Count_StagesToStimulate= ISNULL(CASE WHEN xP.TotalStagesOnPad IS NULL THEN 0 ELSE xP.TotalStagesOnPad END, 0)
			--, rP.Pad_No					= CASE WHEN xP.Pad_No IS NULL THEN 0 
			--								WHEN xP.Pad_No BETWEEN 0 AND 99999 AND rP.Pad_No > 99999 THEN rP.Pad_No
			--								ELSE xP.Pad_No END
	--select * 
		FROM cte_xmlPads			xP
			INNER JOIN dbo.LOS_Pads	rP ON rP.Field_PadName = xP.Pad AND rP.ID_Operator = xP.ID_Operator

		WHERE xP.TotalWellsOnPad <> rP.Count_WellsTotal
			OR xP.WellsToStimulate <> rP.Count_WellsToStimulate
			OR xP.TotalStagesOnPad <> rP.Count_StagesToStimulate
			--OR xP.Pad_No <> rP.Pad_No

	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Pads', 'Update', @rValue

END 

GO

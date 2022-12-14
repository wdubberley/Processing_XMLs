USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATWellInfo_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  Created:	KPHAM
  20190520- Added StageEquipment section to insert WellInfo
  20210104(v002)- Removed call to StageEquipment
  20210708(v003)- Switched vw on JobBoard to TechSheet_WellInfo
*******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATWellInfo_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT = 0
		, @tValue	AS VARCHAR(100) = 'dbo.Material_WellInfo'

	INSERT INTO dbo.Material_WellInfo (ID_MaterialInfo, WellName, ID_FracInfo)

	/******* New WellInfos from SandTrends *******/
	SELECT DISTINCT ID_MaterialInfo = xST.ID_MaterialInfo
		, WellName		= xST.Well
		, ID_FracInfo	= CASE WHEN vJ.ID_FracInfo IS NOT NULL THEN vJ.ID_FracInfo ELSE 0 END

		FROM [SSIS_ENG].[fnRPT_xmlMAT_SandTrends]() xST
			--LEFT JOIN Performance.vw_JobBoard		vJ ON vJ.WellName = xST.Well AND vJ.ID_Pad = xST.ID_Pad
			LEFT JOIN Engineering.vw_TechSheet_WellInfo		vJ ON vJ.Well_Name = xST.Well AND vJ.ID_Pad = xST.ID_Pad

		WHERE NOT EXISTS (SELECT sWI.ID_WellInfo
							FROM dbo.Material_WellInfo sWI 
							WHERE sWI.ID_MaterialInfo = xST.ID_MaterialInfo AND sWI.WellName=RTRIM(LTRIM(xST.Well)))

			AND xST.ID_MaterialInfo IS NOT NULL
			AND xST.Well IS NOT NULL
				
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @rValue + ISNULL(@@ROWCOUNT, 0)
	
	IF @rValue > 0 EXEC [SSIS_ENG].[uspREF_History_Insert] @tValue, 'Insert', @rValue

END 

GO

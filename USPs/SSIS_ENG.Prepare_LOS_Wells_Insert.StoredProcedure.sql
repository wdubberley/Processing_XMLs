USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LOS_Wells_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_LOS_Wells_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT = 0;

	--/******* (1) New Wells from xmlImport_TS_FracInfo (TechSheets) **********************
	INSERT INTO dbo.LOS_Wells 
		(ID_Operator, ID_District, ID_StateProv, ID_Basin, StateProv, County, FieldName
		, WellName, WellAPI, WellAFE, WellLocation, Latitude_X, Longitude_Y)
	--***********************************************************************************/
	SELECT DISTINCT ID_Operator = mO.ID_Operator
		, ID_District			= ISNULL(rD.ID_District, rB.ID_LOSDistrict)
		, ID_StateProv			= CASE WHEN rS.ID_Record IS NULL THEN 0 ELSE rS.ID_Record END
		, ID_Basin				= rB.ID_Basin
		, StateProv				= tI.[State]
		, County				= ISNULL(tI.County,'')
		, FieldName				= CASE WHEN tI.Field_Prospect IS NULL THEN '' ELSE tI.Field_Prospect END
		, WellName				= RTRIM(LTRIM(tI.Well_Name))
		, WellAPI				= ISNULL(RTRIM(LTRIM(tI.API)),'')
		, WellAFE				= CASE WHEN tI.AFE IS NULL THEN '' ELSE LTRIM(RTRIM(tI.AFE)) END
		, WellLocation			= CASE WHEN tI.Well_Location IS NULL THEN '' ELSE tI.Well_Location END
		, Latitude_X			= tI.Latitude
		, Longitude_Y			= tI.Longitude

		FROM [SSIS_ENG].xmlImport_TS_FracInfo tI
			LEFT JOIN [SSIS_ENG].mapping_Customer_Operator mO ON (mO.Customer = tI.Customer_Name)
			LEFT JOIN dbo.ref_Districts rD ON (rD.Basin = tI.LOS_District OR rD.DistrictName=tI.LOS_District
												OR rD.DistrictAbbr=tI.LOS_District OR rD.Township=tI.LOS_District)
			LEFT JOIN dbo.ref_StateProvs rS ON rS.StateName = tI.[State]
			LEFT JOIN dbo.LOS_Basins rB ON rB.Basin = tI.Basin

		WHERE NOT EXISTS (SELECT rW.ID_Well 
							FROM dbo.LOS_Wells rW 
							WHERE rW.WellName=RTRIM(LTRIM(tI.Well_Name)))
			AND mO.ID_Operator IS NOT NULL
			
	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @rValue + ISNULL(@@ROWCOUNT, 0)
	
	;WITH TT_Wells AS
		(SELECT DISTINCT 
			ID_Operator		= mO.ID_Operator
			, ID_District	= ISNULL(ISNULL(rB.ID_District, rC.ID_District), 0)
			, ID_StateProv	= 0
			, StateProv		= ''
			, County		= ''
			, FieldName		= ''
			, WellName		= xTT.WellName
			, WellAPI		= ''
			, WellLocation	= ''
			, Latitude_X	= NULL
			, Longitude_Y	= NULL

			FROM [SSIS_ENG].[fnRPT_xmlTT_Wells]() xTT 
				LEFT JOIN [SSIS_ENG].mapping_Customer_Operator	mO ON mO.Customer = xTT.Customer
				LEFT JOIN dbo.ref_Districts		rB ON (rB.Basin = xTT.Camp OR rB.DistrictName = xTT.Camp)
				LEFT JOIN dbo.ref_Crews			rC ON (rC.CrewName = xTT.Crew OR rC.CrewNameAlt = xTT.Crew)

			WHERE NOT EXISTS (SELECT rW.ID_Well 
								FROM dbo.LOS_Wells rW 
								WHERE rW.WellName = xTT.WellName)
				AND mO.ID_Operator IS NOT NULL

		)
	
		--/******* (2) New Wells from xmlTimeLogs *************************************
		INSERT INTO dbo.LOS_Wells 
			(ID_Operator, ID_District, ID_StateProv, StateProv, County, FieldName
			, WellName, WellAPI, WellLocation, Latitude_X, Longitude_Y)
		--****************************************************************************/
	
		SELECT ID_Operator, ID_District, ID_StateProv, StateProv, County, FieldName
			, WellName, WellAPI, WellLocation, Latitude_X, Longitude_Y 

			FROM TT_Wells

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @rValue + ISNULL(@@ROWCOUNT, 0)
	
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Wells', 'Insert', @rValue

	/********* UPDATE Pad reference if not already updated ********/
	UPDATE rW SET rW.ID_Pad = fX.ID_Pad
	--SELECT DISTINCT rW.ID_Well, rW.ID_Pad, fX.ID_Pad
		FROM [SSIS_ENG].[fnRPT_xmlTT_TimeLogs]() fX
			INNER JOIN dbo.LOS_Wells rW ON rW.ID_Well = fX.ID_Well
		
		WHERE fX.ID_Well IS NOT NULL AND rW.ID_Pad = 0 AND fX.ID_Pad IS NOT NULL; 

END 



GO

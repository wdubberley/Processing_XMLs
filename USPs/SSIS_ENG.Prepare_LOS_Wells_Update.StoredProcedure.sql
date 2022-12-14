USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LOS_Wells_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  20211027(v002)- If rD.ID_District doesnt match, get ID_LOSDIstrict from Basin
  20220117(v003)- Added DateModified to update stmt.
************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LOS_Wells_Update]	
AS
BEGIN

	DECLARE @rValue AS INT = 0;

	/******* Update Existing Well Info from xmlImport_Daily (TechSheets) *******/
	WITH xInfo_Wells AS
		(SELECT DISTINCT 
			ID_Operator		= mO.ID_Operator
			, ID_District	= ISNULL(rD.ID_District, rB.ID_LOSDistrict)
			, ID_StateProv	= CASE WHEN rS.ID_Record IS NULL THEN 0 ELSE rS.ID_Record END
			, ID_Basin		= rB.ID_Basin
			, StateProv		= tI.[State]
			, County		= ISNULL(tI.County,tI.[State])
			, FieldName		= CASE WHEN tI.Field_Prospect IS NULL THEN '' ELSE tI.Field_Prospect END
			, WellName		= RTRIM(LTRIM(tI.Well_Name))
			, WellAPI		= ISNULL(tI.API,'')
			, WellAFE		= CASE WHEN tI.AFE IS NULL THEN '' ELSE LTRIM(RTRIM(tI.AFE)) END
			, WellLocation	= tI.Well_Location
			, Latitude_X	= tI.Latitude
			, Longitude_Y	= tI.Longitude
			FROM [SSIS_ENG].xmlImport_TS_FracInfo	tI
				LEFT JOIN [SSIS_ENG].mapping_Customer_Operator	mO ON mO.Customer = tI.Customer_Name
				LEFT JOIN dbo.ref_Districts			rD ON (rD.DistrictName = tI.LOS_District OR rD.Township = tI.LOS_District
															OR rD.Basin = tI.LOS_District OR rD.DistrictAbbr = tI.LOS_District OR rD.Township = tI.LOS_District)
				LEFT JOIN dbo.LOS_Basins			rB ON rB.Basin = tI.Basin
				LEFT JOIN dbo.ref_StateProvs		rS ON rS.StateName = tI.[State]
		)

		UPDATE rW
			SET rW.ID_StateProv		= cte.ID_StateProv
				, rW.ID_District	= CASE WHEN rW.ID_District <> cte.ID_District THEN cte.ID_District ELSE rW.ID_District END
				, rW.ID_Basin		= CASE WHEN rW.ID_Basin=0 AND cte.ID_Basin <> 0 THEN cte.ID_Basin ELSE rW.ID_Basin END
				, rW.StateProv		= cte.StateProv
				, rW.County			= ISNULL(cte.County,'')
				, rW.FieldName		= CASE WHEN cte.FieldName IS NULL THEN rW.FieldName ELSE cte.FieldName END
				, rW.WellAPI		= cte.WellAPI
				, rW.WellAFE		= cte.WellAFE
				, rW.WellLocation	= CASE WHEN cte.WellLocation IS NULL THEN '' ELSE cte.WellLocation END
				, rW.Latitude_X		= cte.Latitude_X
				, rW.Longitude_Y	= cte.Longitude_Y
				, rW.DateModified	= GETDATE()
		--select *
			FROM xInfo_Wells cte
				INNER JOIN dbo.LOS_Wells rW ON rW.WellName = cte.WellName AND rW.ID_Operator = cte.ID_Operator

	SET @rValue = ISNULL(@@ROWCOUNT, 0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Wells', 'Update', @rValue

END 

GO

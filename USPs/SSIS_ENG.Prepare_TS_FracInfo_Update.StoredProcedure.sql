USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracInfo_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
  Created:	KPHAM (2016)
  20210708(v004)- Added Reservation_Land
  20211110(v005)- Added Energized_Fluid
  20220117(v006)- Added DateModified
*******************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracInfo_Update]	
AS
BEGIN

	;WITH cte_Info_Update AS
		(SELECT ID_FracInfo	= fI.ID_FracInfo
			, WellName		= fI.WellName
			, ID_District	= fI.ID_District
			, LOS_ProjectNo	= STUFF((SELECT DISTINCT ',' + LTRIM(RTRIM(xI.LOS_Project_Number ))
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.LOS_Project_Number IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, Formation		= STUFF((SELECT DISTINCT ',' + xI.Formation 
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.Formation IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, Well_BHST		= MAX(fI.Well_BHST)

			, Well_MaxPressure	= MAX(fI.Well_MaxPressure)
			, ID_CompletionType	= MAX(fI.ID_CompletionType)
			, ID_WellType		= MAX(fI.ID_WellType)
			, TotalIntervals	= MAX(fI.TotalIntervals)
			, MainFluidTypes	= STUFF((SELECT DISTINCT ',' + xI.Main_Fluid_Type 
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.Main_Fluid_Type IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, MainProppantTypes	= STUFF((SELECT DISTINCT ',' + xI.Main_Proppant_Type 
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.Main_Proppant_Type IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, DateCompletion	= MAX(fI.DateCompletion)	
			, PadName			= CASE WHEN fI.Pad_Name IS NULL OR fI.Pad_Name='' THEN fI.PadName ELSE fI.Pad_Name END

			, xmlMacroVersion	= STUFF((SELECT DISTINCT ',' + xI.MacroVersion
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.MacroVersion IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, Customer_Address	= STUFF((SELECT DISTINCT ',' + xI.Customer_Address 
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.Customer_Address IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, LOS_Address		= STUFF((SELECT DISTINCT ',' + xI.LOS_Address 
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.LOS_Address IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			
			, Reservation_Land	= STUFF((SELECT DISTINCT ',' + ISNULL(xI.Reservation_Land, '')
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.LOS_Address IS NOT NULL
										FOR XML PATH('')) ,1,1,'')
			, Energized_Fluid	= STUFF((SELECT DISTINCT ',' + ISNULL(xI.Energized_Fluid, '')
										FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
										WHERE xI.Well_Name = fI.WellName AND xI.LOS_Address IS NOT NULL
										FOR XML PATH('')) ,1,1,'')

			FROM [SSIS_ENG].[fnRPT_xmlTS_FracInfo]()	fI
				
			GROUP BY fI.ID_FracInfo
				, fI.WellName
				, fI.ID_District
				, fI.Pad_Name
				, fI.PadName
		)

	/********** UPDATE FracInfo if available in TechSheet Info load ***************/
	UPDATE eI 
		SET eI.LOS_ProjectNo	= ISNULL(LTRIM(RTRIM(fI.LOS_ProjectNo)),'') -- CASE WHEN LTRIM(RTRIM(fI.LOS_ProjectNo)) IS NULL THEN '' ELSE LTRIM(RTRIM(fI.LOS_ProjectNo)) END
		, eI.Formation			= ISNULL(fI.Formation, '')					-- CASE WHEN fI.Formation IS NULL THEN '' ELSE fI.Formation END
		, eI.Well_BHST			= ISNULL(fI.Well_BHST, 0)					-- CASE WHEN fI.Well_BHST IS NULL THEN 0 ELSE fI.Well_BHST END
		, eI.Well_MaxPressure	= ISNULL(fI.Well_MaxPressure, 0)			-- CASE WHEN fI.Well_MaxPressure IS NULL THEN 0 ELSE fI.Well_MaxPressure END
		, eI.ID_CompletionType	= ISNULL(fI.ID_CompletionType, 0)			-- CASE WHEN fI.ID_CompletionType IS NULL THEN 0 ELSE fI.ID_CompletionType END
		, eI.ID_WellType		= ISNULL(fI.ID_WellType, 0)					-- CASE WHEN fI.ID_WellType IS NULL THEN 0 ELSE fI.ID_WellType END
		, eI.TotalIntervals		= ISNULL(fI.TotalIntervals, 0)				-- CASE WHEN fI.TotalIntervals IS NULL THEN 0 ELSE fI.TotalIntervals END
		, eI.MainFluidTypes		= ISNULL(fI.MainFluidTypes, '')				-- CASE WHEN fI.MainFluidTypes IS NULL THEN '' ELSE fI.MainFluidTypes END
		, eI.MainProppantTypes	= ISNULL(fI.MainProppantTypes, '')			-- CASE WHEN fI.MainProppantTypes IS NULL THEN '' ELSE fI.MainProppantTypes END
		, eI.DateCompletion		= fI.DateCompletion
		, eI.PadName			= ISNULL(fI.PadName, '')					-- CASE WHEN fI.PadName IS NULL THEN '' ELSE fI.PadName END
		, eI.ID_District		= fI.ID_District
		, eI.xmlMacroVersion	= fI.xmlMacroVersion
		, eI.Customer_Address	= ISNULL(fI.Customer_Address, '')
		, eI.LOS_Address		= ISNULL(fI.LOS_Address, '')
		
		, eI.Reservation_Land	= fI.Reservation_Land		/* 20210708 */
		, eI.Energized_Fluid	= fI.Energized_Fluid		/* 20211110 */
		
		, eI.DateModified		= GETDATE()					/* 20220117 */
	--select *
		FROM cte_Info_Update		fI
			INNER JOIN dbo.FracInfo eI ON eI.ID_FracInfo = fI.ID_FracInfo 

		WHERE ISNULL(eI.LOS_ProjectNo,'') <> ISNULL(LTRIM(RTRIM(fI.LOS_ProjectNo)),'')
			OR ISNULL(eI.Formation,'') <> ISNULL(fI.Formation, '')
			OR ISNULL(eI.Well_BHST,0) <> ISNULL(fI.Well_BHST, 0)
			OR ISNULL(eI.Well_MaxPressure,0) <> ISNULL(fI.Well_MaxPressure, 0)
			OR ISNULL(eI.ID_CompletionType,0) <> ISNULL(fI.ID_CompletionType, 0)
			OR ISNULL(eI.ID_WellType,0) <> ISNULL(fI.ID_WellType, 0)
			OR ISNULL(eI.TotalIntervals,0) <> ISNULL(fI.TotalIntervals, 0)
			OR ISNULL(eI.MainFluidTypes,'') <> ISNULL(fI.MainFluidTypes, '')
			OR ISNULL(eI.MainProppantTypes,'') <> ISNULL(fI.MainProppantTypes, '')
			OR eI.DateCompletion <> fI.DateCompletion OR (eI.DateCompletion IS NULL AND fI.DateCompletion IS NOT NULL) OR (eI.DateCompletion IS NOT NULL AND fI.DateCompletion IS NULL) 
			OR ISNULL(eI.PadName,'') <> ISNULL(fI.PadName, '')
			OR eI.ID_District <> fI.ID_District
			OR eI.xmlMacroVersion <> fI.xmlMacroVersion
			OR ISNULL(eI.Customer_Address,'') <> ISNULL(fI.Customer_Address,'')
			OR ISNULL(eI.LOS_Address,'') <> ISNULL(fI.LOS_Address,'')
		
			OR ISNULL(eI.Reservation_Land,'') <> ISNULL(fI.Reservation_Land,'')
			OR ISNULL(eI.Energized_Fluid,'') <> ISNULL(fI.Energized_Fluid,'')
		
END 

GO

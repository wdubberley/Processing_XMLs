USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTT_Wells]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************
  Created:	KPHAM (2018)
  Modified:	20181016- Added splitCount to indicate number of wells being split
			20181018- Modified code to handle multiple symbols
			20181207 (v002)- Exclude Hornbuckle 13W-32/29H
			20190131 (v002)- Exclude 'State-Hayter 35/42S 4HA','State 15E-36/25-3775H'
			20190201 (v003)- Recode to handle issue with having / in single well names
  20210228(v004)- Remove ' % ' separation code for pad Dark Star Unit 2 Pad 5
***************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTT_Wells]()
RETURNS TABLE
AS
RETURN 

	WITH wTT_Single AS		/* This selects ONLY single wells */
		(SELECT DISTINCT	
			Customer	= xTT.Customer
			, Pad		= xTT.Pad
			, Crew		= xTT.Crew
			, Camp		= xTT.Camp
		
			, tt_Well		= xTT.Well			/* exact name on TT */
			, minPadRecord	= (SELECT MIN(x.[Record#]) FROM [SSIS_ENG].[xmlImport_TT_TimeLogs] x WHERE x.Pad = xTT.Pad GROUP BY x.Pad)
			, splitCount	= 1

			, WellName	= xTT.Well
		
			FROM [SSIS_ENG].[xmlImport_TT_TimeLogs] xTT 

			WHERE xTT.Well IS NOT NULL
				AND (xTT.Well NOT LIKE '% / %' 
					--AND xTT.Well NOT LIKE '% & %'
					)
		)
		, wTT_Multiple AS		/* This selects multiple wells record and gives the split count */
		(SELECT DISTINCT
			Customer	= xTT.Customer
			, Pad		= xTT.Pad
			, Crew		= xTT.Crew
			, Camp		= xTT.Camp
		
			, tt_Well		= REPLACE(xTT.Well, ' & ', ' / ')			/* exact name on TT */
			, minPadRecord	= (SELECT MIN(x.[Record#]) FROM [SSIS_ENG].[xmlImport_TT_TimeLogs] x WHERE x.Pad = xTT.Pad GROUP BY x.Pad)
			, splitCount	= CONVERT(FLOAT, LEN(xTT.Well) - LEN(REPLACE(REPLACE(xTT.Well, '/', ''),'&',''))) + 1.0

			FROM [SSIS_ENG].[xmlImport_TT_TimeLogs] xTT 

			WHERE xTT.Well IS NOT NULL
				AND (xTT.Well LIKE '% / %' 
					--OR xTT.Well LIKE '% & %'
					)
		)
		, xTT_Sync AS	/* This splits the well names that has " / " (indicating multiple wells) */
		(SELECT xTT.*
			, WellName	= RTRIM(LTRIM(well.items)) 
			FROM wTT_Multiple xTT
				OUTER APPLY dbo.Split(xTT.tt_Well, '/') well
			WHERE splitCount > 1
		)

		/* COMBINING Single wells and Sync wells */
		SELECT *
			FROM wTT_Single 
		UNION 
		SELECT * 
			FROM xTT_Sync


GO

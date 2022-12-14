USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_ComparisonChemicals]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************
  Created:	KPHAM (20170822)
  Updated:	20190115- Change xI.LOS_ProjectNo to xI.TaskNo
			20190116- Added rNo to sort list by ID_FracInfo, StageNo
*****************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_ComparisonChemicals]()
RETURNS TABLE
AS
RETURN 

	SELECT --xC_Chem.*
		  ID_FracInfo		= xI.ID_FracInfo
		, StageNo			= xC_Chem.[StageNo]
		, ID_Chemical		= rChem.ID_Chemical
		, Chemical_Unit		= xC_Chem.[Chemical_Unit]
		, Chemical_Propose	= xC_Chem.[Chemical_Propose]
		, Chemical_Design	= xC_Chem.[Chemical_Design]
		, Chemical_Actual	= xC_Chem.[Chemical_Actual]

		, rNo				= ROW_NUMBER() OVER(ORDER BY xI.ID_FracInfo, xC_Chem.[StageNo],xC_Chem.[ID_Record])		/* 20190116 */

		, xC_Chem.[ID_Record]
		, xC_Chem.[WellName]
		, xC_Chem.[TicketNo]
		, xC_Chem.[Chemical_Name]
		, xC_Chem.[FilePath]

		FROM [SSIS_ENG].[xmlImport_TS_ComparisonChemicals]	xC_Chem
			INNER JOIN SSIS_ENG.fnRPT_xmlTS_FracInfo()		xI		ON xI.WellName = xC_Chem.WellName AND xI.TaskNo = xC_Chem.TicketNo
			INNER JOIN dbo.LOS_Chemicals					rChem	ON rChem.ChemicalName = xC_Chem.[Chemical_Name]

	;


GO

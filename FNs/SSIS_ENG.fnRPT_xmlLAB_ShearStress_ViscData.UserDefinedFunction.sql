USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_ViscData]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
  CREATED:	20190418 (KPHAM)
  Modified:	
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_ViscData] ()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_Record	= xSV.ID_Record

		,[ID_LabInfo]	= xChem.ID_LabInfo
		,[ID_TestInfo]	= xChem.ID_TestInfo
	
		,[Data_Min]		= xSV.[Data_Min]
		,[ShearRate]	= xsV.[ShearRate]
		,[Viscocity]	= xSV.[Viscocity]

		,rowID		= ROW_NUMBER() OVER(ORDER BY xSV.ID_Record)
						-- OVER(ORDER BY xSV.ID_Pad, xSV.OscillatingRheometerTestNumber, xSV.ID_Performance, xSV.Data_Min)
		,[ID_Pad]		= xChem.[ID_Pad]
		,[TestNumber]	= xChem.[TestNumber]
		,[ChemPerformance]	= xSV.[ID_Performance]
		,[PadNumber]	= xSV.PadNumber
	
		FROM [SSIS_ENG].[xmlImport_LAB_ShearStress_ViscData]	xSV
			INNER JOIN [SSIS_ENG].fnRPT_xmlLAB_TestChemicals()	xChem
				ON xChem.ID_TestType = 99 
					AND xChem.ID_Pad = xSV.ID_Pad AND xChem.TestNumber = xSV.OscillatingRheometerTestNumber 
					AND xChem.RelatedTestNo = xSV.ID_Performance

	;

GO

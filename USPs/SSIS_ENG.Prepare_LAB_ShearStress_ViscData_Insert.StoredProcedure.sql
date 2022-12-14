USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_ShearStress_ViscData_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  CREATED:	20190418 (KPHAM)
  MOdified:	
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_ShearStress_ViscData_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_ShearStress_ViscData]
        ([ID_LabInfo],[ID_TestInfo],[ID_ChemInfo]
        ,[Data_Min],[ShearRate],[Viscocity]
        ,[ID_Performance])

	SELECT ID_LabInfo	= xSV.ID_LabInfo
		, ID_TestInfo	= xSV.ID_TestInfo
		, ID_ChemInfo	= dChem.ID_TestChemical

		, Data_Min	= xSV.Data_Min
		, ShearRate	= xSV.ShearRate
		, Viscocity	= xSV.Viscocity 

		, ID_Performance	= xSV.ChemPerformance
		
		FROM [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_ViscData]()	xSV
			INNER JOIN dbo.LAB_TestChemicals dChem
				ON dChem.ID_TestType = 99 
					AND dChem.ID_LabInfo = xSV.ID_LabInfo AND dChem.ID_TestInfo = xSV.ID_TestInfo AND dChem.RelatedTestNo = xSV.ChemPerformance

			LEFT JOIN dbo.LAB_ShearStress_ViscData	dSV 
				ON dSV.ID_TestInfo = xSV.ID_TestInfo AND dSV.ID_Performance = xSV.ChemPerformance

		WHERE xSV.ID_LabInfo IS NOT NULL AND xSV.ID_TestInfo IS NOT NULL AND dChem.ID_TestChemical IS NOT NULL
			AND dSV.ID_ViscData IS NULL

		ORDER BY xSV.ID_LabInfo, xSV.ID_TestInfo, xSV.ChemPerformance, xSV.Data_Min
					
	;

END 


GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_ShearStress_TestSpecs_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******
  Created:	20190416 (KPHAM)
  Modified:	
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_ShearStress_TestSpecs_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_ShearStress_TestSpecs]
		([ID_LabInfo]
		,[TestNumber],[WASampleLocation]
		,[Viscometer_Model]
		,[Rotor]
		,[Bob]
		,[Torsion_Spring])

	SELECT [ID_LabInfo]		= xSS.[ID_LabInfo]
		, [TestNumber]		= xSS.[TestNumber]
		, [WASampleLocation]= xSS.WASampleLocation

		, [Viscometer_Model]= xSS.[Viscometer_Model]
		, [Rotor]	= xSS.[Rotor]
		, [Bob]		= xSS.[Bob]
		, [Torsion_Spring]	= xSS.[Torsion_Spring]
		
		FROM [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_TestSpecs]()	xSS
			LEFT JOIN dbo.[LAB_ShearStress_TestSpecs]		dSS ON dSS.ID_LabInfo = xSS.ID_LabInfo AND dSS.TestNumber = xSS.TestNumber 

		WHERE xSS.ID_LabInfo IS NOT NULL 
			AND dSS.ID_TestInfo IS NULL

	;

END 


GO

USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_OscillatingRheometer_TestData]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
  CREATED:	20190417 (KPHAM)
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_OscillatingRheometer_TestData]()
RETURNS TABLE
AS
RETURN 
	
	SELECT ID_LabInfo	= vI.ID_LabInfo
		, ID_TestInfo	= vI.ID_TestInfo

		, SequenceNo		= xOR.[OscillatingRheometerPointOrder]
		, ShearStrainPercent= xOR.[OscillatingRheometerShearStrainPercent]
		, StorageModulus_Pa	= xOR.[OscillatingRheometerStorageModulusPa] 
		, LossModulus_Pa	= xOR.[OscillatingRheometerLossModulusPa]

		,[ID_Record]	= xOR.ID_Record
		,[ID_Pad]		= vI.ID_Pad
		,[TestNumber]	= xOR.[OscillatingRheometerTestNumber]
		
		FROM [SSIS_ENG].[xmlImport_LAB_OscillatingRheometer_TestData]	xOR
			INNER JOIN [SSIS_ENG].vw_LAB_TestInfos			vI ON vI.ID_Pad = xOR.ID_Pad AND vI.TestNumber = xOR.OscillatingRheometerTestNumber
	;


GO

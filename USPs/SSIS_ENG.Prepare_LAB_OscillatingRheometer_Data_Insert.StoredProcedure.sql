USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_OscillatingRheometer_Data_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******
  CREATED:	20190417 (KPHAM)
  MOdified:	
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_OscillatingRheometer_Data_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_OscillatingRheometer_TestData]
        ([ID_LabInfo],[ID_TestInfo],[SequenceNo]
        ,[ShearStrainPercent]
        ,[StorageModulus_Pa]
        ,[LossModulus_Pa])

	SELECT ID_LabInfo	= xOR.ID_LabInfo
		, ID_TestInfo	= xOR.ID_TestInfo
		, SequenceNo	= xOR.SequenceNo

		, ShearStrainPercent= xOR.ShearStrainPercent
		, StorageModulus_Pa	= xOR.StorageModulus_Pa 
		, LossModulus_Pa	= xOR.LossModulus_Pa

		FROM [SSIS_ENG].[fnRPT_xmlLAB_OscillatingRheometer_TestData]() xOR
			LEFT JOIN dbo.LAB_OscillatingRheometer_TestData		dOR ON dOR.ID_TestInfo = xOR.ID_TestInfo AND dOR.SequenceNo = xOR.SequenceNo
		WHERE xOR.ID_TestInfo IS NOT NULL
			AND dOR.ID_TestData IS NULL
					
	;

END 


GO

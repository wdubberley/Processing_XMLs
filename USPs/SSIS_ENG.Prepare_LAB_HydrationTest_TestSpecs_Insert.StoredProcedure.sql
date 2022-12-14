USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_HydrationTest_TestSpecs_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	20180915 (KPHAM)
  Modified:	20190415- Added new columns; 
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_HydrationTest_TestSpecs_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_HydrationTest_TestSpecs]
		([ID_LabInfo]
		,[TestNumber]
		,[ChandlerTestNo]
		,[WASampleLocation]
		
		,[BobType]
		,[RotorType]
		,[SpringFactor]
		,[SpeedFactor]
		,[RotorBobFactor]
		,[TargetViscosity_cP]
		,[InitialViscosity_cP]
		,[InitialHydrationTime_min]
		)

	SELECT [ID_LabInfo]	= xH.[ID_LabInfo]
		
		, [TestNumber]	= xH.[TestNumber]
		, [ChandlerTestNo]	= xH.ChandlerTestNo
		, [WASampleLocation]= xH.WASampleLocation

		, [BobType]			= xH.[BobType]
		, [RotorType]		= xH.[RotorType]
		, [SpringFactor]	= xH.[SpringFactor]
		, [SpeedFactor]		= xH.[SpeedFactor]
		, [RotorBobFactor]	= xH.[RotorBobFactor]

		, [TargetViscosity_cP]	= xH.TargetViscosity_cP
		, [InitialViscosity_cP]	= xH.InitialViscosity_cP
		, [InitialHydrationTime_min]	= xH.InitialHydrationTime_min
		
		FROM [SSIS_ENG].[fnRPT_xmlLAB_HydrationTest_TestSpecs]()	xH
			LEFT JOIN dbo.[LAB_HydrationTest_TestSpecs]			sH ON sH.ID_LabInfo = xH.ID_LabInfo AND sH.TestNumber = xH.TestNumber 

		WHERE xH.ID_LabInfo IS NOT NULL 
			AND sH.ID_TestInfo IS NULL
	;

END 


GO

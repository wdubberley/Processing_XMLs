USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_ChandlerTest_TestSpecs_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM
  Modified:	20190416- Added new columns; Re-order columns to match schema; moved obsolete columns to the end
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_ChandlerTest_TestSpecs_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_ChandlerTest_TestSpecs]
        ([ID_LabInfo]
        ,[TestNumber],[HydrationTestNo],[WASampleLocation]
        ,[Temperature],[TemperatureRamp]
        ,[BobSize],[ShearRatePerSecond],[APIShearScan]
        ,[TargetViscositycP],[InitalViscositycP],[InitialHydrationTime_min]
        ,[BaseFluidpH],[BufferedFluidpH],[XLinkpH]
        ,[WaterSource],[EndpH])

	SELECT [ID_LabInfo]			= xC.[ID_LabInfo]

		, [TestNumber]		= xC.[TestNumber]
		, [HydrationTestNo]	= xC.[HydrationTestNo]
		, [WASampleLocation]= xC.WASampleLocation

		, [Temperature]			= xC.[Temperature]
		, [TemperatureRamp]		= xC.[TemperatureRamp]
		, [BobSize]				= xC.[BobSize]
		, [ShearRatePerSecond]	= xC.[ShearRatePerSecond]
		, [APIShearScan]		= xC.[APIShearScan]
		, [TargetViscositycP]	= xC.[TargetViscositycP]
		, [InitalViscositycP]	= xC.[InitialViscositycP]
		, [InitialHydrationTime_min]= xC.InitialHydrationTimeMin
		, [BaseFluidpH]			= xC.[BaseFluidpH]
		, [BufferedFluidpH]		= xC.[BufferedFluidpH]
		, [XLinkpH]				= xC.[XLinkpH]
		
		/* Obsolete */
		, [WaterSource]			= xC.[WaterSource]
		, [EndpH]				= xC.[EndpH]

		FROM [SSIS_ENG].[fnRPT_xmlLAB_ChandlerTest_TestSpecs]()	xC
			LEFT JOIN dbo.[LAB_ChandlerTest_TestSpecs]		sC ON sC.ID_LabInfo = xC.ID_LabInfo AND sC.TestNumber = xC.TestNumber 

		WHERE sC.ID_TestInfo IS NULL

	;

END 


GO

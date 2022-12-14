USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracChemTotal_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	KPHAM (20190118)
  20220616(v002)- not process if ID_FracInfo is NULL
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracChemTotal_Insert]	
AS
BEGIN
	INSERT INTO dbo.[FracChemTotals]
		([ID_FracInfo]
		,[ID_FracStage]
		,[StageNo]
		,[ID_Chemical]
		,[Delivery]
		,[PrimeUp]
		,[Volume_Start]
		,[Volume_End]
		,[StrapOffset]
		,[Micro]
		,[NoCharge]
		,[OtherConsumption]
		,[StartPumpDown]
		,[EndPumpDown]
		,[PumpDownOffset]
		,[PumpDownTicket]
		,[StageStrap]
		,[StageDesign]
		,[StageDifference]
		,[StageVariance]
		,[FracFocus]
		,[TotalPumped]
		,[StageTicket]
		,[TotalTicket]
		,[JobDifference]
		,[JobVariance])

	SELECT ID_FracInfo			= xCT.ID_FracInfo
		, ID_FracStage			= xCT.ID_FracStage
		, StageNo				= xCT.Interval_No
		, ID_Chemical			= xCT.ID_Chemical
		, [Delivery]			= xCT.[Delivery]
        , [PrimeUp]				= xCT.[PrimeUp]
        , [Volume_Start]		= xCT.[Volume_Start]
        , [Volume_End]			= xCT.[Volume_End]
		, [StrapOffset]			= xCT.[StrapOffset]
        , [Micro]				= xCT.[Micro]
        , [NoCharge]			= xCT.[NoCharge]
		, [OtherConsumption]	= xCT.[OtherConsumption]
		, [StartPumpDown]		= xCT.[StartPumpDown]
		, [EndPumpDown]			= xCT.[EndPumpDown]
		, [PumpDownOffset]		= xCT.[PumpDownOffset]
        , [PumpDownTicket]		= xCT.[PumpDownTicket]
        , [StageStrap]			= xCT.[StageStrap]
        , [StageDesign]			= xCT.[StageDesign]
        , [StageDifference]		= xCT.[StageDifference]
        , [StageVariance]		= xCT.[StageVariance]
		, [FracFocus]			= xCT.[FracFocus]
        , [TotalPumped]			= xCT.[TotalPumped]
        , [StageTicket]			= xCT.[StageTicket]
        , [TotalTicket]			= xCT.[TotalTicket]
        , [JobDifference]		= xCT.[JobDifference]
        , [JobVariance]			= xCT.[JobVariance]

		FROM [SSIS_ENG].[fnRPT_xmlTS_FracStages_ChemTotals]() xCT
			LEFT JOIN dbo.[FracChemTotals] eCT
				ON eCT.ID_FracStage = xCT.ID_FracStage AND eCT.StageNo = xCT.Interval_No AND eCT.ID_Chemical = xCT.ID_Chemical
		WHERE eCT.ID_FracChemTotal IS NULL AND xCT.ID_FracStage IS NOT NULL 

			AND xCT.ID_FracInfo IS NOT NULL

	;

END 

GO

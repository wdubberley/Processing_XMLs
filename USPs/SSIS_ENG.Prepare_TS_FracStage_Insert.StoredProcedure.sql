USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracStage_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
  Created: KPHAM
  20190819(v003)- Added Pad_Inj section columns;
  20190930(v004)- Added Well_Swap_Type, Iron_Type, Injection_Type
  20191015(v005)- Added HPStart, HPEnd
  20200115(v006)- Added ISD/FSD_1st/2nd/3rd_WB_Fric (6 new columns); Remove Ramp#_Ave/PSI section
  20200121(v007)- Added Wireline_Type
  20200310(v008)- Added DesignStgTime, & N2 columns to track Nitrogen
  20200407(v009)- Restructure data into dbo.FracStageSummary
  20201217(v010)- Added HHP_HR formula as new Calculated column
  20201229(v011)- Added Missile_Type 
  20210421(v012)- Added TicketRangeNum, Recycled_Vol
  20211130(v013)- Added Ambient_Temperature
  20220719(v014)- Added AverageTotalRate
******************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracStage_Insert]	
AS
BEGIN
	
	WITH cte_eStages AS
		(SELECT eS.ID_FracStage, eS.ID_FracInfo, eS.StageNo, eS.Formation
			FROM dbo.FracStageSummary eS 
				INNER JOIN [SSIS_ENG].fnRPT_xmlTS_FracInfo() xFI ON xFI.ID_FracInfo = eS.ID_FracInfo AND eS.IsDeleted=0
		)
	
	--/****************************
	INSERT INTO dbo.FracStageSummary
		([ID_FracInfo]
		,[StageNo]
		,[EndFracDate]
		,[EndFracTime]
		,[Formation]
		,[FracPumpTime]
		,[ID_CompletionType]
		,[ID_Crew]
		,[ID_CustRep]
		,[ID_Engineer]
		,[ID_Supervisor]
		,[DesignType]
		,[StartFracDate]
		,[StartFracTime]
		,[Service_Charges_1]
		,[Service_Charges_2]
		,[Chemical_Charges]
		,[Proppant_Charges]
		,[Ticket_SubTotal]
		,[Additional_Discount]
		,[Ticket_Discount]
		,[Ticket_Total]
		,[Stage_Quote_Average]
		,[Price_Difference]
		,[Percentage]
		,[Notes_Price_Difference]
		,[Stage_Revenue_Per_Day_Charge]
		,[StageCost]
		,[TicketPercent]
		--,[IsDeleted]
		,[ID_Status]
		,[DateCreated]
		,[DateStatus]
		,[VersionNo]
		--,[ID_Archive]

		/***** TOTALS *******/
		,[CleanFrac]
		,[DesignClean]
		,[DesignProp]
		,[DesignSlurry]
		,[DesignSlurryRate]
		,[DesignStgTime]
		,[PercentCompleteBolBilledProp]
		,[PercentCompleteCleanFluid]
		,[PercentCompleteScrewProp]
		,[PercentCompleteWeightProp]
		,[PropStore_Handle_Actual]
		,[PropStore_Handle_Design]
		,[PropStore_Handle_NC]
		,[PropStore_Handle_Screw]
		,[TotalClean]
		,[TotallbsScrewProp]
		,[TotallbsWeightProp]
		,[TotalSlurry]
		
		/***** INPUTS *******/
		,[AvePSI]
		,[MaxPSI]
		,[AveRate]
		,[MaxRate]
		,[AveVisc]
		,[AveTemp]
		,[AvepH]
		,[CloseWHpsi]
		,[OpenWHPsi]
		,[CloseWHTime]
		,[HPonLoc]
		,[HPUsed]
		,[HPStart]
		,[HPEnd]
		,[AveHydraulicHP]
		,[LNG]
		,[CNG]
		,[Diesel]
		,[FracMHHP]
		,[Injection_Type]
		,[Iron_Type]
		,[MaxHydraulicHP]
		,[OpenWHTime]
		,[Screenout]
		,[Well_Swap_Type]
		,[Wireline_Type]

		/***** CALCULATED *******/
		,[HHP_HR]
		,[Ambient_Temperature]
		
		,[Missile_Type]
		,[TicketRangeNum]
		,[Recycled_Vol]
		,[AverageTotalRate]
		)
	--****************************************************************/

	SELECT DISTINCT
		[ID_FracInfo]	= xS.[ID_FracInfo]
		,[StageNo]		= xS.[StageNo]
		,[EndFracDate]	= xS.[EndFracDate]
		,[EndFracTime]	= xS.[EndFracTime]
		,[Formation]	= xS.[Formation]
		,[FracPumpTime]	= xS.[FracPumpTime]
		,[ID_CompletionType]= xS.[ID_CompletionType]
		,[ID_Crew]			= CASE WHEN xS.[ID_Crew] IS NULL THEN 0 ELSE xS.[ID_Crew] END
		,[ID_CustRep]		= CASE WHEN xS.[ID_CustRep] IS NULL THEN 0 ELSE xS.[ID_CustRep] END
		,[ID_Engineer]		= CASE WHEN xS.ID_Engineer IS NULL THEN 0 ELSE xS.ID_Engineer END	
		,[ID_Supervisor]	= CASE WHEN xS.[ID_Supervisor] IS NULL THEN 0 ELSE xS.ID_Supervisor END
		,[DesignType]		= xS.[DesignType]
		,[StartFracDate]	= xS.[StartFracDate]
		,[StartFracTime]	= xS.[StartFracTime]
		,[Service_Charges_1]= xS.[Service_Charges_1]
		,[Service_Charges_2]= xS.[Service_Charges_2]
		,[Chemical_Charges]	= xS.[Chemical_Charges]
		,[Proppant_Charges]	= xS.[Proppant_Charges]
		,[Ticket_SubTotal]	= xS.[Ticket_SubTotal]
		,[Additional_Discount]= xS.[Additional_Discount]
		,[Ticket_Discount]	= xS.[Ticket_Discount]
		,[Ticket_Total]		= xS.[Ticket_Total]
		,[Stage_Quote_Average]= xS.[Stage_Quote_Average]
		,[Price_Difference]	= xS.[Price_Difference]
		,[Percentage]		= xS.[Percentage]
		,[Notes_Price_Difference]		= xS.[Notes__Price_Difference_]
		,[Stage_Revenue_Per_Day_Charge]	= xS.[Stage_Revenue_Per_Day_Charge]
		,[StageCost]	= xS.[StageCost]
		,[TicketPercent]= xS.[TicketPercent]

		--,[IsDeleted]
		,[ID_Status]	= 1
		,[DateCreated]	= GETDATE()
		,[DateStatus]	= GETDATE()
		,[VersionNo]	= 1 + ISNULL((SELECT COUNT(*)
										FROM dbo.FracStageSummary t 
										WHERE t.ID_FracInfo = xS.ID_FracInfo AND t.StageNo = xS.StageNo 
										GROUP BY t.ID_FracInfo, t.StageNo), 0)
		--,[ID_Archive]

		/***** TOTALS *******/
		,[CleanFrac]	= xS.[CleanFrac]
		,[DesignClean]	= xS.[DesignClean]
		,[DesignProp]	= xS.[DesignProp]
		,[DesignSlurry]	= xS.[DesignSlurry]
		,[DesignSlurryRate]	= xS.[DesignSlurryRate]
		,[DesignStgTime]	= xS.[DesignStgTime]	
		,[PercentCompleteBolBilledProp]	= xS.[PercentCompleteBolBilledProp]
		,[PercentCompleteCleanFluid]	= xS.[PercentCompleteCleanFluid]
		,[PercentCompleteScrewProp]		= xS.[PercentCompleteScrewProp]
		,[PercentCompleteWeightProp]	= xS.[PercentCompleteWeightProp]
		,[PropStore_Handle_Actual]	= xS.[PropStore_Handle_Actual]
		,[PropStore_Handle_Design]	= xS.[PropStore_Handle_Design]
		,[PropStore_Handle_NC]		= xS.[PropStore_Handle_NC]
		,[PropStore_Handle_Screw]	= xS.[PropStore_Handle_Screw]
		,[TotalClean]	= xS.[TotalClean]
		,[TotallbsScrewProp]	= xS.[TotallbsScrewProp]
		,[TotallbsWeightProp]	= xS.[TotallbsWeightProp]
		,[TotalSlurry]	= xS.[TotalSlurry]
      
		/***** INPUTS *******/
		,[AvePSI]	= xS.[AvePSI]
		,[MaxPSI]	= xS.[MaxPSI]
		,[AveRate]	= xS.[AveRate]
		,[MaxRate]	= xS.[MaxRate]
		,[AveVisc]	= xS.[AveVisc]
		,[AveTemp]	= xS.[AveTemp]
		,[AvepH]	= xS.[AvepH]
		,[CloseWHpsi]	= xS.[CloseWHpsi]
		,[OpenWHPsi]	= xS.[OpenWHPsi]
		,[CloseWHTime]	= xS.[CloseWHTime]
		,[HPonLoc]	= xS.[HPonLoc]
		,[HPUsed]	= xS.[HPUsed]
		,[HPStart]	= xS.[HPStart]
		,[HPEnd]	= xS.[HPEnd]
		,[AveHydraulicHP]	= xS.[AveHydraulicHP]
		,[LNG]		= xS.[LNG]
		,[CNG]		= xS.[CNG]
		,[Diesel]	= xS.[Diesel]
		,[FracMHHP]	= xS.[FracMHHP]
		,[Injection_Type]	= xS.[Injection_Type]
		,[Iron_Type]		= xS.[Iron_Type]
		,[MaxHydraulicHP]	= xS.[MaxHydraulicHP]
		,[OpenWHTime]	= xS.[OpenWHTime]
		,[Screenout]	= xS.[Screenout]
		,[Well_Swap_Type]	= xS.[Well_Swap_Type]
		,[Wireline_Type]	= xS.[Wireline_Type]

		/***** CALCULATED *******/
		,[HHP_HR]	= xS.[HHP_HR]
		,[Ambient_Temperature]	= xS.[Ambient_Temperature]
		
		,[Missile_Type]	= xS.[Missile_Type]
		,[TicketRangeNum] = xS.[TicketRangeNum]
		,[Recycled_Vol]	= xS.[Recycled_Vol]
		,[AverageTotalRate] = xS.[AverageTotalRate]
		
	--select * 
	FROM [SSIS_ENG].fnRPT_xmlTS_FracStages() xS
		LEFT JOIN cte_eStages eS ON eS.ID_FracInfo = xS.ID_FracInfo AND eS.StageNo = xS.StageNo
			AND es.Formation=xS.Formation 

	WHERE eS.ID_FracStage IS NULL AND xS.ID_FracInfo IS NOT NULL
	ORDER BY ID_FracInfo, StageNo
	;

END 

GO

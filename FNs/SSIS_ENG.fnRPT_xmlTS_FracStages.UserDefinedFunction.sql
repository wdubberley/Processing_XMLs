USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracStages]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************
  20200120(v007)- Added ISD/FSD_1st/2nd/3rd_WB_Fric (6 new columns); Remove Ramp section
  20200120(v008)- Added Wireline_Type (1 new columns);
  20200310(v009)- Added 6 new columns 
  20201217(v010)- Added calculated column HHP_HR per TomFlynn
  20201229(v011)- Added Missile_Type per Cameron Davis/Akiko Billings; Remove Diverter section (no longer needed; has its own Diverter section)
  20210329(v012)- Modified HHP_HR formula to adjust conversion for Canadian jobs; Removed HES section (no longer needed)
  20211130(v013)- Added calculation to convert Ambient_Temp to F if ID_District is CAN; Assuming all other using F
  20210421(v013)- Added TicketRangeNum
  20220719(v015)- Added AverageTotalRate
*****************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracStages]()
RETURNS TABLE
AS
RETURN 
	SELECT eI.ID_FracInfo
		, StageNo				= CONVERT(INT, xS.Stage)
		, Formation				= ISNULL(xS.Formation,'')
		, ID_CompletionType		= CASE WHEN rCompType.ID_Record IS NULL THEN 0 ELSE rCompType.ID_Record END			/*20180215*/
		, ID_Supervisor			= rSupervisor.ID_Employee
		, ID_Engineer			= rEngineer.ID_Employee
		, ID_CustRep			= rRep.ID_Record
		, ID_Crew				= rC.ID_Crew
		, StartFracDate			= xS.StartFracDate
		, StartFracTime			= xS.StartFracTime
		, EndFracTime			= xS.EndFracTime
		, EndFracDate			= xS.EndFracDate
		, FracPumpTime			= xS.FracPumpTime
		, FracMHHP				= ISNULL(xS.FracMHHP, xS.MHHP)
		, LOSDT					= xS.LOSDT
		, [3rdDT]				= xS.[3rdDT]
		,[LOSDTReason]
		,[3rdDTReason]
		,[LOSDTComments]
		,[3rdDTComments]
		,[FracComments]
		,[WLDate]
		,[StartWLTime]
		,[EndWLTime]
		,[WLPumpTime]
		,[TotalPumpTime]
		,[FracWAHHP7_5Method]
		,[WLWAHHPAveRatePSIMethod]
		,[TotalWAHHP7_5Method]
		,[TotalWAHHPAveRatePsiMethod]
		,[TotalMHHP]
		,[DesignType]
		,[DesignClean]
		,[DesignProp]
		,[DesignSlurry]
		,[Screenout]					= CASE WHEN xS.Screenout LIKE 'N%' THEN 17
											WHEN xS.Screenout LIKE 'Y%' THEN 16 ELSE 15 END
		,[PercentCompleteCleanFluid]
		,[TotallbsScrewProp]			= CASE WHEN xS.EndFracTime IS NOT NULL THEN ISNULL(xS.[TotallbsScrewProp],0) ELSE xS.[TotallbsScrewProp] END
		,[TotallbsWeightProp]
		,[PercentCompleteScrewProp]
		,[PercentCompleteWeightProp]
		,[PercentCompleteBolBilledProp]
		,[PortPerf]
		,[NumPerfsPorts]
		,[PerfDiam]
		,[TotalnumPerfs]
		,[SleeveDepth1]
		,[SleeveDepth2]
		,[SleeveDepth3]
		,[TopShot]
		,[BottomShot]
		,[Plug]
		,[TVD]
		,[Sleeve1_Flush_Vol_Gal]
		,[Sleeve1_Flush_Vol_bbl]
		,[Sleeve2_Flush_Vol_Gal]
		,[Sleeve2_Flush_Vol_bbl]
		,[Sleeve3_Flush_Vol_Gal]
		,[Sleeve3_Flush_Vol_bbl]
		,[Top_Shot_Flush_Vol_Gal]
		,[Bottom_Shot_Flush_Vol_Gal]
		,[Plug_Flush_Vol_Gal]
		,[Top_Shot_Flush_Vol_bbl]
		,[Bottom_Shot_Flush_Vol_bbl]
		,[Plug_Flush_Vol_bbl]
		,[I_ISIP]
		,[I_BHISIP]
		,[I_FG_From_BHISIP]
		,[I_FG]
		,[F_ISIP]
		,[F_BHISIP]
		,[F_FG_From_BHISIP]
		,[F_FG]
		,[SurfaceEqClosurePSI]
		,[ClosureStressPsi]
		,[ClosureStressGradient]
		,[InitialShutinNetPsi]
		,[FinalShutinNetPSI]
		,[AvePSI]
		,[MaxPSI]
		,[AveRate]
		,[MaxRate]
		,[AveHydraulicHP]
		,[MaxHydraulicHP]
		,[PumpDownVol]
		,[InjectionTest]
		,[Clean_Other]
		,[CleanFrac]
		,[TotalClean]
		,[SlurryFrac]
		,[TotalSlurry]
		,[Prop_Ladden]
		,[Chems]			= REPLACE(REPLACE(xS.Chems,'_0',''),'_',',')
		,[Proppants]		= REPLACE(xS.Proppants,'_','')
		,[StageCost]
		,[BHST]
		,[Sleeve1_Early_Late]
		,[PlugBall_Early_Late]
		,[BallHit_Diff]
		,[PD_Company]
		,[PD_NumHP]
		,[PD_Equipment]
		,[PD_MeterType]
		,[PD_OpenWHTime]
		,[PD_OpenWHPSI]
		,[PD_StartTime]
		,[PD_EndTime]
		,[PD_RateMax]
		,[PD_PressureMax]
		,[PD_Freshbbls]
		,[PD_Brinebbls]
		,[PD_CloseWHTime]
		,[PD_CloseWHPSI]
		,[PERF_Type]
		,[PERF_Company]
		,[PERF_TotalNumShots]
		,[PERF_PerfDiam]
		,[PERF_NumPerfClusters]
		,[PERF_ClusterLength]
		,[PERF_Phasing]
		,[PERF_ShotPerFoot]
		,[PERF_TopShot]
		,[PERF_BottomShot]
		,[PERF_PlugDepth]
		,[BallSize]
		,[Sleeve_Depth1]
		,[Sleeve_Depth2]
		,[Sleeve_Depth3]
		,[MaxWorkingPSI]
		,[GlobalTrips]
		,[PopOffSet_L]
		,[PopOffSet_H]
		,[PressureTestPsi]
		,[OpenWHTime]
		,[OpenWHPsi]
		,[AcidDisplaceRate]
		,[BallDropVol]
		,[BallHitVol]
		,[Ball_Initial]
		,[Ball_Max]
		,[Ball_Final]
		,[Ball_Rate]
		,[BallAction]						/*** ADDED 2016.10.17 ***/
		,[BD_Rate]
		,[BD_Psi]
		,[FR_Benefit]
		,[FR_FlowRate]
		,[FR_Temp]
		,[ISD_1st_Rate]
		,[ISD_1st_PSI]
		,[ISD_1st_BHP]
		,[ISD_2nd_Rate]
		,[ISD_2nd_PSI]
		,[ISD_2nd_BHP]
		,[ISD_3rd_Rate]
		,[ISD_3rd_PSI]
		,[ISD_3rd_BHP]
		,[ISD_MaxRate]
		,[ISD_WB_Fric]
		,[ISD_NWB_Fric]
		,[ISD_Perf_Fric]
		,[ISD_T_Fric]
		,[ISD_Perfs_Open]
		,[I_1Min]
		,[I_2Min]
		,[I_5Min]
		,[I_10Min]
		,[I_15Min]
		,[FSD_1st_Rate]
		,[FSD_1st_PSI]
		,[FSD_1st_BHP]
		,[FSD_2nd_Rate]
		,[FSD_2nd_PSI]
		,[FSD_2nd_BHP]
		,[FSD_3rd_Rate]
		,[FSD_3rd_PSI]
		,[FSD_3rd_BHP]
		,[FSD_MaxRate]
		,[FSD_WB_Fric]
		,[FSD_NWB_Fric]
		,[FSD_Perf_Fric]
		,[FSD_T_Fric]
		,[FSD_Perfs_Open]
		,[F_1Min]
		,[F_2Min]
		,[F_5Min]
		,[F_10Min]
		,[F_15Min]
		,[HPUsed]
		,[HPonLoc]
		,[AveVisc]
		,[AveTemp]
		,[AvepH]
		,[AveHHP]
		,[MaxHHP]
		,[ActualFlush]
		,[OverFlush]
		,[CloseWHTime]
		,[CloseWHpsi]
		,[Accident]
		,[Flowback_Vol]
		,[KCLStartStrap]
		,[KCLEndStrap]
		,[WaterStartStrap]
		,[WaterEndStrap]
		/*** REMOVED :: 20210331 **********************
		,[Hes_StableRateBeforeHes]
		,[Hes_StableBHPBeforeHes]
		,[Hes_NumDiversionBalls]
		,[Hes_RateAtBallSeat]
		,[Hes_PSIBeforeBallSeat]
		,[Hes_MaxPSIAtBallSeat]
		,[Hes_PsiAfterBallSeat]
		,[Hes_DiverterType]
		,[Hes_LBSDiverter]
		,[Hes_LengthofHes]
		,[Hes_BrineInHesYN]
		,[Hes_AcidInHesYN]
		,[Hes_StableRateAfterHes]
		,[Hes_StableBHPAfterHes]
		--************************************************/
		,[Design_TS]
		,[Design_BS]
		,[Design_PD]
		,[DeltaTS]
		,[DeltaBS]
		,[DeltaPD]

		/***** 20200115- Remove ramp section
		,[Ramp1_Avg_PSI]
		,[Ramp1_Avg_Rate]
		,[Ramp2_Avg_PSI]
		,[Ramp2_Avg_Rate]
		,[Ramp3_Avg_PSI]
		,[Ramp3_Avg_Rate]
		,[Ramp4_Avg_PSI]
		,[Ramp4_Avg_Rate]
		,[Ramp5_Avg_PSI]
		,[Ramp5_Avg_Rate]
		,[Ramp6_Avg_PSI]
		,[Ramp6_Avg_Rate]
		,[Ramp7_Avg_PSI]
		,[Ramp7_Avg_Rate]
		,[Ramp8_Avg_PSI]
		,[Ramp8_Avg_Rate]
		,[Ramp9_Avg_PSI]
		,[Ramp9_Avg_Rate]
		,[Ramp10_Avg_PSI]
		,[Ramp10_Avg_Rate]
		*************************************************************/

		,[WaterStrap]
		,[BHConcAvg]
		,[BHConcMax]
		,[WaterToLocTemp]
		,[WaterToLocRate]
		,[IntervalDescription]
		,[NumberBalls]

		,[Max_Prop_Conc]
		,[Job_Type]
		,[PD_Comm_Y_N]
		,[Delta_psi]
		,[DVA_DeltaPressure]

		,[Breakdown_Vol]
		,[Acid_Vol]
		,[Pad_Vol]
		,[PLF_Vol]
		,[Flush_Vol]
		,[Shut_Down_Vol]
		,[Pump_Down_Vol]
		,[PropStore_Handle_Screw]
		,[PropStore_Handle_Actual]
		,[PropStore_Handle_NC]
		,[PropStore_Handle_Design]
		,FilePath						
		
		,[BHConc_Max_100_Mesh]
		,[BHConcAvg_100_Mesh]
		,[BHConc_Max_4070_White]
		,[BHConcAvg_4070_White]
		,[BHConc_Max_4070_CRC]
		,[BHConcAvg_4070_CRC]
		
		,[WL_Communication]
		,[Btm_Max_Prop_40_70]
		,[Btm_Max_Prop_CRC]

		,[LNG]
		,[TicketCount]

		,[Service_Charges_1]
		,[Service_Charges_2]
		,[Chemical_Charges]
		,[Proppant_Charges]
		,[Ticket_SubTotal]
		,[Additional_Discount]
		,[Ticket_Total]
		,[Ticket_Discount]

		,[Tot_Clean_PD]
		,[ThirdNP]
		,[LOSNP]
		,[TotalNP]
		,[TotalNPT]
		,[QAQC]
		,[ID_QAQC]		= CASE WHEN rQAQC.ID_Employee IS NULL THEN 0 ELSE rQAQC.ID_Employee END

		,[Stage_Quote_Average]
		,[Price_Difference]
		,[Percentage]
		,[Notes__Price_Difference_]
		,[DesignSlurryRate]

		,[MaxFlushPSI]
		,[BallHitTime]
		,[Stage_Revenue_Per_Day_Charge]

		,[WL_Well]
		,[Communication_Start_Time]
		,[Communication_End_Time]
		,[Communication_Duration]
		,[Communication_DeltaPSI]

		,[SMPB_TotalClean_Acid_PD_Brine]
		,[SMPB_TotalSlurry_PD_Brine]

		,[MaxBHPSI]
		,[AveBHPSI]
		,[AveInj]

		/***** 20201229- Remove Diverter section
		,[Ramp1_Stable_Rate_1]
		,[Ramp1_Stable_BH_Pressure_1]
		,[Ramp1_Avg_PSI_Before_Diversion_1]
		,[Ramp1_Avg_Rate_Before_Diversion_1]
		,[Ramp1_Diverter_Landing_Rate_1]
		,[Diversion1_Diverter_Hit_Rate_1]
		,[Diversion1_BH_Pressure_Before_Diverter_1]
		,[Diversion1_BH_Max_Pressure_at_Diverter_Landing_1]
		,[Diversion1_BH_Pressure_after_Diverter_Landing_1]
		,[Diversion1_Delta_Pressure_After_Diverter_1]
		,[Diversion1_Diverter_Type_1_1]
		,[Diversion1_Lbs_of_Diverter_Type_1_1]
		,[Diversion1_Diverter_Type_2_1]
		,[Diversion1_Lbs_of_Diverter_Type_2_1]
		,[Diversion1_Total_Lbs_Diverter_1]

		,[Ramp2_Stable_Rate_2]
		,[Ramp2_Stable_BH_Pressure_2]
		,[Ramp2_Avg_PSI_Post_Diversion_2]
		,[Ramp2_Avg_Rate_Post_Diversion_2]
		,[Diversion2_Diverter_Hit_Rate_2]
		,[Diversion2_BH_Pressure_Before_Diverter_2]
		,[Diversion2_BH_Max_Pressure_at_Diverter_Landing_2]
		,[Diversion2_BH_Pressure_after_Diverter_Landing_2]
		,[Diversion2_Delta_Pressure_After_Diverter_2]
		,[Diversion2_Diverter_Type_1_2]
		,[Diversion2_Lbs_of_Diverter_Type_1_2]
		,[Diversion2_Diverter_Type_2_2]
		,[Diversion2_Lbs_of_Diverter_Type_2_2]
		,[Diversion2_Total_Lbs_Diverter_2]

		,[Ramp3_Stable_Rate_3]
		,[Ramp3_Stable_BH_Pressure_3]
		,[Ramp3_Avg_PSI_Post_Diversion_3]
		,[Ramp3_Avg_Rate_Post_Diversion_3]
		,[Diversion3_Diverter_Hit_Rate_3]
		,[Diversion3_BH_Pressure_Before_Diverter_3]
		,[Diversion3_BH_Max_Pressure_at_Diverter_Landing_3]
		,[Diversion3_BH_Pressure_after_Diverter_Landing_3]
		,[Diversion3_Delta_Pressure_After_Diverter_3]
		,[Diversion3_Diverter_Type_1_3]
		,[Diversion3_Lbs_of_Diverter_Type_1_3]
		,[Diversion3_Diverter_Type_2_3]
		,[Diversion3_Lbs_of_Diverter_Type_2_3]
		,[Diversion3_Total_Lbs_Diverter_3]
		*************************************************************/

		,[AveCoilPSI]
		,[AveSurfacePSI]
		,[AveBacksidePSI]
		,[MaxCoilPSI]
		,[MaxSurfacePSI]
		,[MaxBacksidePSI]
		,[ISD_Start_Rate]
		,[ISD_Start_PSI]
		,[ISD_Start_BHP]
		,[FSD_StartRate]
		,[FSD_Start_PSI]
		,[FSD_Start_BHP]

		,[Open_WH_Backside_PSI]
		,[Rate_Pre_Proppant]
		,[PSI_Pre_Proppant]
		
		,[TicketPercent]

		,[CNG]
		,[Recycled_Vol]
		,[Diesel]

		,[Blender_Discharge_Pressure]
		,[Blender_Engine_RPM]

		/*20180313*/
		,[Acid_Relief]
		,[Average_RPM_4007]
		,[Discharge_Pressure_4007]
		,[Average_RPM_4008]
		,[Discharge_Pressure_4008]

		/*20180326*/
		,[MinCoilPSI]
		,[MinSurfacePSI]
		,[MinBacksidePSI]
		,[DailyStageCountDiscount]
		,[HourlyNormalCharge]
		,[HourlyDiscountCharge]

		/*20190320*/
		,[MSD_Start_Rate]
		,[MSD_Start_WB_Fric]
		,[MSD_Start_PSI]
		,[MSD_Start_BHP]
		,[MSD_1st_Rate]
		,[MSD_1st_WB_Fric]
		,[MSD_1st_PSI]
		,[MSD_1st_BHP]
		,[MSD_2nd_Rate]
		,[MSD_2nd_WB_Fric]
		,[MSD_2nd_PSI]
		,[MSD_2nd_BHP]
		,[MSD_3rd_Rate]
		,[MSD_3rd_WB_Fric]
		,[MSD_3rd_BHP]
		,[MSD_NWB_Fric]
		,[MSD_Perf_Fric]
		,[MSD_T_Fric]
		,[MSD_Perfs_Open]
		,[MSD_ISIP]
		,[MSD_BHISIP]
		,[M_5Min]

		/*20190819*/
		,[Pad_Injectivity]
		,[Pad_Inj_Start_BHP]
		,[Pad_Inj_End_BHP]
		,[Pad_Inj_Start_Rate]
		,[Pad_Inj_End_Rate]
		,[Pad_Inj_Start_Time]
		,[Pad_Inj_End_Time]
		,[Pad_Inj_Value]
		,[Sync_Offset]
		,[Sync_Wells]

		/*20190930*/
		,[Well_Swap_Type]
		,[Iron_Type]
		,[Injection_Type]

		/*20191015*/
		,[HPStart]
		,[HPEnd]
		
		/*20200115*/
		,[ISD_1st_WB_Fric]
		,[ISD_2nd_WB_Fric]
		,[ISD_3rd_WB_Fric]
		,[FSD_1st_WB_Fric]
		,[FSD_2nd_WB_Fric]
		,[FSD_3rd_WB_Fric]
		
		/*20200115*/
		,[Wireline_Type]		
		
		/*20200310*/
		,[DesignStgTime]		
		,[MaxN2Rate]		
		,[AveN2Rate]		
		,[BHN2Factor]		
		,[TotalBtmHoleFluid_Vol]		
		,[Nitrogen_Vol]		

		/* 20201217 - Calculated column */
		,[HHP_HR]	= CASE WHEN eI.ID_District = 11 THEN 912.2614628  ELSE 1 END
					* ( (ISNULL(xS.FracPumpTime, 0)/60.0) * (ISNULL(xS.avePSI,0)) * (ISNULL(xS.aveRate, 0)) ) / 40.8
		
		/* 20201229 - Missile_Type */
		,[Missile_Type]	
		/* 20210121 - Missile_Type */
		,[TicketRangeNum]
		
		/* 20211130 - Ambient_Temperature; Conversion to F if project is CAN */
		,[Ambient_Temperature]	= CASE WHEN xS.[Ambient_Temperature] IS NOT NULL 
									THEN (CASE WHEN eI.bID_District NOT IN (11) 
										THEN xS.[Ambient_Temperature]
										ELSE ((9.00/5.00 * xS.[Ambient_Temperature]) + 32)		-- do conversion to F
										END
										)
									ELSE NULL END
		/* 20220719j */
		,[AverageTotalRate] 
		
		,WellName		= xS.WellName
		,Crew			= xS.Crew
		,FileDate		= xS.FileDate
	  --, xS.* 

	FROM [SSIS_ENG].xmlImport_TS_FracStages xS
		INNER JOIN [SSIS_ENG].fnRPT_xmlTS_FracInfo() eI ON eI.WellName = xS.WellName
		
		/* 20190312 */
		LEFT JOIN (SELECT * FROM dbo.ref_Categories WHERE ID_Parent=1) rCompType ON rCompType.ItemName = xS.CompletionType
		LEFT JOIN [SSIS_ENG].mapping_Employees rSupervisor 
			ON rSupervisor.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xS.Supervisor))) = 0 
												THEN LTRIM(RTRIM(ISNULL(xS.Supervisor, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xS.Supervisor, '')))
											ELSE LTRIM(RTRIM(ISNULL(xS.Supervisor, ''))) END --xS.Supervisor
		LEFT JOIN [SSIS_ENG].mapping_Employees rEngineer 
			ON rEngineer.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xS.Engineer))) = 0 
												THEN LTRIM(RTRIM(ISNULL(xS.Engineer, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xS.Engineer, '')))
											ELSE LTRIM(RTRIM(ISNULL(xS.Engineer, ''))) END --xS.Engineer
		LEFT JOIN [SSIS_ENG].mapping_Employees rQAQC 
			ON rQAQC.EmployeeName = CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(xS.QAQC))) = 0 
												THEN LTRIM(RTRIM(ISNULL(xS.QAQC, ''))) + ' ' + LTRIM(RTRIM(ISNULL(xS.QAQC, '')))
											ELSE LTRIM(RTRIM(ISNULL(xS.QAQC, ''))) END --xS.QAQC
		
		LEFT JOIN dbo.ref_Representatives rRep ON rRep.FirstName + ' ' + rRep.LastName = xS.CustomerRep
		LEFT JOIN dbo.ref_Crews rC ON rC.CrewName=xS.Crew OR rC.CrewNameAlt=xS.Crew
		
	WHERE xS.StartFracDate is not null or xS.EndFracDate IS NOT NULL
		AND (YEAR(xS.StartFracDate) >= 2012)


GO

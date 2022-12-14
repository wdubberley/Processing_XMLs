USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_MicrobeTestingSample_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	20180914 (KPHAM)
  Modified:	20190415- Added columns; Moved unused columns to bottom of selection
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_MicrobeTestingSample_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_MicrobeTestingSamples]
        ([ID_LabInfo]
		,[SampleNo]
		,[RLUUC1]
		,[SampleVolume]
		,[RLUcATP]
		,[ATPConc]
		,[LogMicroEqvsPERmL]
		,[DesiredMaxLevel]
		,[LogMicroEquivsPERmLvsMaxAccLevel]
		,[LogMicroEquivOverMaxAccLevel]
		,[WASampleLocation]
		,[WARunID]
		,[Set_Point]
		,[Bio_Type]
		,[Run_Name]
		,[Microbial_Test]
		,[Biocide_Concentration]
		,[Incubation_Period]
		,[ATPConc_ME]
		,[Percent_CATP_Decrease_fr_Control]
		,[BART_SRB_Test]
		,[BART_APB_Test]
		,[BART_HAB_Test]
		,[BART_SLYM_Test]
		,[BART_IRB_Test]
		,[Rec_Biocide_Dosage]
		,[Notes]
		,[SampleCollectionPointIdentifier]
		,[TotalBacteriaPERmL]
		)

	SELECT [ID_LabInfo]	= xMT.[ID_LabInfo]

		, [SampleNo]	= xMT.[SampleNo]
		
		, [RLUUC1]			= xMT.[RLUUC1]
		, [SampleVolume]	= xMT.[SampleVolume]
		, [RLUcATP]			= xMT.[RLUcATP]
		, [ATPConc]			= xMT.[ATPConc]
		, [LogMicroEqvsPERmL]	= xMT.[LogMicroEqvsPERmL]
		, [DesiredMaxLevel]		= xMT.[DesiredMaxLevel]
		, [LogMicroEquivsPERmLvsMaxAccLevel]	= xMT.[LogMicroEquivsPERmLvsMaxAccLevel]
		, [LogMicroEquivOverMaxAccLevel]		= xMT.[LogMicroEquivOverMaxAccLevel]

		, [WASampleLocation]	= xMT.WASampleLocation
		, [WARunID]				= xMT.WARunID
		, [Set_Point]	= xMT.Set_Point
		, [Bio_Type]	= xMT.Bio_Type
		, [Run_Name]	= xMT.Run_Name
		, [Microbial_Test]	= xMT.Microbial_Test
		, [Biocide_Concentration]	= xMT.Biocide_Concentration
		, [Incubation_Period]		= xMT.Incubation_Period
		, [ATPConc_ME]				= xMT.ATPConc_ME
		, [Percent_CATP_Decrease_fr_Control]	= xMT.Percent_CATP_Decrease_fr_Control

		, [BART_SRB_Test]	= xMT.BART_SRB_Test
		, [BART_APB_Test]	= xMT.BART_APB_Test
		, [BART_HAB_Test]	= xMT.BART_HAB_Test
		, [BART_SLYM_Test]	= xMT.BART_SLYM_Test
		, [BART_IRB_Test]	= xMT.BART_IRB_Test

		, [Rec_Biocide_Dosage]	= xMT.Rec_Biocide_Dosage
		, [Notes]	= xMT.Notes

		, [SampleCollectionPointIdentifier] = xMT.[SampleCollectionPointIdentifier]
		, [TotalBacteriaPERmL]	= xMT.[TotalBacteriaPERmL]
		

		FROM [SSIS_ENG].[fnRPT_xmlLAB_MicrobeTestingSamples]()	xMT
			LEFT JOIN dbo.[LAB_MicrobeTestingSamples]		sMT ON sMT.ID_LabInfo = xMT.ID_LabInfo AND sMT.SampleNo	= xMT.SampleNo 

		WHERE sMT.ID_MicrobeSample IS NULL

	;

END 


GO

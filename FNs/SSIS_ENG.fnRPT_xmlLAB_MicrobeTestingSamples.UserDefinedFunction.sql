USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_MicrobeTestingSamples]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 
  CREATED:	20180815 (KPHAM)
  Modified:	20190415- Added new columns; Modified join to xInfo by ID_Pad
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_MicrobeTestingSamples]()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LabInfo		= xI.ID_LabInfo
		, SampleNo			= xMT.SampleCollectionNumber
		
		, WASampleLocation	= xMT.WASampleLocation
		, WARunID			= xMT.WA_Analysis_Run_ID
		, SampleVolume		= xMT.SampleVolume

		, Set_Point				= xMT.Set_Point
		, Bio_Type				= xMT.Bio_Type
		, Run_Name				= xMT.Run_Name
		, Microbial_Test		= xMT.Microbial_Test
		, Biocide_Concentration	= xMT.Biocide_Concentration

		, RLUUC1			= xMT.RLUUC1
		, RLUcATP			= xMT.RLUcATP
		, Incubation_Period = xMT.Incubation_Period
		, ATPConc			= xMT.ATPConc
		, ATPConc_ME		= xMT.ATPConc_ME
		, Percent_CATP_Decrease_fr_Control	= xMT.Percent_CATP_Decrease_from_Control
				
		, LogMicroEqvsPERmL		= xMT.LogMicroEqvsPERmL
		, DesiredMaxLevel		= xMT.DesiredMaxLevel
		, LogMicroEquivsPERmLvsMaxAccLevel	= xMT.LogMicroEquivsPERmLvsMaxAccLevel
		, LogMicroEquivOverMaxAccLevel		= xMT.LogMicroEquivOverMaxAccLevel

		, BART_SRB_Test		= xMT.BART_SRB_Test
		, BART_APB_Test		= xMT.BART_APB_Test
		, BART_HAB_Test		= xMT.BART_HAB_Test
		, BART_SLYM_Test	= xMT.BART_SLYM_Test
		, BART_IRB_Test		= xMT.BART_IRB_Test
		, Rec_Biocide_Dosage	= xMT.Rec__Biocide_Dosage

		, Notes	= xMT.Notes

		--, xMT.*
		, ID_Pad	= xI.ID_Pad
		, PadNumber	= xMT.PadNumber
		
		/*** OBSOLETE ***/
		, PadName	= xI.PadName
		, SampleCollectionPointIdentifier	= xMT.SampleCollectionPointIdentifier
		, TotalBacteriaPERmL	= xMT.TotalBacteriaPERmL
		
		FROM [SSIS_ENG].xmlImport_LAB_MicrobeTesting_SampleCollection xMT
			INNER JOIN [SSIS_ENG].fnrpt_xmlLAB_Info()	xI ON xI.ID_Pad = xMT.ID_Pad

	;


GO

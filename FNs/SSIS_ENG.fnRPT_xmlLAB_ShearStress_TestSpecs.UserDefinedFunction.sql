USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_TestSpecs]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
  CREATED:	20190417 (KPHAM)
  Modified:	
******/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlLAB_ShearStress_TestSpecs] ()
RETURNS TABLE
AS
RETURN 
		
	SELECT ID_LabInfo	= xI.ID_LabInfo

		, TestNumber		= xOR.OscillatingRheometerTestNumber
		, WASampleLocation	= xOR.WASampleLocation
		
		, Viscometer_Model	= xOR.Viscometer_Model
		, Rotor	= xOR.Rotor
		, Bob	= xOR.Bob
		, Torsion_Spring	= xOR.Torsion_Spring

		, rowID		= ROW_NUMBER() OVER(ORDER BY xOR.ID_Record)
		, ID_Pad	= xOR.ID_Pad
		, PadNumber	= xOR.PadNumber
		--, xOR.*
		
		FROM [SSIS_ENG].[xmlImport_LAB_ShearStress_TestSpecs]	xOR
			INNER JOIN [SSIS_ENG].fnrpt_xmlLAB_Info()			xI ON xI.ID_Pad = xOR.ID_Pad

	;


GO

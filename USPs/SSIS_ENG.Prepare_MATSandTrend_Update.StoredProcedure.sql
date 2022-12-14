USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATSandTrend_Update]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  20201106(v002)- Added additional filter for Update to also match by RowNo
  20211104(v003)- Updated scripts to improve loading time
************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATSandTrend_Update]	
AS
BEGIN

	UPDATE sST
		SET sST.[Date_Time]	= xST.[Date_Time]
		--, sST.[ID_WellInfo]	= sWI.[ID_WellInfo]
		--, sST.[StageNo]		= xST.[StageNo]
		, sST.[Design]		= xST.[Design]
		, sST.[Shut_In]		= xST.[Shut_In]
		, sST.[Screw]		= xST.[Screw]
		, sST.[lbl_Rev]		= xST.[lbl_Rev]
		, sST.[BlenderNo]	= xST.[BlenderNo]
		, sST.[TActPump]	= xST.[TActPump]
		--, sST.[Well]		= xST.[Well]
		
		, sST.[Pad_Variance]	= xST.[Pad_Variance]
		, sST.[Design_Qty]		= xST.[Design_Qty]
		, sST.[Screw_Qty]		= xST.[Screw_Qty]
		, sST.[PPR]				= xST.[PPR]
		--, sST.RowNo				= xST.RowNo

	--select *--, sWI.ID_WellInfo
		FROM [SSIS_ENG].[fnRPT_xmlMAT_SandTrends_test]()	xST
			INNER JOIN dbo.Material_WellInfo	sWI ON (sWI.ID_MaterialInfo=xST.ID_MaterialInfo AND sWI.WellName = xST.Well)
			INNER JOIN dbo.Material_SandTrends	sST ON (sST.ID_MaterialInfo = xST.ID_MaterialInfo 
														AND sST.Well = xST.Well 
														AND sST.ID_WellInfo = sWI.ID_WellInfo
														AND sST.StageNo = xST.StageNo 
														AND sST.ID_SandInfo = xST.ID_SandInfo
														AND sST.RowNo = xST.RowNo					/* 20201105 */
														)
	;

END 

GO

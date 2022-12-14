USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_MATSandTrend_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
  20201105(v002)- Added additional filter for Insertion to also match by RowNo
  20211104(v003)- Updated scripts to improve loading time
************************************************************************************/
CREATE PROCEDURE [SSIS_ENG].[Prepare_MATSandTrend_Insert]	
AS
BEGIN
	
	INSERT INTO dbo.[Material_SandTrends]
		([ID_MaterialInfo]
		, [ID_SandInfo]
		, [RowNo]
		, [Date_Time]
		, [ID_WellInfo]
		, [StageNo]
		, [Design]
		, [Shut_In]
		, [Screw]
		, [lbl_Rev]
		, [BlenderNo]
		, [TActPump]
		, [Well]
		, [Pad_Variance]
		, [Design_Qty]
		, [Screw_Qty]
		, [PPR])

	SELECT ID_MaterialInfo	= xST.ID_MaterialInfo
		, ID_SandInfo		= xST.ID_SandInfo

		, [RowNo]			= xST.[RowNo]
		, [Date_Time]		= CONVERT(DATETIME,xST.[Date_Time])
		, [ID_WellInfo]		= sWI.[ID_WellInfo]
		, [StageNo]			= xST.[StageNo]
		, [Design]			= xST.[Design]
		, [Shut_In]			= xST.[Shut_In]
		, [Screw]			= xST.[Screw]
		, [lbl_Rev]			= xST.[lbl_Rev]
		, [BlenderNo]		= xST.[BlenderNo]
		, [TActPump]		= xST.[TActPump]

		, [Well]			= xST.[Well]

		, [Pad_Variance]	= xST.[Pad_Variance]
		, [Design_Qty]		= xST.[Design_Qty]
		, [Screw_Qty]		= xST.[Screw_Qty]
		, [PPR]				= xST.[PPR]
		--, xST.*
		--, sSt.ID_SandTrend
	
		FROM [SSIS_ENG].[fnRPT_xmlMAT_SandTrends_test]()	xST
			INNER JOIN dbo.Material_WellInfo	sWI ON (sWI.ID_MaterialInfo = xST.ID_MaterialInfo AND sWI.WellName = xST.Well)
			LEFT JOIN dbo.Material_SandTrends	sST ON (sST.ID_MaterialInfo = xST.ID_MaterialInfo 
														AND sST.Well = xST.Well 
														AND sST.ID_WellInfo = sWI.ID_WellInfo
														AND sST.StageNo = xST.StageNo 
														AND sST.ID_SandInfo = xST.ID_SandInfo
														AND sST.RowNo = xST.RowNo					/* 20201105 */
														)
			
		WHERE sST.ID_SandTrend IS NULL
		--order by xst.RowNo
	;

END 

GO

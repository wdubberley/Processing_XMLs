USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_SandTrends_test]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [FieldData]
--GO

--/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlMAT_SandTrends]    Script Date: 11/4/2021 1:05:49 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

/***********************************************************************************
  20211104(v002)- Updated scripts to improve loading time
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlMAT_SandTrends_test]()
RETURNS --TABLE
	@tblMAT_Trends TABLE (ID_MaterialInfo INT, ID_SandInfo INT
				, [RowNo] INT,	[Date_Time] [datetime], [Well] [nvarchar](255), [StageNo] INT
				, [Design] decimal(18,6), [Shut_In] decimal(18,6), [Screw] decimal(18,6)
				, [lbl_Rev] [nvarchar](255), [BlenderNo] [nvarchar](255), [TActPump] decimal(18,6)
				, [Pad_Variance] FLOAT, [Design_Qty] [decimal](18,6), [Screw_Qty] [decimal](18,6), [PPR] [nvarchar](255)
				, [xmlFileName] [nvarchar](255) NOT NULL, [SandName] [nvarchar](255) NOT NULL
				)
AS
BEGIN 

	/************* TEST 
	declare @tblMAT_Trends TABLE (ID_MaterialInfo INT, ID_SandInfo INT
			, [RowNo] INT,	[Date_Time] [datetime], [Well] [nvarchar](255), [StageNo] INT
			, [Design] decimal(18,6), [Shut_In] decimal(18,6), [Screw] decimal(18,6)
			, [lbl_Rev] [nvarchar](255), [BlenderNo] [nvarchar](255), [TActPump] decimal(18,6)
			, [Pad_Variance] FLOAT, [Design_Qty] [decimal](18,6), [Screw_Qty] [decimal](18,6), [PPR] [nvarchar](255)
			, [xmlFileName] [nvarchar](255) NOT NULL, [SandName] [nvarchar](255) NOT NULL
			)
	--*******************************************************************/

	declare @tbl_Sands as table (ID_MaterialInfo INT, ID_Proppant INT, ID_SandInfo INT, SandName VARCHAR(100), mFileName VARCHAR(MaX))
	insert into @tbl_Sands
	select ID_MaterialInfo	= mSI.ID_MaterialInfo
			, ID_Proppant	= mSI.ID_Proppant
			, ID_SandInfo	= mSI.ID_SandInfo
			, SandName		= xSI.SandName
			, mFileName		= xSI.xmlFileName
			from [SSIS_ENG].fnRPT_xmlMAT_SandInfo()		xSI
				inner join [dbo].[Material_SandInfo]	mSI On mSI.ID_MaterialInfo = xSI.ID_MaterialInfo and mSI.ID_Proppant = xSI.ID_Proppant

	insert into @tblMAT_Trends
	SELECT ID_MaterialInfo		= xI.ID_MaterialInfo
		, [ID_SandInfo]			= xI.ID_SandInfo
		
		, [RowNo]				= xST.[RowNo]
		, [Date_Time]			= xST.[Date_Time]
		, [Well]				= xST.[Well]
		, [StageNo]				= ISNULL(xST.[Stage],0)
		, [Design]				= xST.[Design]
		, [Shut_In]				= xST.[Shut_In]
		, [Screw]				= xST.[Shut_In]
		, [lbl_Rev]				= xST.[lbl_Rev]
		, [BlenderNo]			= xST.[BlenderNo]
		, [TActPump]			= xST.[TActPump]

		, [Pad_Variance]		= xST.[Pad_Variance]
		, [Design_Qty]			= xST.[Design_Qty]
		, [Screw_Qty]			= xST.[Screw_Qty]
		, [PPR]					= xST.[PPR]

		, xmlFileName			= xST.[FileName]
		, SandName				= xST.SandName

		--, [ID_FracInfo]
		--, [ID_Pad]				= sMI.ID_Pad

		--, xST.*
		--, xI.*
		
		FROM [SSIS_ENG].xmlImport_MAT_SandTrends	xST
			INNER JOIN @tbl_Sands					xI ON xI.mFileName = xST.[FileName] AND xI.SandName = xST.SandName
			

	--select @tblMAT_Trends
	RETURN 
END

GO

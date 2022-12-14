USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_LAB_Info_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
  Created:	20180914 (KPHAM)
  Modified:	20190415- Added new columns;
******/
CREATE PROCEDURE [SSIS_ENG].[Prepare_LAB_Info_Insert]	
AS
BEGIN

	INSERT INTO [dbo].[LAB_Info]
		([ID_Pad]
		,[MacroVersion],[xmlFileName],[xmlDate]
		,[PadName],[PadNumber]
		,[TestPerformedBy],[CompanyName],[TestingLocation],[TestingAddress],[TestingAddress2],[Phone_Number]
		,[DateOfTest],[Fluid_System],[Developmental])

	SELECT [ID_Pad]		= xL.ID_Pad

		,[MacroVersion]	= xL.MacroVersion
		,[xmlFileName]	= xL.xmlFileName
		,[xmlDate]		= xL.xmlDate
      
		,[PadName]		= xL.PadName
		,[PadNumber]	= xL.PadNumber
      
		,[TestPerformedBy]	= xL.TestPerformedBy
		,[CompanyName]		= xL.CompanyName
		,[TestingLocation]	= xL.TestingLocation
		,[TestingAddress]	= xL.TestingAddress
		,[TestingAddress2]	= xL.TestingAddress2
		,[Phone_Number]		= xL.Phone_Number
		,[DateOfTest]		= xL.DateOfTest
		,[Fluid_System]		= xL.Fluid_System
		,[Developmental]	= xL.Developmental
      
		FROM [SSIS_ENG].[fnRPT_xmlLAB_Info]() xL
			
		WHERE xL.ID_LabInfo IS NULL
			AND xL.ID_Pad IS NOT NULL AND xL.PadName IS NOT NULL
	;

END 


GO

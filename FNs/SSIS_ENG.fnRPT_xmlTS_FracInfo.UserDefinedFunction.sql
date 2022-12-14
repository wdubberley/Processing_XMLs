USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnRPT_xmlTS_FracInfo]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************ 
  Created:	KPHAM (20190114)
  20210506(v006)- Adjusted Formation if NULL
  20210708(v007)- Added Reservation_Land
  20210915(v008)- Corrected BHST
  20210922(v009)- Adjusted ID_District to pull from Basin correllated ID_District 
  20210927(v010)- Reverting code back to get District from LOS_District
  20211110(v011)- Added Energized_Fluid
************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnRPT_xmlTS_FracInfo]()
RETURNS TABLE
AS
RETURN

	WITH rComp AS (SELECT ItemName, ID_Record FROM dbo.ref_Categories WHERE ID_Parent=1)
		,wType AS (SELECT ItemName, ID_Record FROM dbo.ref_Categories WHERE ID_Parent=9)

	SELECT ID_FracInfo	= eI.ID_FracInfo
		, ID_Pad		= wCTE.ID_Pad
		, ID_Well		= wCTE.ID_Well
		, ID_District	= wCTE.ID_District							/* 20210927 */
							--CASE WHEN rB.ID_LOSDistrict <> wCTE.ID_District THEN rB.ID_LOSDistrict
							--ELSE ISNULL(rB.ID_LOSDistrict, wCTE.ID_District) END --wCTE.ID_District
		, TicketNo		= xI.LOS_Project_Number
		, TaskNo		= xI.LOS_Project_Number						/* 20210506 */
		, Formation		= ISNULL(xI.Formation,'')
		, Well_BHST		= xI.BHST									/* 20210915 */
						/*** CASE WHEN ISNUMERIC(xI.BHST)=1 THEN xI.BHST 
							WHEN xI.BHST LIKE '%F%' THEN REPLACE(xI.BHST, 'F','') 
							WHEN xI.BHST LIKE '%UNK%' THEN NULL 
							ELSE NULL END	--****/
		, Well_MaxPressure	= xI.Max_Pressure
		, ID_CompletionType	= CASE WHEN rComp.ID_Record IS NULL THEN 0 ELSE rComp.ID_Record END
		, ID_WellType		= CASE WHEN wType.ID_Record IS NULL THEN 0 ELSE wType.ID_Record END
		, TotalIntervals	= xI.Number_of_Intervals
		, MainFluidTypes	= ISNULL(xI.Main_Fluid_Type,'')
		, MainProppantTypes	= ISNULL(xI.Main_Proppant_Type,'')
		, DateCompletion	= CASE WHEN ISDATE(xI.Completion_Date) = 1 THEN xI.Completion_Date ELSE NULL END
		, PadName			= wCTE.PadName
		, WellName			= xI.Well_Name

		, LOS_Sales_Contact	= xI.LOS_Sales_Contact
		, LOS_Ops_Contact	= xI.LOS_Operations_Contact
		, Cust_Contact		= xI.Customer_Contact

		, Pad_Name		= xI.Pad_Name
		, alt_ID_Pad	= wCTE.ID_Pad 

		, xmlFileName	= xI.xmlFileName			
		, xmlFileDate	= xI.xmlFileDate
		, xmlMacroVersion	= xI.MacroVersion
		, Customer_Address	= xI.Customer_Address
		, LOS_Address		= xI.LOS_Address

		, Reservation_Land	= ISNULL(xI.Reservation_Land,'')				/* 20210708 */
		, Energized_Fluid	= ISNULL(xI.Energized_Fluid,'')					/* 20211110 */
		
		, bID_District	= rB.ID_LOSDistrict
		, wID_District	= wCTE.ID_District
		
		--, xI.*
		
		FROM [SSIS_ENG].xmlImport_TS_FracInfo xI
			INNER JOIN [SSIS_ENG].fnTMP_WellInfo() wCTE ON wCTE.PadName = xI.Pad_Name AND wCTE.WellName = xI.Well_Name
			LEFT JOIN rComp ON rComp.ItemName = xI.Completion_Type
			LEFT JOIN wType ON wType.ItemName = xI.Well_Type

			LEFT JOIN dbo.FracInfo eI ON eI.ID_Pad = wCTE.ID_Pad AND eI.ID_Well = wCTE.ID_Well 
										AND eI.LOS_ProjectNo = xI.LOS_Project_Number 

			LEFT JOIN dbo.LOS_Basins	rB ON rB.Basin = xI.Basin

GO

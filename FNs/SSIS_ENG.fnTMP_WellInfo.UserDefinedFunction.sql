USE [FieldData]
GO
/****** Object:  UserDefinedFunction [SSIS_ENG].[fnTMP_WellInfo]    Script Date: 8/24/2022 11:05:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************************************************************
  Created:	KPHAM (20190114)
  Desc:		This FN returns a table with pad/well data for all wells in pads that are not completed or completed within the last 21 days;
			For pads/wells that are completed prior to that, go to dbo.LOS_Pads and set IsCurrent to 1 for the corresponding ID_Pad
  Modified:	20180214- Set maxPadDate to 30 days
			20181206- Set maxPadDate to 21 days
			20190114- Removed 2016 section until further notice
			20190220- Removed code on line 42 [ AND YEAR(lP.minDate) BETWEEN YEAR(GETDATE())-1 AND YEAR(GETDATE()) ]; no need this one year backward filter
************************************************************************************************************************************/
CREATE FUNCTION [SSIS_ENG].[fnTMP_WellInfo]()
RETURNS --TABLE
	@tTBL_WellInfo TABLE 
		(ID_Operator	INT
		, ID_Pad		INT
		, ID_Well		INT
		, ID_District	INT
		, WellName		VARCHAR(255)
		, OperatorName	VARCHAR(255)
		, PadName		VARCHAR(255))
AS
BEGIN

	/**************************
	declare @tTBL_WellInfo TABLE (ID_Operator	INT, ID_Pad	INT, ID_Well INT, ID_District INT
							, WellName VARCHAR(255), OperatorName VARCHAR(255), PadName VARCHAR(255))
	--*************************/
	
	INSERT INTO @tTBL_WellInfo

	SELECT DISTINCT lP.ID_Operator, eT.ID_Pad, eT.ID_Well, lW.ID_District, lW.WellName, lP.ShortName, PadName = lP.Field_PadName
		--, year(minDate), year(getdate())-1, year(getdate())
		--, lP.isPadComplete
		FROM dbo.FracTime eT
			INNER JOIN dbo.LOS_Wells lW						ON lW.ID_Well	= eT.ID_Well
			INNER JOIN Engineering.vw_Pad_TimeSummary lP	ON lP.ID_Pad	= eT.ID_Pad
		WHERE 1=1
			--AND YEAR(lP.minDate) BETWEEN YEAR(GETDATE())-1 AND YEAR(GETDATE())				/* 20190220 */
			AND (lP.isPadComplete = 0 
				OR (lP.isPadComplete = 1 AND DATEDIFF(DD,lP.maxDate,GETDATE())<= 93)			/* 20181206 */
				)																				/* 20181214 */
	/* specific to rerun 2016s */																/* 20190114 */
	/******************************************************************* 
	UNION
	SELECT lP.ID_Operator, lP.ID_Pad, lW.ID_Well, lW.ID_District, lW.WellName, lP.ShortName, PadName = lP.Field_PadName
		FROM dbo.FracInfo eI 
			INNER JOIN Engineering.vw_Pad_TimeSummary	lP ON lP.ID_Pad	= eI.ID_Pad
			INNER JOIN dbo.LOS_Wells					lW ON lW.ID_Well = eI.ID_Well
		WHERE lP.isPadComplete = 0 AND (YEAR(lP.maxDate) = 2016 OR YEAR(lP.minDate) = 2016)
	--*****************************************************************/
				
	--select * from @tTBL_WellInfo where id_pad = 4464
		
	RETURN

END


GO

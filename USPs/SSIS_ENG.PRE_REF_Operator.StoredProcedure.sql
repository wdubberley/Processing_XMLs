USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Operator]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*============================================================
	Created:	KPHAM
	Modified:	
==============================================================*/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Operator]	
AS
BEGIN

	DECLARE @rValue	AS INT;

	WITH oCTE (OperatorName, ShortName) AS 
		(
		SELECT DISTINCT tI.Customer_Name, tI.Customer_Name
			FROM [SSIS_ENG].xmlImport_TS_FracInfo tI
		UNION
		SELECT DISTINCT timeLogs.Customer, timeLogs.Customer
			FROM [SSIS_ENG].xmlImport_TT_TimeLogs timeLogs
		)

	INSERT INTO dbo.Ref_Operators (OperatorName, ShortName)
	SELECT OperatorName	= oCTE.OperatorName
		, ShortName		= oCTE.ShortName 
		FROM oCTE
			LEFT JOIN [SSIS_ENG].mapping_Customer_Operator rO ON (rO.Customer = oCTE.OperatorName)
		WHERE rO.ID_Operator IS NULL
			AND oCTE.OperatorName IS NOT NULL

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = ISNULL(@@ROWCOUNT,0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Operators', 'Insert', @rValue

END 


GO

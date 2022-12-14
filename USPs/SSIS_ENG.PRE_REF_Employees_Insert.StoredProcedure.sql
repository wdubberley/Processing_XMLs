USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Employees_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/******
 Created:	KPHAM (20190104)
 Desc:		Insert the rest of new records when unused records are used up; Use [SSIS_ENG].fnRPT_xmlLOS_Employees()
 Modified:	20190115- Changed mapping for insert to find existing in SSIS_ENG.mapping_Employees table first.
******/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Employees_Insert]	
AS
BEGIN

	DECLARE @rValue AS INT;

	INSERT INTO [dbo].[LOS_Employees] (FirstName, LastName, IsActive) 
	SELECT FirstName	= eCTE.FirstName
		, LastName		= eCTE.LastName
		, IsActive		= 1

		FROM [SSIS_ENG].[fnRPT_xmlLOS_Employees]() eCTE
			--LEFT JOIN [dbo].[LOS_Employees] rE ON eCTE.FirstName = rE.FirstName AND eCTE.LastName = rE.LastName
			LEFT JOIN [SSIS_ENG].[mapping_Employees] rE ON rE.EmployeeName = eCTE.FirstName + ' ' + eCTE.LastName
		WHERE rE.ID_Employee IS NULL

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = ISNULL(@@ROWCOUNT,0)
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Employees', 'Insert', @rValue

END 



GO

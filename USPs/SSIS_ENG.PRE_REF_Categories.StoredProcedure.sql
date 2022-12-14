USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Categories]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Categories]	
AS
BEGIN

	DECLARE @rValue AS INT = 0
	
	/***** Category: Completion Well Type (20180130) *****/
	INSERT INTO dbo.ref_Categories(ID_Parent, ItemName, ItemDesc)
	SELECT DISTINCT ID_Parent=9, ItemName=LTRIM(RTRIM(xT.[Type])),ItemDesc=LTRIM(RTRIM(xT.[Type]))
		FROM [SSIS_ENG].xmlImport_TT_TimeLogs xT
			LEFT JOIN dbo.ref_Categories rC ON xT.[Type] = rC.ItemName AND rC.ID_Parent=9
		WHERE rC.ID_Record IS NULL AND LTRIM(RTRIM(xT.[Type])) IS NOT NULL

	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Categories', 'Insert-WellType', @rValue;

	/***** Category: Completion Frac Type (20180215) *****/
	UPDATE [SSIS_ENG].xmlImport_TS_FracStages SET CompletionType=LTRIM(RTRIM(CompletionType)) WHERE CompletionType IS NOT NULL
	INSERT INTO dbo.ref_Categories(ID_Parent, ItemName, ItemDesc)
	SELECT DISTINCT ID_Parent=1, ItemName=xS.[CompletionType],ItemDesc=xS.[CompletionType]
		FROM [SSIS_ENG].xmlImport_TS_FracStages xS
			LEFT JOIN dbo.ref_Categories rC ON xS.[CompletionType] = rC.ItemName AND rC.ID_Parent=1
		WHERE rC.ID_Record IS NULL AND xS.[CompletionType] IS NOT NULL
	/*===== RECORD INSERT HISTORY =====*/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Categories', 'Insert-CompletionType', @rValue;

	/***** Category: Charge Options (20180125)*****/
	;WITH cte_Values As
		(SELECT DISTINCT ChargeOption = ISNULL(LTRIM(RTRIM(xT.IsPassthrough)),'') FROM [SSIS_ENG].xmlImport_TS_FracTickets xT
		UNION 
		SELECT DISTINCT ChargeOption = ISNULL(LTRIM(RTRIM(xQ.IsPassthrough)),'') FROM [SSIS_ENG].xmlImport_TS_FracQuotes xQ 
		)
	INSERT INTO dbo.ref_Categories(ID_Parent, ItemName, ItemDesc)
	SELECT ID_Parent = 65
		, ItemName	= ChargeOption
		, ItemDesc = ChargeOption
		FROM cte_Values xT
			LEFT JOIN dbo.ref_Categories rC ON xT.ChargeOption = rC.ItemName AND rC.ID_Parent=65
		WHERE rC.ID_Record IS NULL AND xT.ChargeOption IS NOT NULL
	
	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.ref_Categories', 'Insert-ChargeOption', @rValue;
	
END 


GO

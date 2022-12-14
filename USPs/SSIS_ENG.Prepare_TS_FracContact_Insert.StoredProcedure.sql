USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[Prepare_TS_FracContact_Insert]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [SSIS_ENG].[Prepare_TS_FracContact_Insert]	
AS
BEGIN
	
	DECLARE @rValue AS INT;

	WITH cCTE AS
		(SELECT ID_FracInfo
			--, ID_Personnel
			, ID_Personnel		= CASE WHEN xC.ID_ContactType IN (19,20) AND mE.ID_Employee IS NOT NULL THEN mE.ID_Employee 
										WHEN xC.ID_ContactType IN (21) AND rR.ID_Record IS NOT NULL THEN rR.ID_Record
									ELSE 0 END
			, ID_ContactType
			, IsLOS				= CASE WHEN xC.ID_ContactType IN (19,20) THEN 1 ELSE 0 END
			--, Contact
			FROM [SSIS_ENG].fnRPT_xmlTS_FracInfo_Contacts() xC
				--LEFT JOIN dbo.LOS_Employees rE ON rE.FirstName + ' ' + rE.LastName = xC.Contact
				LEFT JOIN [SSIS_ENG].mapping_Employees mE ON mE.EmployeeName = xC.Contact
				LEFT JOIN dbo.ref_Representatives rR ON rR.FirstName + ' ' + rR.LastName = xC.Contact
			WHERE xC.ID_FracInfo IS NOT NULL 
		)

		INSERT INTO dbo.FracContacts
			(ID_FracInfo, ID_Personnel, ID_ContactType, IsLOS)

		SELECT cCTE.ID_FracInfo
			, cCTE.ID_Personnel
			, cCTE.ID_ContactType
			, cCTE.IsLOS
			FROM cCTE
				LEFT JOIN dbo.FracContacts eC 
					ON eC.ID_FracInfo = cCTE.ID_FracInfo 
						AND eC.ID_ContactType=cCTE.ID_ContactType 
						AND cCTE.ID_Personnel = eC.ID_Personnel
			WHERE eC.ID_Contact IS NULL AND cCTE.ID_Personnel <> 0
	;

	/***** RECORD INSERT HISTORY *****/
	SELECT @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.FracContacts', 'Insert', @rValue;


END 

GO

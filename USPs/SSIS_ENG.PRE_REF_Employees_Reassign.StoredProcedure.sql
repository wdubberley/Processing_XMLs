USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Employees_Reassign]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******
 Created:	KPHAM (20190104)
 Desc:		Update extra rows from available/unused/no-refs records; Use [SSIS_ENG].[fnRPT_xmlLOS_Employees]() and [SSIS_ENG].[fnQC_Employees]()
******/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Employees_Reassign]	
AS
BEGIN

	DECLARE @rValue AS INT;

	WITH new_xEmp AS	/* new Employees from XMLs */
		(SELECT xID			= ROW_NUMBER() OVER(ORDER BY xE.LastName) 
			, xFirstname	= xE.FirstName
			, xLastName		= xE.LastName

			--, *
			FROM [SSIS_ENG].[fnRPT_xmlLOS_Employees] () xE
				LEFT JOIN [SSIS_ENG].[mapping_Employees] mE 
					ON mE.EmployeeName = CASE WHEN xE.FirstName='' THEN xE.LastName ELSE xE.FirstName END  
										+ ' ' + CASE WHEN xE.LastName='' THEN xE.FirstName ELSE xE.LastName END
			WHERE mE.ID_Employee is null
		)
		, cte_eMap AS	/* list of mapping IDs */
		(SELECT DISTINCT ID_Employee
			, cIDs_Emp = count(*)

			FROM [SSIS_ENG].mapping_Employees 
			GROUP BY ID_Employee
		)
		, cte_eAvail AS	/* list of records of unused/no-refs records */
		(SELECT aID			= ROW_NUMBER() OVER(ORDER BY eQC.ID_Employee)
			, aFirstName	= eQC.FirstName
			, aLastName		= eQC.LastName
			, aID_Employee	= eQC.ID_Employee
			
			FROM cte_eMap eM
				FULL JOIN [SSIS_ENG].[fnQC_Employees] () eQC ON eQC.ID_Employee = eM.ID_Employee
			WHERE eM.ID_Employee IS NULL 
				AND eQC.c_REFs = 0 AND eQC.IsActive IN (0) AND eQC.IsLocked = 0
		)

	UPDATE rE
		SET rE.FirstName	= x.xFirstName
			, rE.LastName	= x.xLastName
			, rE.PhoneNumber=''
			, rE.IsActive	= 1
			, rE.EmailAddress=''
			, rE.DateCreated	= GETDATE()

			, rE.prev_EmployeeName = rE.FirstName + ' ' + rE.LastName

	--select * 
		
		FROM new_xEmp x
			INNER JOIN cte_eAvail a ON a.aID = x.xID
			INNER JOIN [dbo].[LOS_Employees] rE ON rE.ID_Employee = a.aID_Employee

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Employees', 'Reassign', @rValue

END 




GO

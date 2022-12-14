USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Fluids_Reassign]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/******
 Created:	KPHAM (20190204)
 Desc:		Update extra rows from available/unused/no-refs records; Use [SSIS_ENG].[xmlImport_TS_FracFluids] and [SSIS_ENG].[fnQC_LOS_Fluids]()
******/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Fluids_Reassign]	
AS
BEGIN

	DECLARE @rValue AS INT;

	WITH new_xFluid AS	/* new Employees from XMLs */
		(SELECT xID		= ROW_NUMBER() OVER(ORDER BY xF.FluidName) 
			, xFluidName= xF.FluidName
			FROM (SELECT DISTINCT FluidName FROM [SSIS_ENG].xmlImport_TS_FracFluids WHERE FluidName IS NOT NULL) xF 
				LEFT JOIN [SSIS_ENG].[mapping_Fluids] mF ON mF.Fluid = xF.FluidName
			WHERE mF.ID_Fluid IS NULL
		)
		, cte_eMap AS	/* list of mapping IDs */
		(SELECT DISTINCT ID_Fluid
			, cIDs_Fluid = count(*)

			FROM [SSIS_ENG].mapping_Fluids
			GROUP BY ID_Fluid
		)
		, cte_eAvail AS	/* list of records of unused/no-refs records */
		(SELECT aID			= ROW_NUMBER() OVER(ORDER BY eQC.ID_Fluid)
			, aFluidName	= eQC.FluidName
			, aID_Fluid		= eQC.ID_Fluid
			
			FROM cte_eMap eM
				FULL JOIN [SSIS_ENG].[fnQC_LOS_Fluids] ('') eQC ON eQC.ID_Fluid = eM.ID_Fluid
			WHERE eM.ID_Fluid IS NULL 
				AND eQC.c_REFs = 0 AND eQC.IsLocked = 0 
		)
		
		
	UPDATE rF
		SET rF.FluidName	= x.xFluidName
			--, rE.IsDeleted	= 1
			--, rE.EmailAddress=''
			, rF.DateCreated	= GETDATE()

			, rF.Archived_FluidName = rF.FluidName
	
		--select * 
		FROM new_xFluid x
			INNER JOIN cte_eAvail			a ON a.aID = x.xID
			INNER JOIN [dbo].[LOS_Fluids]	rF ON rF.ID_Fluid = a.aID_Fluid

	/***** RECORD INSERT HISTORY *****/
	SET @rValue = @@ROWCOUNT
	IF @rValue > 0 
		EXEC [SSIS_ENG].[uspREF_History_Insert] 'dbo.LOS_Fluids', 'Reassign', @rValue

END 

GO

USE [FieldData]
GO
/****** Object:  StoredProcedure [SSIS_ENG].[PRE_REF_Employees]    Script Date: 8/24/2022 10:55:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
 Created:	KPHAM (2018)
 Desc:		(1) Update extra rows from available/unused/no-refs records; (2) Insert the rest of new records when unused records are used up
 Modified:	20190104- Modified USP to update unused records BEFORE insert new records for mapping.
******/
CREATE PROCEDURE [SSIS_ENG].[PRE_REF_Employees]	
AS
BEGIN
	
	EXEC [SSIS_ENG].[PRE_REF_Employees_Reassign]
	EXEC [SSIS_ENG].[PRE_REF_Employees_Insert]

END 

GO

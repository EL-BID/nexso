
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [MIFNEXSO2015].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [MIFNEXSO2015] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET ARITHABORT OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [MIFNEXSO2015] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [MIFNEXSO2015] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [MIFNEXSO2015] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET  DISABLE_BROKER 
GO
ALTER DATABASE [MIFNEXSO2015] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [MIFNEXSO2015] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [MIFNEXSO2015] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [MIFNEXSO2015] SET  MULTI_USER 
GO
ALTER DATABASE [MIFNEXSO2015] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [MIFNEXSO2015] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'MIFNEXSO2015', N'ON'
GO
/****** Object:  User [nexso]    Script Date: 4/17/2015 10:19:30 AM ******/
CREATE USER [nexso] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [mif_user]    Script Date: 4/17/2015 10:19:30 AM ******/
CREATE USER [mif_user] FOR LOGIN [mif_user] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [mif_admin]    Script Date: 4/17/2015 10:19:30 AM ******/
CREATE USER [mif_admin] FOR LOGIN [mif_admin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [nexso]
GO
ALTER ROLE [db_datareader] ADD MEMBER [mif_user]
GO
ALTER ROLE [db_owner] ADD MEMBER [mif_admin]
GO
/****** Object:  FullTextCatalog [SolutionCatalog]    Script Date: 4/17/2015 10:19:30 AM ******/
CREATE FULLTEXT CATALOG [SolutionCatalog]WITH ACCENT_SENSITIVITY = OFF

GO
/****** Object:  StoredProcedure [dbo].[spGetSolutionsOrganizations]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizations]
(
	@RowsPerPage		INT,
	@PageNumber			INT,
	@MinScore			INT, 
	@MaxScore			INT,
	@State				INT,
	@Search				varchar(500),
	@Categories			varchar(500),
	@Beneficiaries		varchar(500),
	@DeliveryFormat		varchar(500),
	@UserId				INT,
	@ChallengeReference	varchar(50),
	@SolutionType	    varchar(50),
	@Language	    varchar(50),
	@Joly				varchar(500),
	@Count int output
)
AS
	BEGIN
		DECLARE @filterLenght as int
		DECLARE @searchString as varchar(500)
		SET		@filterLenght=0
		SELECT	@Beneficiaries=REPLACE(@Beneficiaries,'''','')
		SELECT	@Categories=REPLACE(@Categories,'''','')
		SELECT	@DeliveryFormat=REPLACE(@DeliveryFormat,'''','')
		
		
		
		IF (LEN(@Beneficiaries)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Beneficiaries, ',')
		END

		IF (LEN(@Categories)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Categories, ',')
		END

		IF (LEN(@DeliveryFormat)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@DeliveryFormat, ',')
		END



		IF (LEN(@Search)>0  )
		BEGIN
			SET @searchString=@Search
	    END
		ELSE
		BEGIN
			SET @searchString='*'
		END
		
		declare @tmpTable table(
		RowNum bigint not null,
		[SSolutionId] [uniqueidentifier] NOT NULL,
		[SSolutionTypeId] [int] NULL,
		[STitle] [varchar](200) NULL,
		[STagLine] [varchar](500) NULL,
		[SDescription] [varchar](1500) NULL,
		[SBiography] [varchar](1000) NULL,
		[SChallenge] [varchar](1000) NULL,
		[SApproach] [varchar](1000) NULL,
		[SResults] [varchar](1000) NULL,
		[SImplementationDetails] [varchar](1000) NULL,
		[SAdditionalCost] [varchar](500) NULL,
		[SAvailableResources] [varchar](500) NULL,
		[STimeFrame] [varchar](500) NULL,
		[SDuration] [int] NULL,
		[SDurationDetails] [varchar](500) NULL,
		[SSolutionStatusId] [int] NULL,
		[SSolutionType] [varchar](50) NULL,
		[STopic] [int] NULL,
		[SLanguage] [varchar](5) NULL,
		[SCreatedUserId] [int] NULL,
		[SDeleted] [bit] NULL,
		[SCountry] [nchar](50) NULL,
		[SRegion] [nchar](50) NULL,
		[SCity] [nchar](50) NULL,
		[SAddress] [varchar](200) NULL,
		[SZipCode] [varchar](50) NULL,
		[SLogo] [varchar](200) NULL,
		[SCost1] [decimal](16, 2) NULL,
		[SCost2] [decimal](16, 2) NULL,
		[SCost3] [decimal](16, 2) NULL,
		[SDeliveryFormat] [int] NULL,
		[SCost] [decimal](16, 2) NULL,
		[SCostType] [int] NULL,
		[SCostDetails] [varchar](500) NULL,
		[SSolutionState] [int] NULL,
		[SBeneficiaries] [int] NULL,
		[SDateCreated] [datetime] NULL,
		[SDateUpdated] [datetime] NULL,
		[SChallengeReference] [varchar](50) NULL,
		[SVideoObject] [varchar] (500) NULL,
		[OOrganizationID] [uniqueidentifier] NOT NULL,
		[OCode] [varchar](100) NULL,
		[OName] [varchar](100) NULL,
		[OAddress] [varchar](200) NULL,
		[OPhone] [varchar](100) NULL,
		[OEmail] [varchar](100) NULL,
		[OContactEmail] [varchar](100) NULL,
		[OWebsite] [varchar](100) NULL,
		[OTwitter] [varchar](100) NULL,
		[OSkype] [varchar](100) NULL,
		[OFacebook] [varchar](100) NULL,
		[OGooglePlus] [varchar](100) NULL,
		[OLinkedIn] [varchar](100) NULL,
		[ODescription] [varchar](800) NULL,
		[OLogo] [varchar](200) NULL,
		[OCountry] [varchar](50) NULL,
		[ORegion] [varchar](50) NULL,
		[OCity] [varchar](50) NULL,
		[OZipCode] [varchar](50) NULL,
		[OCreated] [datetime] NULL,
		[OUpdated] [datetime] NULL,
		[OLatitude] [decimal](10, 7) NULL,
		[OLongitude] [decimal](10, 7) NULL,
		[OGoogleLocation] [varchar](1000) NULL,
	    Score integer not null
		
		);
		
		
		INSERT into @tmpTable 
		
		SELECT  
							ROW_NUMBER() OVER (ORDER BY dbo.GetScore(SLN.SolutionId,'JUDGE') desc) AS RowNum,
							SLN.SolutionId AS SSolutionId, 
							SLN.SolutionTypeId AS SSolutionTypeId, 
							SLN.Title AS STitle, 
							SLN.TagLine AS STagLine,  
							SLN.Description AS SDescription, 
							SLN.Biography AS SBiography, 
							SLN.Challenge AS SChallenge, 
							SLN.Approach AS SApproach,  
							SLN.Results AS SResults, 
							SLN.ImplementationDetails AS SImplementationDetails, 
							SLN.AdditionalCost AS SAdditionalCost,  
							SLN.AvailableResources AS SAvailableResources, 
							SLN.TimeFrame AS STimeFrame, 
							SLN.Duration AS SDuration,  
							SLN.DurationDetails AS SDurationDetails, 
							SLN.SolutionStatusId AS SSolutionStatusId, 
							SLN.SolutionType AS SSolutionType,  
							SLN.Topic AS STopic, 
							SLN.Language AS SLanguage, 
							SLN.CreatedUserId AS SCreatedUserId, 
							SLN.Deleted AS SDeleted,  
							SLN.Country AS SCountry, 
							SLN.Region AS SRegion, 
							SLN.City AS SCity, 
							SLN.Address AS SAddress,  
							SLN.ZipCode AS SZipCode, 
							SLN.Logo AS SLogo, 
							SLN.Cost1 AS SCost1, 
							SLN.Cost2 AS SCost2, 
							SLN.Cost3 AS SCost3,  
							SLN.DeliveryFormat AS SDeliveryFormat, 
							SLN.Cost AS SCost, 
							SLN.CostType AS SCostType, 
							SLN.CostDetails AS SCostDetails,  
							SLN.SolutionState AS SSolutionState, 
							SLN.Beneficiaries AS SBeneficiaries, 
							SLN.DateCreated AS SDateCreated,  
							SLN.DateUpdated AS SDateUpdated, 
							SLN.ChallengeReference AS SChallengeReference, 
							SLN.VideoObject AS SVideoObject,
							ORG.OrganizationID AS OOrganizationID,  
							ORG.Code AS OCode, 
							ORG.Name AS OName, 
							ORG.Address AS OAddress, 
							ORG.Phone AS OPhone,  
							ORG.Email AS OEmail, 
							ORG.ContactEmail AS OContactEmail, 
							ORG.Website AS OWebsite, 
							ORG.Twitter AS OTwitter,  
							ORG.Skype AS OSkype, 
							ORG.Facebook AS OFacebook, 
							ORG.GooglePlus AS OGooglePlus,  
							ORG.LinkedIN AS OLinkedIn, 
							ORG.Description AS ODescription, 
							ORG.Logo AS OLogo, 
							ORG.Country AS OCountry,  
							ORG.Region AS ORegion, 
							ORG.ZipCode AS OZipCode, 
							ORG.City AS OCity,
							ORG.Created AS OCreated,  
							ORG.Updated AS OUpdated, 
							ORG.Latitude AS OLatitude, 
							ORG.Longitude AS OLongitude,  
							ORG.GoogleLocation AS OGoogleLocation,
							dbo.GetScore(SLN.SolutionId,'JUDGE') AS Score
					FROM	dbo.Solution AS SLN
							INNER JOIN dbo.Organization AS ORG ON SLN.OrganizationId = ORG.OrganizationID 
					WHERE	(@ChallengeReference='%' OR @ChallengeReference='' OR @ChallengeReference IS NULL OR SLN.ChallengeReference LIKE @ChallengeReference)
					and (@SolutionType='%' OR @SolutionType='' OR @SolutionType IS NULL OR SLN.SolutionType LIKE @SolutionType)
					and (@Language='%' OR @Language='' OR @Language IS NULL OR SLN.Language LIKE @Language)
							AND (@MinScore='' OR @MinScore IS NULL OR dbo.GetScore(SLN.SolutionId,'JUDGE')>= @MinScore) 
							AND (@State IS NULL OR SLN.SolutionState >= @State )
							AND (@UserId=-1 OR CreatedUserId=@UserId) 
							AND (((@Categories = '' AND @Beneficiaries = '' AND @DeliveryFormat = '')OR(@Categories IS NULL AND @Beneficiaries IS NULL AND @DeliveryFormat IS NULL) ) OR SLN.SolutionId IN (
							
							SELECT	solutionid AS SolutionIdList 
														
	FROM	SolutionLists
	WHERE	((Category='Beneficiaries' AND [KEY] IN (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) 
or (Category='Theme' AND [KEY] IN (SELECT Data FROM dbo.Split(@Categories, ',')))
or (Category='DeliveryFormat' AND [KEY] IN (SELECT Data FROM dbo.Split(@DeliveryFormat, ','))))  
														
					
	
									
														group by solutionid
														having COUNT(solutionid)=@filterLenght
														
														))
					        AND (@searchString='*' or freetext((Title, TagLine),@searchString))
order by score	desc	
		select @Count=COUNT(*)
		from @tmpTable

		SELECT	* 
		FROM	@tmpTable AS SOD
		WHERE	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		order by score	desc	
	END

GO
/****** Object:  StoredProcedure [dbo].[spGetSolutionsOrganizationsOld]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizationsOld]
		@RowsPerPage INT,
		@PageNumber INT ,
		@MinScore INT, 
		@MaxScore INT
		,@State INT,
		@Search varchar(500),
		@Categories varchar(500),
		@Beneficiaries varchar(500),
		@UserId as int,
		@ChallengeReference as varchar(50),
		@Joly as varchar(500)
AS
BEGIN
declare @lock as int
set @lock=1
SELECT @Beneficiaries=REPLACE(@Beneficiaries,'''','')
SELECT @Categories=REPLACE(@Categories,'''','')
if LEN(@Beneficiaries)>0 or LEN(@Categories)>0
set @lock=0


if(@UserId=-1)
Begin
SELECT * FROM (
SELECT  
ROW_NUMBER() OVER (ORDER BY dbo.GetScore(Solution.SolutionId,'JUDGE') desc) AS RowNum,
dbo.Solution.SolutionId AS SSolutionId, dbo.Solution.SolutionTypeId AS SSolutionTypeId, 
dbo.Solution.Title AS STitle, dbo.Solution.TagLine AS STagLine,  
dbo.Solution.Description AS SDescription, dbo.Solution.Biography AS SBiography, dbo.Solution.Challenge AS SChallenge, dbo.Solution.Approach AS SApproach,  
dbo.Solution.Results AS SResults, dbo.Solution.ImplementationDetails AS SImplementationDetails, dbo.Solution.AdditionalCost AS SAdditionalCost,  
dbo.Solution.AvailableResources AS SAvailableResources, dbo.Solution.TimeFrame AS STimeFrame, dbo.Solution.Duration AS SDuration,  
dbo.Solution.DurationDetails AS SDurationDetails, dbo.Solution.SolutionStatusId AS SSolutionStatusId, dbo.Solution.SolutionType AS SSolutionType,  
dbo.Solution.Topic AS STopic, dbo.Solution.Language AS SLanguage, dbo.Solution.CreatedUserId AS SCreatedUserId, dbo.Solution.Deleted AS SDeleted,  
dbo.Solution.Country AS SCountry, dbo.Solution.Region AS SRegion, dbo.Solution.City AS SCity, dbo.Solution.Address AS SAddress,  
dbo.Solution.ZipCode AS SZipCode, dbo.Solution.Logo AS SLogo, dbo.Solution.Cost1 AS SCost1, dbo.Solution.Cost2 AS SCost2, dbo.Solution.Cost3 AS SCost3,  
dbo.Solution.DeliveryFormat AS SDeliveryFormat, dbo.Solution.Cost AS SCost, dbo.Solution.CostType AS SCostType, dbo.Solution.CostDetails AS SCostDetails,  
dbo.Solution.SolutionState AS SSolutionState, dbo.Solution.Beneficiaries AS SBeneficiaries, dbo.Solution.DateCreated AS SDateCreated,  
dbo.Solution.DateUpdated AS SDateUpdated, dbo.Solution.ChallengeReference AS SChallengeReference, dbo.Organization.OrganizationID AS OOrganizationID,  
dbo.Organization.Code AS OCode, dbo.Organization.Name AS OName, dbo.Organization.Address AS OAddress, dbo.Organization.Phone AS OPhone,  
dbo.Organization.Email AS OEmail, dbo.Organization.ContactEmail AS OContactEmail, dbo.Organization.Website AS OWebsite, dbo.Organization.Twitter AS OTwitter,  
dbo.Organization.Skype AS OSkype, dbo.Organization.Facebook AS OFacebook, dbo.Organization.GooglePlus AS OGooglePlus,  
dbo.Organization.LinkedIn AS OLinkedIn, dbo.Organization.Description AS ODescription, dbo.Organization.Logo AS OLogo, dbo.Organization.Country AS OCountry,  
dbo.Organization.Region AS ORegion, dbo.Organization.ZipCode AS OZipCode, dbo.Organization.City AS OCity, dbo.Organization.Created AS OCreated,  
dbo.Organization.Updated AS OUpdated, dbo.Organization.Latitude AS OLatitude, dbo.Organization.Longitude AS OLongitude,  
dbo.Organization.GoogleLocation AS OGoogleLocation ,dbo.GetScore(Solution.SolutionId,'JUDGE') as Score
FROM
dbo.Solution INNER JOIN dbo.Organization ON dbo.Solution.OrganizationId = dbo.Organization.OrganizationID 
WHERE  
Solution.ChallengeReference like @ChallengeReference and dbo.GetScore(Solution.SolutionId,'JUDGE')>= @MinScore and Solution.SolutionState>=@State             
and Solution.SolutionId in 
(select DISTINCT solutionid as SolutionIdList from 
SolutionLists

where (Category='Beneficiaries' and [KEY] in (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) or
(Category='Theme' and [KEY] in (SELECT Data FROM dbo.Split(@Categories, ',')))or 1=@lock)


)AS SOD
WHERE SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
AND @RowsPerPage*(@PageNumber)
end
else

SELECT * FROM (
SELECT  
ROW_NUMBER() OVER (ORDER BY dbo.GetScore(Solution.SolutionId,'JUDGE') desc) AS RowNum,
dbo.Solution.SolutionId AS SSolutionId, dbo.Solution.SolutionTypeId AS SSolutionTypeId, 
dbo.Solution.Title AS STitle, dbo.Solution.TagLine AS STagLine,  
dbo.Solution.Description AS SDescription, dbo.Solution.Biography AS SBiography, dbo.Solution.Challenge AS SChallenge, dbo.Solution.Approach AS SApproach,  
dbo.Solution.Results AS SResults, dbo.Solution.ImplementationDetails AS SImplementationDetails, dbo.Solution.AdditionalCost AS SAdditionalCost,  
dbo.Solution.AvailableResources AS SAvailableResources, dbo.Solution.TimeFrame AS STimeFrame, dbo.Solution.Duration AS SDuration,  
dbo.Solution.DurationDetails AS SDurationDetails, dbo.Solution.SolutionStatusId AS SSolutionStatusId, dbo.Solution.SolutionType AS SSolutionType,  
dbo.Solution.Topic AS STopic, dbo.Solution.Language AS SLanguage, dbo.Solution.CreatedUserId AS SCreatedUserId, dbo.Solution.Deleted AS SDeleted,  
dbo.Solution.Country AS SCountry, dbo.Solution.Region AS SRegion, dbo.Solution.City AS SCity, dbo.Solution.Address AS SAddress,  
dbo.Solution.ZipCode AS SZipCode, dbo.Solution.Logo AS SLogo, dbo.Solution.Cost1 AS SCost1, dbo.Solution.Cost2 AS SCost2, dbo.Solution.Cost3 AS SCost3,  
dbo.Solution.DeliveryFormat AS SDeliveryFormat, dbo.Solution.Cost AS SCost, dbo.Solution.CostType AS SCostType, dbo.Solution.CostDetails AS SCostDetails,  
dbo.Solution.SolutionState AS SSolutionState, dbo.Solution.Beneficiaries AS SBeneficiaries, dbo.Solution.DateCreated AS SDateCreated,  
dbo.Solution.DateUpdated AS SDateUpdated, dbo.Solution.ChallengeReference AS SChallengeReference, dbo.Organization.OrganizationID AS OOrganizationID,  
dbo.Organization.Code AS OCode, dbo.Organization.Name AS OName, dbo.Organization.Address AS OAddress, dbo.Organization.Phone AS OPhone,  
dbo.Organization.Email AS OEmail, dbo.Organization.ContactEmail AS OContactEmail, dbo.Organization.Website AS OWebsite, dbo.Organization.Twitter AS OTwitter,  
dbo.Organization.Skype AS OSkype, dbo.Organization.Facebook AS OFacebook, dbo.Organization.GooglePlus AS OGooglePlus,  
dbo.Organization.LinkedIn AS OLinkedIn, dbo.Organization.Description AS ODescription, dbo.Organization.Logo AS OLogo, dbo.Organization.Country AS OCountry,  
dbo.Organization.Region AS ORegion, dbo.Organization.ZipCode AS OZipCode, dbo.Organization.City AS OCity, dbo.Organization.Created AS OCreated,  
dbo.Organization.Updated AS OUpdated, dbo.Organization.Latitude AS OLatitude, dbo.Organization.Longitude AS OLongitude,  
dbo.Organization.GoogleLocation AS OGoogleLocation ,dbo.GetScore(Solution.SolutionId,'JUDGE') as Score
FROM
dbo.Solution INNER JOIN dbo.Organization ON dbo.Solution.OrganizationId = dbo.Organization.OrganizationID 
WHERE 
Solution.ChallengeReference like @ChallengeReference and dbo.GetScore(Solution.SolutionId,'JUDGE')>= @MinScore and Solution.SolutionState>=@State               
and CreatedUserId=@UserId
and Solution.SolutionId in 
(select DISTINCT solutionid as SolutionIdList from 
SolutionLists

where (Category='Beneficiaries' and [KEY] in (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) or
(Category='Theme' and [KEY] in (SELECT Data FROM dbo.Split(@Categories, ','))) or 1=@lock)


)AS SOD
WHERE SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
AND @RowsPerPage*(@PageNumber)

END


GO
/****** Object:  StoredProcedure [dbo].[spGetSolutionsOrganizationsUsers]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizationsUsers]
(
	@RowsPerPage		INT,
	@PageNumber			INT,
	@MinScore			INT, 
	@MaxScore			INT,
	@State				INT,
	@Search				varchar(500),
	@Categories			varchar(500),
	@Beneficiaries		varchar(500),
	@DeliveryFormat		varchar(500),
	@UserId				INT,
	@ChallengeReference	varchar(50),
	@SolutionType	    varchar(50),
	@Language	    varchar(50),
	@Joly				varchar(500)
)
AS
	BEGIN
		DECLARE @filterLenght as int
		DECLARE @searchString as varchar(500)
		SET		@filterLenght=0
		SELECT	@Beneficiaries=REPLACE(@Beneficiaries,'''','')
		SELECT	@Categories=REPLACE(@Categories,'''','')
		SELECT	@DeliveryFormat=REPLACE(@DeliveryFormat,'''','')
		
		
		
		IF (LEN(@Beneficiaries)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Beneficiaries, ',')
		END

		IF (LEN(@Categories)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Categories, ',')
		END

		IF (LEN(@DeliveryFormat)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@DeliveryFormat, ',')
		END



		IF (LEN(@Search)>0  )
		BEGIN
			SET @searchString=@Search
	    END
		ELSE
		BEGIN
			SET @searchString='*'
		END
		
		

		SELECT	* 
		FROM	(	SELECT	ROW_NUMBER() OVER (ORDER BY dbo.GetScore(SLN.SolutionId,'JUDGE') desc) AS RowNum,
							SLN.SolutionId AS SSolutionId, 
							SLN.SolutionTypeId AS SSolutionTypeId, 
							SLN.Title AS STitle, 
							SLN.TagLine AS STagLine,  
							SLN.Description AS SDescription, 
							SLN.Biography AS SBiography, 
							SLN.Challenge AS SChallenge, 
							SLN.Approach AS SApproach,  
							SLN.Results AS SResults, 
							SLN.ImplementationDetails AS SImplementationDetails, 
							SLN.AdditionalCost AS SAdditionalCost,  
							SLN.AvailableResources AS SAvailableResources, 
							SLN.TimeFrame AS STimeFrame, 
							SLN.Duration AS SDuration,  
							SLN.DurationDetails AS SDurationDetails, 
							SLN.SolutionStatusId AS SSolutionStatusId, 
							SLN.SolutionType AS SSolutionType,  
							SLN.Topic AS STopic, 
							SLN.Language AS SLanguage, 
							SLN.CreatedUserId AS SCreatedUserId, 
							SLN.Deleted AS SDeleted,  
							SLN.Country AS SCountry, 
							SLN.Region AS SRegion, 
							SLN.City AS SCity, 
							SLN.Address AS SAddress,  
							SLN.ZipCode AS SZipCode, 
							SLN.Logo AS SLogo, 
							SLN.Cost1 AS SCost1, 
							SLN.Cost2 AS SCost2, 
							SLN.Cost3 AS SCost3,  
							SLN.DeliveryFormat AS SDeliveryFormat, 
							SLN.Cost AS SCost, 
							SLN.CostType AS SCostType, 
							SLN.CostDetails AS SCostDetails,  
							SLN.SolutionState AS SSolutionState, 
							SLN.Beneficiaries AS SBeneficiaries, 
							SLN.DateCreated AS SDateCreated,  
							SLN.DateUpdated AS SDateUpdated, 
							SLN.ChallengeReference AS SChallengeReference, 
							ORG.OrganizationID AS OOrganizationID,  
							ORG.Code AS OCode, 
							ORG.Name AS OName, 
							ORG.Address AS OAddress, 
							ORG.Phone AS OPhone,  
							ORG.Email AS OEmail, 
							ORG.ContactEmail AS OContactEmail, 
							ORG.Website AS OWebsite, 
							ORG.Twitter AS OTwitter,  
							ORG.Skype AS OSkype, 
							ORG.Facebook AS OFacebook, 
							ORG.GooglePlus AS OGooglePlus,  
							ORG.LinkedIN AS OLinkedIn, 
							ORG.Description AS ODescription, 
							ORG.Logo AS OLogo, 
							ORG.Country AS OCountry,  
							ORG.Region AS ORegion, 
							ORG.ZipCode AS OZipCode, 
							ORG.City AS OCity,
							ORG.Created AS OCreated,  
							ORG.Updated AS OUpdated, 
							ORG.Latitude AS OLatitude, 
							ORG.Longitude AS OLongitude,  
							ORG.GoogleLocation AS OGoogleLocation,
							dbo.GetScore(SLN.SolutionId,'JUDGE') AS Score,
							USR.FirstName,
							USR.LastName,
							USR.City,
							USR.Country,
							USR.email,
							USR.Telephone,
							USR.[Address]
					FROM	dbo.Solution AS SLN
							INNER JOIN dbo.Organization AS ORG ON SLN.OrganizationId = ORG.OrganizationID 
							INNER JOIN dbo.UserProperties AS USR ON SLN.CreatedUserId=USR.UserId
					WHERE	(@ChallengeReference='%' OR @ChallengeReference='' OR @ChallengeReference IS NULL OR SLN.ChallengeReference LIKE @ChallengeReference)
					and (@SolutionType='%' OR @SolutionType='' OR @SolutionType IS NULL OR SLN.SolutionType LIKE @SolutionType)
					and (@Language='%' OR @Language='' OR @Language IS NULL OR SLN.Language LIKE @Language)
							AND (@MinScore='' OR @MinScore IS NULL OR dbo.GetScore(SLN.SolutionId,'JUDGE')>= @MinScore) 
							AND (@State IS NULL OR SLN.SolutionState >= @State )
							AND (@UserId=-1 OR CreatedUserId=@UserId) 
							AND (((@Categories = '' AND @Beneficiaries = '' AND @DeliveryFormat = '')OR(@Categories IS NULL AND @Beneficiaries IS NULL AND @DeliveryFormat IS NULL) ) OR SLN.SolutionId IN (
							
							SELECT	solutionid AS SolutionIdList 
														
	FROM	SolutionLists
	WHERE	((Category='Beneficiaries' AND [KEY] IN (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) 
or (Category='Theme' AND [KEY] IN (SELECT Data FROM dbo.Split(@Categories, ',')))
or (Category='DeliveryFormat' AND [KEY] IN (SELECT Data FROM dbo.Split(@DeliveryFormat, ','))))  
														
					
	
									
														group by solutionid
														having COUNT(solutionid)=@filterLenght
														
														))
					        AND (@searchString='*' or freetext((Title, TagLine),@searchString))
					) AS SOD
		WHERE	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		
	END

GO
/****** Object:  StoredProcedure [dbo].[spGetSolutionsOrganizationsUsersModeOR]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizationsUsersModeOR]
(
	@RowsPerPage		INT,
	@PageNumber			INT,
	@MinScore			INT, 
	@MaxScore			INT,
	@State				INT,
	@Search				varchar(500),
	@Categories			varchar(500),
	@Beneficiaries		varchar(500),
	@DeliveryFormat		varchar(500),
	@UserId				INT,
	@ChallengeReference	varchar(50),
	@SolutionType	    varchar(50),
	@Language	    varchar(50),
	@Joly				varchar(500)
)
AS
	BEGIN
		DECLARE @filterLenght as int
		DECLARE @searchString as varchar(500)
		SET		@filterLenght=0
		SELECT	@Beneficiaries=REPLACE(@Beneficiaries,'''','')
		SELECT	@Categories=REPLACE(@Categories,'''','')
		SELECT	@DeliveryFormat=REPLACE(@DeliveryFormat,'''','')
		
		
		
		IF (LEN(@Beneficiaries)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Beneficiaries, ',')
		END

		IF (LEN(@Categories)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Categories, ',')
		END

		IF (LEN(@DeliveryFormat)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@DeliveryFormat, ',')
		END



		IF (LEN(@Search)>0  )
		BEGIN
			SET @searchString=@Search
	    END
		ELSE
		BEGIN
			SET @searchString='*'
		END
		
		

		SELECT	* 
		FROM	(	SELECT	ROW_NUMBER() OVER (ORDER BY dbo.GetScore(SLN.SolutionId,'JUDGE') desc) AS RowNum,
							SLN.SolutionId AS SSolutionId, 
							SLN.SolutionTypeId AS SSolutionTypeId, 
							SLN.Title AS STitle, 
							SLN.TagLine AS STagLine,  
							SLN.Description AS SDescription, 
							SLN.Biography AS SBiography, 
							SLN.Challenge AS SChallenge, 
							SLN.Approach AS SApproach,  
							SLN.Results AS SResults, 
							SLN.ImplementationDetails AS SImplementationDetails, 
							SLN.AdditionalCost AS SAdditionalCost,  
							SLN.AvailableResources AS SAvailableResources, 
							SLN.TimeFrame AS STimeFrame, 
							SLN.Duration AS SDuration,  
							SLN.DurationDetails AS SDurationDetails, 
							SLN.SolutionStatusId AS SSolutionStatusId, 
							SLN.SolutionType AS SSolutionType,  
							SLN.Topic AS STopic, 
							SLN.Language AS SLanguage, 
							SLN.CreatedUserId AS SCreatedUserId, 
							SLN.Deleted AS SDeleted,  
							SLN.Country AS SCountry, 
							SLN.Region AS SRegion, 
							SLN.City AS SCity, 
							SLN.Address AS SAddress,  
							SLN.ZipCode AS SZipCode, 
							SLN.Logo AS SLogo, 
							SLN.Cost1 AS SCost1, 
							SLN.Cost2 AS SCost2, 
							SLN.Cost3 AS SCost3,  
							SLN.DeliveryFormat AS SDeliveryFormat, 
							SLN.Cost AS SCost, 
							SLN.CostType AS SCostType, 
							SLN.CostDetails AS SCostDetails,  
							SLN.SolutionState AS SSolutionState, 
							SLN.Beneficiaries AS SBeneficiaries, 
							SLN.DateCreated AS SDateCreated,  
							SLN.DateUpdated AS SDateUpdated, 
							SLN.ChallengeReference AS SChallengeReference, 
							ORG.OrganizationID AS OOrganizationID,  
							ORG.Code AS OCode, 
							ORG.Name AS OName, 
							ORG.Address AS OAddress, 
							ORG.Phone AS OPhone,  
							ORG.Email AS OEmail, 
							ORG.ContactEmail AS OContactEmail, 
							ORG.Website AS OWebsite, 
							ORG.Twitter AS OTwitter,  
							ORG.Skype AS OSkype, 
							ORG.Facebook AS OFacebook, 
							ORG.GooglePlus AS OGooglePlus,  
							ORG.LinkedIN AS OLinkedIn, 
							ORG.Description AS ODescription, 
							ORG.Logo AS OLogo, 
							ORG.Country AS OCountry,  
							ORG.Region AS ORegion, 
							ORG.ZipCode AS OZipCode, 
							ORG.City AS OCity,
							ORG.Created AS OCreated,  
							ORG.Updated AS OUpdated, 
							ORG.Latitude AS OLatitude, 
							ORG.Longitude AS OLongitude,  
							ORG.GoogleLocation AS OGoogleLocation,
							dbo.GetScore(SLN.SolutionId,'JUDGE') AS Score,
							USR.FirstName,
							USR.LastName,
							USR.City,
							USR.Country,
							USR.email,
							USR.Telephone,
							USR.[Address]
					FROM	dbo.Solution AS SLN
							INNER JOIN dbo.Organization AS ORG ON SLN.OrganizationId = ORG.OrganizationID 
							INNER JOIN dbo.UserProperties AS USR ON SLN.CreatedUserId=USR.UserId
					WHERE	(@ChallengeReference='%' OR @ChallengeReference='' OR @ChallengeReference IS NULL OR SLN.ChallengeReference LIKE @ChallengeReference)
					and (@SolutionType='%' OR @SolutionType='' OR @SolutionType IS NULL OR SLN.SolutionType LIKE @SolutionType)
					and (@Language='%' OR @Language='' OR @Language IS NULL OR SLN.Language LIKE @Language)
							AND (@MinScore='' OR @MinScore IS NULL OR dbo.GetScore(SLN.SolutionId,'JUDGE')>= @MinScore) 
							AND (@State IS NULL OR SLN.SolutionState >= @State )
							AND (@UserId=-1 OR CreatedUserId=@UserId) 
							AND (((@Categories = '' AND @Beneficiaries = '' AND @DeliveryFormat = '')OR(@Categories IS NULL AND @Beneficiaries IS NULL AND @DeliveryFormat IS NULL) ) OR SLN.SolutionId IN (
							
							SELECT	distinct solutionid AS SolutionIdList 
														
	FROM	SolutionLists
	WHERE	((Category='Beneficiaries' AND [KEY] IN (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) 
or (Category='Theme' AND [KEY] IN (SELECT Data FROM dbo.Split(@Categories, ',')))
or (Category='DeliveryFormat' AND [KEY] IN (SELECT Data FROM dbo.Split(@DeliveryFormat, ','))))  
														
					
	
									
																
														))
					        AND (@searchString='*' or freetext((Title, TagLine),@searchString))
					) AS SOD
		WHERE	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		
	END

GO
/****** Object:  StoredProcedure [dbo].[spGetUsersProperties]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUsersProperties]
(
	@RowsPerPage		INT,
	@PageNumber			INT

)
AS 
SELECT	* 
		FROM (	SELECT ROW_NUMBER() OVER (ORDER BY USR.FirstName) AS RowNum,
		USR.UserId AS UUserId,
		USR.NexsoUserId AS UNexsoUserId,
		USR.Agreement AS UAgreement,
		USR.SkypeName AS USkypeName,
		USR.Twitter AS UTwitter,
		USR.FaceBook AS UFaceBook,
		USR.Google AS UGoogle,
		USR.LinkedIn AS ULinkedIn,
		USR.OtherSocialNetwork AS UOtherSocialNetwork,
		USR.City AS UCity,
		USR.Region AS URegion,
		USR.Country AS UCountry,
		USR.PostalCode AS UPostalCode,
		USR.Telephone AS UTelephone,
		USR.Address AS UAddress,	
		USR.LastName AS ULastName,		
		USR.FirstName AS UFirstName,
		USR.email AS UEmail,
		USR.CustomerType AS UCustomerType,
		USR.NexsoEnrolment AS UNexsoEnrolment,
		USR.AllowNexsoNotifications AS UAllowNexsoNotifications,
		USR.Language AS ULanguage,
		USR.Latitude AS ULatitude,
		USR.Longitude AS ULongitude,
		USR.GoogleLocation AS UGoogleLocation,
		USR.Bio AS UBio,
		USR.ProfilePicture AS UProfilePicture,
		USR.BannerPicture AS UBannerPicture
		
		FROM UserProperties AS USR ) AS SUSR
		WHERE SUSR.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		
	
		

GO
/****** Object:  UserDefinedFunction [dbo].[GetScore]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetScore] (@SolutionId uniqueidentifier,@ScoreType varchar(50) )
RETURNS INT
AS
BEGIN

DECLARE @rate          INT
SET @rate = 0

IF @ScoreType is not null
begin
SELECT @rate= AVG(Scores.ComputedValue) 
  FROM [MIFNEXSO2015].[dbo].[Scores]
  where SolutionId= @SolutionId and scoretype=@ScoreType
  group by solutionid
end
else
SELECT @rate= AVG(Scores.ComputedValue) 
  FROM [MIFNEXSO2015].[dbo].[Scores]
  where SolutionId= @SolutionId
  group by solutionid


RETURN @rate

END


GO
/****** Object:  UserDefinedFunction [dbo].[GetScoreOld]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[GetScoreOld] (@SolutionId uniqueidentifier,@ScoreType varchar(50) )
RETURNS INT
AS
BEGIN

DECLARE @rate          INT
SET @rate = 0

IF @ScoreType is not null
begin
SELECT @rate= AVG(Scores.ComputedValue) 
  FROM [MIFNEXSO2015].[dbo].[Scores]
  where SolutionId= @SolutionId and scoretype=@ScoreType
  group by solutionid
end
else
SELECT @rate= AVG(Scores.ComputedValue) 
  FROM [MIFNEXSO2015].[dbo].[Scores]
  where SolutionId= @SolutionId
  group by solutionid


RETURN @rate

END


GO
/****** Object:  UserDefinedFunction [dbo].[WordCount]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WordCount] ( @solutionId uniqueidentifier ) 
RETURNS INT
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @WordCount      INT
DECLARE @InputString varchar(max)



SELECT @InputString=ISNULL(title,' ')+' '+ISNULL(TagLine,' ')+' '+
ISNULL(Challenge,' ')+' '+ISNULL(Approach,' ')+' '+ISNULL(Results,' ')+' '+
ISNULL(Description,' ')+ISNULL(CostDetails ,' ')+
ISNULL(ImplementationDetails,' ')+ISNULL(DurationDetails,' ')
FROM [MIFNEXSO2015].[dbo].[Solution]
WHERE SolutionId=@solutionId

SET @Index = 1
SET @WordCount = 0

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar = ' ' AND @Char != ' '
        SET @WordCount = @WordCount + 1

    SET @Index = @Index + 1
END

RETURN @WordCount

END


GO
/****** Object:  UserDefinedFunction [dbo].[WordCountPerField]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WordCountPerField] ( @InputString varchar(max) ) 
RETURNS INT
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @WordCount      INT






SET @Index = 1
SET @WordCount = 0

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar = ' ' AND @Char != ' '
        SET @WordCount = @WordCount + 1

    SET @Index = @Index + 1
END

RETURN @WordCount

END


GO
/****** Object:  Table [dbo].[CampaignLogs]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampaignLogs](
	[CampaignLogId] [uniqueidentifier] NOT NULL,
	[CampaignId] [uniqueidentifier] NULL,
	[email] [varchar](100) NULL,
	[userId] [int] NULL,
	[SentOn] [datetime] NULL,
	[Status] [varchar](50) NULL,
	[MailContent] [varchar](max) NULL,
	[MailSubject] [varchar](500) NULL,
	[CreatedOn] [datetime] NULL,
	[ReadOn] [datetime] NULL,
	[TrackKey] [varchar](50) NULL,
	[CampaignAttemp] [int] NOT NULL,
	[Attemp] [int] NOT NULL,
	[TrackingMetaData] [varchar](max) NULL,
 CONSTRAINT [PK_CampaignLogs] PRIMARY KEY CLUSTERED 
(
	[CampaignLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Campaigns]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Campaigns](
	[CampaignId] [uniqueidentifier] NOT NULL,
	[TemplateId] [uniqueidentifier] NULL,
	[Description] [varchar](500) NULL,
	[CampaignName] [varchar](50) NULL,
	[SendOn] [datetime] NULL,
	[Repeat] [int] NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[Status] [varchar](10) NULL,
	[Deleted] [bit] NOT NULL,
	[FilterTemplate] [varchar](max) NULL,
	[CampaignType] [int] NOT NULL,
	[NextExecution] [datetime] NULL,
	[TrackKey] [varchar](50) NULL,
	[Attemps] [int] NOT NULL,
 CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED 
(
	[CampaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CampaignTemplates]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CampaignTemplates](
	[TemplateId] [uniqueidentifier] NOT NULL,
	[TemplateTitle] [varchar](50) NULL,
	[TemplateContent] [varchar](max) NULL,
	[TemplateVersion] [int] NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[Deleted] [bit] NOT NULL,
	[Language] [varchar](10) NULL,
	[TemplateSubject] [varchar](500) NULL,
 CONSTRAINT [PK_CampaignTemplates] PRIMARY KEY CLUSTERED 
(
	[TemplateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ChallengeCustomData]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChallengeCustomData](
	[ChallengeCustomDatalId] [uniqueidentifier] NOT NULL,
	[ChallengeReference] [varchar](50) NOT NULL,
	[Language] [varchar](50) NOT NULL,
	[EligibilityTemplate] [varchar](max) NULL,
	[CustomDataTemplate] [varchar](max) NULL,
	[Tags] [varchar](200) NULL,
	[PreConditionsTemplate] [varchar](max) NULL,
	[PostConditionsTemplate] [varchar](max) NULL,
 CONSTRAINT [PK_ChallengeCustomData] PRIMARY KEY CLUSTERED 
(
	[ChallengeCustomDatalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ChallengeJudges]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChallengeJudges](
	[ChallengeUserId] [uniqueidentifier] NOT NULL,
	[UserId] [int] NOT NULL,
	[ChallengeId] [uniqueidentifier] NOT NULL,
	[PermisionLevel] [varchar](50) NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
 CONSTRAINT [PK_ChallengeJudges] PRIMARY KEY CLUSTERED 
(
	[ChallengeUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ChallengeSchemas]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChallengeSchemas](
	[ChallengeReference] [varchar](50) NOT NULL,
	[ChallengeTitle] [varchar](100) NOT NULL,
	[Description] [varchar](500) NULL,
	[Created] [datetime] NOT NULL,
	[Updated] [datetime] NOT NULL,
	[AvailableFrom] [datetime] NULL,
	[AvailableTo] [datetime] NULL,
	[Url] [varchar](100) NULL,
	[EnterUrl] [varchar](100) NULL,
	[OutUrl] [varchar](100) NULL,
 CONSTRAINT [PK_Challenges_1] PRIMARY KEY CLUSTERED 
(
	[ChallengeReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CustomDataLog]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CustomDataLog](
	[CustomDataLogId] [uniqueidentifier] NOT NULL,
	[SolutionId] [uniqueidentifier] NOT NULL,
	[CustomData] [varchar](max) NOT NULL,
	[CustomaDataSchema] [varchar](max) NULL,
	[Created] [datetime] NOT NULL,
	[Updated] [datetime] NULL,
	[CustomDataType] [varchar](50) NOT NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_CustomDataLog] PRIMARY KEY CLUSTERED 
(
	[CustomDataLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Documents]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Documents](
	[DocumentId] [uniqueidentifier] NOT NULL,
	[ExternalReference] [uniqueidentifier] NULL,
	[Title] [varchar](200) NULL,
	[Name] [varchar](200) NULL,
	[Size] [int] NULL,
	[DocumentObject] [varbinary](max) NOT NULL,
	[Created] [datetime] NOT NULL,
	[Updated] [datetime] NOT NULL,
	[Read] [datetime] NULL,
	[Deleted] [bit] NULL,
	[Status] [varchar](10) NULL,
	[Permission] [varchar](10) NULL,
	[Description] [varchar](500) NULL,
	[FileType] [varchar](50) NULL,
	[Version] [int] NOT NULL,
	[Category] [varchar](50) NULL,
	[Author] [varchar](50) NULL,
	[Views] [int] NOT NULL,
	[Tags] [varchar](5000) NULL,
	[DocumentType] [varchar](50) NULL,
	[Scope] [varchar](50) NULL,
	[UploadedBy] [int] NULL,
	[CreatedBy] [int] NULL,
	[Folder] [varchar](500) NULL,
 CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED 
(
	[DocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Lists]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Lists](
	[Key] [varchar](50) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Culture] [varchar](10) NOT NULL,
	[Value] [varchar](200) NOT NULL,
	[ValueType] [varchar](50) NULL,
	[Label] [varchar](500) NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_Lists] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Category] ASC,
	[Culture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailTrackerLogs]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailTrackerLogs](
	[MailTrackerLogId] [uniqueidentifier] NOT NULL,
	[CampaingLogId] [uniqueidentifier] NOT NULL,
	[Language] [varchar](10) NULL,
	[Country] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[Latitude] [decimal](10, 7) NULL,
	[Longitude] [decimal](10, 7) NULL,
	[SourceBrowsing] [varchar](50) NULL,
	[IP] [varchar](50) NULL,
	[Network] [varchar](100) NULL,
	[Browser] [varchar](100) NULL,
	[Device] [varchar](100) NULL,
 CONSTRAINT [PK_MailTrackerLogs] PRIMARY KEY CLUSTERED 
(
	[MailTrackerLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Messages]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Messages](
	[MessageId] [uniqueidentifier] NOT NULL,
	[FromUserId] [int] NULL,
	[ToUserId] [int] NULL,
	[Message] [varchar](max) NULL,
	[DateCreated] [datetime] NULL,
	[DateRead] [datetime] NULL,
 CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED 
(
	[MessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Notifications](
	[NotificationId] [uniqueidentifier] NOT NULL,
	[UserId] [int] NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Created] [datetime] NOT NULL,
	[Read] [datetime] NULL,
	[Message] [varchar](500) NULL,
	[ToolTip] [varchar](500) NULL,
	[Tag] [varchar](500) NOT NULL,
	[Link] [varchar](500) NULL,
	[ObjectType] [varchar](500) NULL,
 CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Organization]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Organization](
	[OrganizationID] [uniqueidentifier] NOT NULL,
	[Code] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[Address] [varchar](200) NULL,
	[Phone] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[ContactEmail] [varchar](100) NULL,
	[Website] [varchar](100) NULL,
	[Twitter] [varchar](100) NULL,
	[Skype] [varchar](100) NULL,
	[Facebook] [varchar](100) NULL,
	[GooglePlus] [varchar](100) NULL,
	[LinkedIn] [varchar](100) NULL,
	[Description] [varchar](800) NULL,
	[Logo] [varchar](200) NULL,
	[Country] [varchar](50) NULL,
	[Region] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[ZipCode] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[Latitude] [decimal](10, 7) NULL,
	[Longitude] [decimal](10, 7) NULL,
	[GoogleLocation] [varchar](1000) NULL,
	[Language] [varchar](5) NULL,
 CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED 
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PotentialUsers]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PotentialUsers](
	[PotentialUserId] [uniqueidentifier] NOT NULL,
	[Email] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[MiddleName] [varchar](100) NULL,
	[Phone] [varchar](100) NULL,
	[Address] [varchar](400) NULL,
	[Country] [varchar](100) NULL,
	[Region] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Language] [varchar](10) NULL,
	[OrganizationName] [varchar](200) NULL,
	[OrganizationType] [varchar](50) NULL,
	[Qualification] [varchar](50) NULL,
	[Source] [varchar](100) NULL,
	[Latitude] [decimal](10, 7) NULL,
	[Longitude] [decimal](10, 7) NULL,
	[Batch] [varchar](100) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[Deleted] [bit] NULL,
	[GoogleLocation] [varchar](1000) NULL,
	[CustomField1] [varchar](500) NULL,
	[CustomField2] [varchar](500) NULL,
	[Title] [varchar](100) NULL,
	[ZipCode] [varchar](50) NULL,
	[WebSite] [varchar](200) NULL,
	[LinkedIn] [varchar](50) NULL,
	[GooglePlus] [varchar](50) NULL,
	[Twitter] [varchar](50) NULL,
	[Facebook] [varchar](50) NULL,
	[Skype] [varchar](50) NULL,
	[Sector] [varchar](200) NULL,
 CONSTRAINT [PK_PotentialUsers] PRIMARY KEY CLUSTERED 
(
	[PotentialUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Scores]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Scores](
	[ScoreId] [uniqueidentifier] NOT NULL,
	[UserId] [int] NOT NULL,
	[SolutionId] [uniqueidentifier] NOT NULL,
	[ScoreType] [varchar](50) NOT NULL,
	[ComputedValue] [float] NULL,
	[Active] [bit] NOT NULL,
	[Created] [datetime] NOT NULL,
	[Updated] [datetime] NOT NULL,
 CONSTRAINT [PK_Scores] PRIMARY KEY CLUSTERED 
(
	[ScoreId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScoreTypes]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScoreTypes](
	[ScoreTypeId] [varchar](50) NOT NULL,
	[ScoreName] [varchar](50) NOT NULL,
	[Weight] [float] NOT NULL,
 CONSTRAINT [PK_ScoreTypes] PRIMARY KEY CLUSTERED 
(
	[ScoreTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScoreValues]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScoreValues](
	[ScoreValueId] [uniqueidentifier] NOT NULL,
	[ScoreId] [uniqueidentifier] NOT NULL,
	[value] [float] NOT NULL,
	[ScoreValueType] [varchar](50) NOT NULL,
	[Created] [datetime] NOT NULL,
	[Updated] [datetime] NOT NULL,
 CONSTRAINT [PK_ScoreValues] PRIMARY KEY CLUSTERED 
(
	[ScoreValueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SocialMediaIndicators]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SocialMediaIndicators](
	[SocialMediaIndicatorId] [uniqueidentifier] NOT NULL,
	[ObjectId] [uniqueidentifier] NOT NULL,
	[ObjectType] [varchar](50) NOT NULL,
	[UserId] [int] NULL,
	[IndicatorType] [varchar](50) NOT NULL,
	[Value] [decimal](12, 2) NOT NULL,
	[Created] [datetime] NULL,
	[Unit] [varbinary](50) NULL,
	[Aggregator] [varchar](10) NOT NULL,
 CONSTRAINT [PK_SocialMediaIndicators] PRIMARY KEY CLUSTERED 
(
	[SocialMediaIndicatorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Solution]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Solution](
	[SolutionId] [uniqueidentifier] NOT NULL,
	[OrganizationId] [uniqueidentifier] NOT NULL,
	[SolutionTypeId] [int] NULL,
	[Title] [varchar](200) NULL,
	[TagLine] [varchar](500) NULL,
	[Description] [varchar](1500) NULL,
	[Biography] [varchar](1000) NULL,
	[Challenge] [varchar](1000) NULL,
	[Approach] [varchar](1000) NULL,
	[Results] [varchar](1000) NULL,
	[ImplementationDetails] [varchar](1000) NULL,
	[AdditionalCost] [varchar](500) NULL,
	[AvailableResources] [varchar](500) NULL,
	[TimeFrame] [varchar](500) NULL,
	[Duration] [int] NULL,
	[DurationDetails] [varchar](500) NULL,
	[SolutionStatusId] [int] NULL,
	[SolutionType] [varchar](50) NULL,
	[Topic] [int] NULL,
	[Language] [varchar](5) NULL,
	[CreatedUserId] [int] NULL,
	[Deleted] [bit] NULL,
	[Country] [nchar](50) NULL,
	[Region] [nchar](50) NULL,
	[City] [nchar](50) NULL,
	[Address] [varchar](200) NULL,
	[ZipCode] [varchar](50) NULL,
	[Logo] [varchar](200) NULL,
	[Cost1] [decimal](16, 2) NULL,
	[Cost2] [decimal](16, 2) NULL,
	[Cost3] [decimal](16, 2) NULL,
	[DeliveryFormat] [int] NULL,
	[Cost] [decimal](16, 2) NULL,
	[CostType] [int] NULL,
	[CostDetails] [varchar](500) NULL,
	[SolutionState] [int] NULL,
	[Beneficiaries] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[ChallengeReference] [varchar](50) NULL,
	[CustomData] [varchar](max) NULL,
	[CustomDataTemplate] [varchar](max) NULL,
	[CustomDataScore] [varchar](max) NULL,
	[CustomScore] [float] NULL,
	[DatePublished] [datetime] NULL,
	[VideoObject] [varchar](500) NULL,
 CONSTRAINT [PK_Solution] PRIMARY KEY CLUSTERED 
(
	[SolutionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SolutionComments]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SolutionComments](
	[Comment_Id] [uniqueidentifier] NOT NULL,
	[SolutionId] [uniqueidentifier] NULL,
	[UserId] [int] NULL,
	[Comment] [varchar](5000) NULL,
	[CreatedDate] [datetime] NULL,
	[Publish] [bit] NULL,
	[Scope] [varchar](50) NULL,
 CONSTRAINT [PK_SolutionComments] PRIMARY KEY CLUSTERED 
(
	[Comment_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SolutionLists]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SolutionLists](
	[ListId] [uniqueidentifier] NOT NULL,
	[SolutionId] [uniqueidentifier] NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Key] [varchar](50) NOT NULL,
 CONSTRAINT [PK_SolutionLists] PRIMARY KEY CLUSTERED 
(
	[ListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SolutionLocations]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SolutionLocations](
	[SolutionLocationId] [uniqueidentifier] NOT NULL,
	[SolutionId] [uniqueidentifier] NOT NULL,
	[Country] [varchar](50) NULL,
	[Region] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[Latitude] [decimal](10, 7) NULL,
	[Longitude] [decimal](10, 7) NULL,
	[GoogleLocation] [varchar](1000) NULL,
	[Address] [varchar](100) NULL,
	[PostalCode] [varchar](50) NULL,
 CONSTRAINT [PK_SolutionLocations] PRIMARY KEY CLUSTERED 
(
	[SolutionLocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SolutionLogs]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SolutionLogs](
	[SolutionLogId] [uniqueidentifier] NOT NULL,
	[SolutionId] [uniqueidentifier] NOT NULL,
	[Key] [varchar](100) NOT NULL,
	[Value] [varchar](max) NULL,
	[Date] [datetime] NOT NULL,
	[DataType] [varchar](50) NULL,
	[Schema] [varchar](max) NULL,
	[Delete] [bit] NOT NULL,
	[UserID] [int] NULL,
 CONSTRAINT [PK_SolutionLogs] PRIMARY KEY CLUSTERED 
(
	[SolutionLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserNotificationConnections]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserNotificationConnections](
	[UserNotificationConnection] [uniqueidentifier] NOT NULL,
	[NotificationId] [uniqueidentifier] NOT NULL,
	[UserId] [int] NOT NULL,
	[Rol] [varchar](50) NOT NULL,
	[Tag] [varchar](500) NULL,
 CONSTRAINT [PK_UserNotificationConnections] PRIMARY KEY CLUSTERED 
(
	[UserNotificationConnection] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserOrganization]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserOrganization](
	[OrganizationID] [uniqueidentifier] NOT NULL,
	[UserID] [int] NOT NULL,
	[Role] [int] NOT NULL,
 CONSTRAINT [PK_UserOrganization] PRIMARY KEY CLUSTERED 
(
	[OrganizationID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserProperties]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserProperties](
	[UserId] [int] NOT NULL,
	[NexsoUserId] [uniqueidentifier] NULL,
	[Agreement] [varchar](50) NULL,
	[SkypeName] [varchar](100) NULL,
	[Twitter] [varchar](100) NULL,
	[FaceBook] [varchar](100) NULL,
	[Google] [varchar](100) NULL,
	[LinkedIn] [varchar](100) NULL,
	[OtherSocialNetwork] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Region] [varchar](100) NULL,
	[Country] [varchar](100) NULL,
	[PostalCode] [varchar](100) NULL,
	[Telephone] [varchar](100) NULL,
	[Address] [varchar](200) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[email] [varchar](200) NULL,
	[CustomerType] [int] NULL,
	[NexsoEnrolment] [int] NULL,
	[AllowNexsoNotifications] [int] NULL,
	[Language] [int] NULL,
	[Latitude] [decimal](10, 7) NULL,
	[Longitude] [decimal](10, 7) NULL,
	[GoogleLocation] [varchar](1000) NULL,
	[Bio] [varchar](500) NULL,
	[ProfilePicture] [uniqueidentifier] NULL,
	[BannerPicture] [uniqueidentifier] NULL,
 CONSTRAINT [PK_UserProperties] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserPropertiesLists]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserPropertiesLists](
	[ListId] [uniqueidentifier] NOT NULL,
	[UserPropertyId] [int] NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Key] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UserPropertiesLists] PRIMARY KEY CLUSTERED 
(
	[ListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split]
(
    @String NVARCHAR(4000),
    @Delimiter NCHAR(1)
)
RETURNS TABLE 
AS
RETURN 
(
    WITH Split(stpos,endpos) 
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
    SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split
)


GO
/****** Object:  View [dbo].[SolutionOrganizationView]    Script Date: 4/17/2015 10:19:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SolutionOrganizationView]
AS
SELECT     dbo.Solution.SolutionId AS SSolutionId, dbo.Solution.SolutionTypeId AS SSolutionTypeId, dbo.Solution.Title AS STitle, dbo.Solution.TagLine AS STagLine, dbo.Solution.Description AS SDescription, 
                      dbo.Solution.Biography AS SBiography, dbo.Solution.Challenge AS SChallenge, dbo.Solution.Approach AS SApproach, dbo.Solution.Results AS SResults, 
                      dbo.Solution.ImplementationDetails AS SImplementationDetails, dbo.Solution.AdditionalCost AS SAdditionalCost, dbo.Solution.AvailableResources AS SAvailableResources, 
                      dbo.Solution.TimeFrame AS STimeFrame, dbo.Solution.Duration AS SDuration, dbo.Solution.DurationDetails AS SDurationDetails, dbo.Solution.SolutionStatusId AS SSolutionStatusId, 
                      dbo.Solution.SolutionType AS SSolutionType, dbo.Solution.Topic AS STopic, dbo.Solution.Language AS SLanguage, dbo.Solution.CreatedUserId AS SCreatedUserId, 
                      dbo.Solution.Deleted AS SDeleted, dbo.Solution.Country AS SCountry, dbo.Solution.Region AS SRegion, dbo.Solution.City AS SCity, dbo.Solution.Address AS SAddress, 
                      dbo.Solution.ZipCode AS SZipCode, dbo.Solution.Logo AS SLogo, dbo.Solution.Cost1 AS SCost1, dbo.Solution.Cost2 AS SCost2, dbo.Solution.Cost3 AS SCost3, 
                      dbo.Solution.DeliveryFormat AS SDeliveryFormat, dbo.Solution.Cost AS SCost, dbo.Solution.CostType AS SCostType, dbo.Solution.CostDetails AS SCostDetails, 
                      dbo.Solution.SolutionState AS SSolutionState, dbo.Solution.Beneficiaries AS SBeneficiaries, dbo.Solution.DateCreated AS SDateCreated, dbo.Solution.DateUpdated AS SDateUpdated, 
                      dbo.Solution.ChallengeReference AS SChallengeReference, dbo.Organization.OrganizationID AS OOrganizationID, dbo.Organization.Code AS OCode, dbo.Organization.Name AS OName, 
                      dbo.Organization.Address AS OAddress, dbo.Organization.Phone AS OPhone, dbo.Organization.Email AS OEmail, dbo.Organization.ContactEmail AS OContactEmail, 
                      dbo.Organization.Website AS OWebsite, dbo.Organization.Twitter AS OTwitter, dbo.Organization.Skype AS OSkype, dbo.Organization.Facebook AS OFacebook, 
                      dbo.Organization.GooglePlus AS OGooglePlus, dbo.Organization.LinkedIn AS OLinkedIn, dbo.Organization.Description AS ODescription, dbo.Organization.Logo AS OLogo, 
                      dbo.Organization.Country AS OCountry, dbo.Organization.Region AS ORegion, dbo.Organization.ZipCode AS OZipCode, dbo.Organization.City AS OCity, dbo.Organization.Created AS OCreated, 
                      dbo.Organization.Updated AS OUpdated, dbo.Organization.Latitude AS OLatitude, dbo.Organization.Longitude AS OLongitude, dbo.Organization.GoogleLocation AS OGoogleLocation, 
                      dbo.Solution.VideoObject
FROM         dbo.Solution INNER JOIN
                      dbo.Organization ON dbo.Solution.OrganizationId = dbo.Organization.OrganizationID


GO
/****** Object:  FullTextIndex     Script Date: 4/17/2015 10:19:30 AM ******/
CREATE FULLTEXT INDEX ON [dbo].[Solution](
[TagLine] LANGUAGE [English], 
[Title] LANGUAGE [English])
KEY INDEX [PK_Solution]ON ([SolutionCatalog], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)


GO
ALTER TABLE [dbo].[CampaignLogs] ADD  CONSTRAINT [DF_CampaingLogs_CampaingAttemp]  DEFAULT ((0)) FOR [CampaignAttemp]
GO
ALTER TABLE [dbo].[CampaignLogs] ADD  CONSTRAINT [DF_CampaingLogs_Attemp]  DEFAULT ((0)) FOR [Attemp]
GO
ALTER TABLE [dbo].[Campaigns] ADD  CONSTRAINT [DF_Campaings_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Campaigns] ADD  CONSTRAINT [DF_Campaings_Attemps]  DEFAULT ((0)) FOR [Attemps]
GO
ALTER TABLE [dbo].[CampaignTemplates] ADD  CONSTRAINT [DF_CampaingTemplates_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Documents] ADD  CONSTRAINT [DF_Documents_Version]  DEFAULT ((1)) FOR [Version]
GO
ALTER TABLE [dbo].[Documents] ADD  CONSTRAINT [DF_Documents_Views]  DEFAULT ((0)) FOR [Views]
GO
ALTER TABLE [dbo].[Lists] ADD  CONSTRAINT [DF_Lists_Order]  DEFAULT ((0)) FOR [Order]
GO
ALTER TABLE [dbo].[Scores] ADD  CONSTRAINT [DF_Scores_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Solution] ADD  CONSTRAINT [DF_Solution_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[SolutionLogs] ADD  CONSTRAINT [DF_SolutionLogs_Delete]  DEFAULT ((0)) FOR [Delete]
GO
ALTER TABLE [dbo].[CampaignLogs]  WITH NOCHECK ADD  CONSTRAINT [FK_CampaignLogs_Campaigns] FOREIGN KEY([CampaignId])
REFERENCES [dbo].[Campaigns] ([CampaignId])
GO
ALTER TABLE [dbo].[CampaignLogs] NOCHECK CONSTRAINT [FK_CampaignLogs_Campaigns]
GO
ALTER TABLE [dbo].[Campaigns]  WITH NOCHECK ADD  CONSTRAINT [FK_Campaigns_CampaignTemplates] FOREIGN KEY([TemplateId])
REFERENCES [dbo].[CampaignTemplates] ([TemplateId])
GO
ALTER TABLE [dbo].[Campaigns] NOCHECK CONSTRAINT [FK_Campaigns_CampaignTemplates]
GO
ALTER TABLE [dbo].[ChallengeCustomData]  WITH NOCHECK ADD  CONSTRAINT [FK_ChallengeCustomData_Challenges] FOREIGN KEY([ChallengeReference])
REFERENCES [dbo].[ChallengeSchemas] ([ChallengeReference])
GO
ALTER TABLE [dbo].[ChallengeCustomData] NOCHECK CONSTRAINT [FK_ChallengeCustomData_Challenges]
GO
ALTER TABLE [dbo].[ChallengeJudges]  WITH NOCHECK ADD  CONSTRAINT [FK_ChallengeJudges_UserProperties] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[ChallengeJudges] NOCHECK CONSTRAINT [FK_ChallengeJudges_UserProperties]
GO
ALTER TABLE [dbo].[CustomDataLog]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomDataLog_Solution] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[CustomDataLog] NOCHECK CONSTRAINT [FK_CustomDataLog_Solution]
GO
ALTER TABLE [dbo].[CustomDataLog]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomDataLog_UserProperties] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[CustomDataLog] NOCHECK CONSTRAINT [FK_CustomDataLog_UserProperties]
GO
ALTER TABLE [dbo].[Documents]  WITH NOCHECK ADD  CONSTRAINT [FK_Documents_Campaigns] FOREIGN KEY([ExternalReference])
REFERENCES [dbo].[Campaigns] ([CampaignId])
GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Campaigns]
GO
ALTER TABLE [dbo].[Documents]  WITH NOCHECK ADD  CONSTRAINT [FK_Documents_Organization] FOREIGN KEY([ExternalReference])
REFERENCES [dbo].[Organization] ([OrganizationID])
GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Organization]
GO
ALTER TABLE [dbo].[Documents]  WITH NOCHECK ADD  CONSTRAINT [FK_Documents_Solution] FOREIGN KEY([ExternalReference])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Solution]
GO
ALTER TABLE [dbo].[Documents]  WITH NOCHECK ADD  CONSTRAINT [FK_Documents_UserProperties] FOREIGN KEY([UploadedBy])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_UserProperties]
GO
ALTER TABLE [dbo].[Documents]  WITH NOCHECK ADD  CONSTRAINT [FK_Documents_UserProperties1] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_UserProperties1]
GO
ALTER TABLE [dbo].[MailTrackerLogs]  WITH NOCHECK ADD  CONSTRAINT [FK_MailTrackerLogs_CampaignLogs] FOREIGN KEY([CampaingLogId])
REFERENCES [dbo].[CampaignLogs] ([CampaignLogId])
GO
ALTER TABLE [dbo].[MailTrackerLogs] NOCHECK CONSTRAINT [FK_MailTrackerLogs_CampaignLogs]
GO
ALTER TABLE [dbo].[Notifications]  WITH NOCHECK ADD  CONSTRAINT [FK_Notifications_UserProperties] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[Notifications] NOCHECK CONSTRAINT [FK_Notifications_UserProperties]
GO
ALTER TABLE [dbo].[Scores]  WITH NOCHECK ADD  CONSTRAINT [FK_Scores_Scores] FOREIGN KEY([ScoreId])
REFERENCES [dbo].[Scores] ([ScoreId])
GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_Scores]
GO
ALTER TABLE [dbo].[Scores]  WITH NOCHECK ADD  CONSTRAINT [FK_Scores_ScoreTypes] FOREIGN KEY([ScoreType])
REFERENCES [dbo].[ScoreTypes] ([ScoreTypeId])
GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_ScoreTypes]
GO
ALTER TABLE [dbo].[Scores]  WITH NOCHECK ADD  CONSTRAINT [FK_Scores_Solution] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_Solution]
GO
ALTER TABLE [dbo].[Scores]  WITH NOCHECK ADD  CONSTRAINT [FK_Scores_UserProperties] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_UserProperties]
GO
ALTER TABLE [dbo].[ScoreValues]  WITH NOCHECK ADD  CONSTRAINT [FK_ScoreValues_Scores] FOREIGN KEY([ScoreId])
REFERENCES [dbo].[Scores] ([ScoreId])
GO
ALTER TABLE [dbo].[ScoreValues] NOCHECK CONSTRAINT [FK_ScoreValues_Scores]
GO
ALTER TABLE [dbo].[ScoreValues]  WITH NOCHECK ADD  CONSTRAINT [FK_ScoreValues_ScoreTypes] FOREIGN KEY([ScoreValueType])
REFERENCES [dbo].[ScoreTypes] ([ScoreTypeId])
GO
ALTER TABLE [dbo].[ScoreValues] NOCHECK CONSTRAINT [FK_ScoreValues_ScoreTypes]
GO
ALTER TABLE [dbo].[SocialMediaIndicators]  WITH NOCHECK ADD  CONSTRAINT [FK_SocialMediaIndicators_UserProperties] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[SocialMediaIndicators] NOCHECK CONSTRAINT [FK_SocialMediaIndicators_UserProperties]
GO
ALTER TABLE [dbo].[Solution]  WITH NOCHECK ADD  CONSTRAINT [FK_Solution_Organization] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organization] ([OrganizationID])
GO
ALTER TABLE [dbo].[Solution] NOCHECK CONSTRAINT [FK_Solution_Organization]
GO
ALTER TABLE [dbo].[SolutionComments]  WITH NOCHECK ADD  CONSTRAINT [FK_SolutionComments_Solution] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[SolutionComments] NOCHECK CONSTRAINT [FK_SolutionComments_Solution]
GO
ALTER TABLE [dbo].[SolutionLists]  WITH NOCHECK ADD  CONSTRAINT [FK_SolutionLists_Solution] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[SolutionLists] NOCHECK CONSTRAINT [FK_SolutionLists_Solution]
GO
ALTER TABLE [dbo].[SolutionLocations]  WITH NOCHECK ADD  CONSTRAINT [FK_SolutionLocations_Solution] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[SolutionLocations] NOCHECK CONSTRAINT [FK_SolutionLocations_Solution]
GO
ALTER TABLE [dbo].[SolutionLogs]  WITH NOCHECK ADD  CONSTRAINT [FK_SolutionLogs_Solution] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solution] ([SolutionId])
GO
ALTER TABLE [dbo].[SolutionLogs] NOCHECK CONSTRAINT [FK_SolutionLogs_Solution]
GO
ALTER TABLE [dbo].[UserNotificationConnections]  WITH NOCHECK ADD  CONSTRAINT [FK_UserNotificationConnections_Notifications] FOREIGN KEY([NotificationId])
REFERENCES [dbo].[Notifications] ([NotificationId])
GO
ALTER TABLE [dbo].[UserNotificationConnections] NOCHECK CONSTRAINT [FK_UserNotificationConnections_Notifications]
GO
ALTER TABLE [dbo].[UserNotificationConnections]  WITH NOCHECK ADD  CONSTRAINT [FK_UserNotificationConnections_UserProperties] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[UserNotificationConnections] NOCHECK CONSTRAINT [FK_UserNotificationConnections_UserProperties]
GO
ALTER TABLE [dbo].[UserOrganization]  WITH NOCHECK ADD  CONSTRAINT [FK_UserOrganization_Organization] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organization] ([OrganizationID])
GO
ALTER TABLE [dbo].[UserOrganization] NOCHECK CONSTRAINT [FK_UserOrganization_Organization]
GO
ALTER TABLE [dbo].[UserPropertiesLists]  WITH NOCHECK ADD  CONSTRAINT [FK_UserPropertiesLists_UserProperties] FOREIGN KEY([UserPropertyId])
REFERENCES [dbo].[UserProperties] ([UserId])
GO
ALTER TABLE [dbo].[UserPropertiesLists] NOCHECK CONSTRAINT [FK_UserPropertiesLists_UserProperties]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Solution"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 42
         End
         Begin Table = "Organization"
            Begin Extent = 
               Top = 18
               Left = 299
               Bottom = 137
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1560
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SolutionOrganizationView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SolutionOrganizationView'
GO
ALTER DATABASE [MIFNEXSO2015] SET  READ_WRITE 
GO

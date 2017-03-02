﻿CREATE PROCEDURE [dbo].[dnn_EasyDNNnewsGetEvents]
	@PortalID INT, -- current Portal
	@ModuleID INT, -- current Module, portal sharing isto sadrzi dobre kategorije, auto add i setingsi su snimljeni kod tog modula
	@UserID INT,
	@OrderBy NVARCHAR(30) = 'PublishDate DESC',
	@ItemsFrom INT = 1,
	@ItemsTo INT = 5,
	@DateRangeType TINYINT = 0, -- 0 - gleda se current date, 1 - gleda se from to, 2 - gleda se start date
	@FromDate DATETIME = NULL, -- ovo ne treba za only events
	@ToDate DATETIME = NULL, -- ovo ne treba za only events
	/* od tud ide filter */
	@OnlyOneCategory INT = NULL, -- used for category menu or vhen need to filter by one category
	@Featured BIT = 0,
	@ShowAllAuthors BIT = 1, -- gleda se filtriranje autora po modulu ili portalu
	@FilterByAuthor INT = 0,
	@FilterByGroupID INT = 0,
	@FilterByTags BIT = 0,
	@FilterByArticles BIT = 0, -- ovoga nema tu !!
	@FilterByDNNUserID INT = 0, -- filter by some UserID / not current user ID
	@FilterByDNNGroupID INT = 0, -- filter by DNNGroup/RoleID / not profile GroupID
	@EditOnlyAsOwner BIT = 0, -- news settings
	@UserCanApprove BIT = 0, -- news settings
	@LocaleCode NVARCHAR(20) = NULL,
	@IsSocialInstance BIT = 0,	
	@FirstOrderBy NVARCHAR(20) = '',--'Featured DESC', -- featured articles on top	
	@Perm_ViewAllCategores BIT = 0, -- permission settings View all categories
	@Perm_EditAllCategores BIT = 0, -- permission settings Edit all categories
	@AdminOrSuperUser BIT = 0,
	@CategoryFilterType TINYINT = 1, -- 0 All categories, 1 - SELECTion, 2 - AutoAdd
	@PermissionSettingsSource BIT = 0, -- 0 portal, 1 module
	@FillterSettingsSource BIT = 0, -- 0 portal, 1 module
	@StartDate DATETIME = NULL,
	@OuterModuleID INT = 0,
	@HideUnlocalizedItems BIT = 0,
	@NewsFilterCategories NVARCHAR(1000) = '',
	@NewsFilterAuthors NVARCHAR(1000) = '',
	@NewsFilterGroups NVARCHAR(1000) = '',
	@ListArchive BIT = 0,
	@FilterByTagID INT = NULL,
	@RestrictionByDateRange TINYINT = NULL,
	@AdminFuturePostsVisible BIT = 0
AS
SET NOCOUNT ON;
DECLARE @EditAll TINYINT;

IF @AdminOrSuperUser = 1 OR (@EditOnlyAsOwner = 0 AND @Perm_EditAllCategores = 1) SET @EditAll = 1;
ELSE IF EXISTS(SELECT * FROM dbo.[dnn_EDS_EditPermissions] (@PortalID,@ModuleID,@UserID,@AdminOrSuperUser,@Perm_EditAllCategores,@PermissionSettingsSource,GETUTCDATE())) SET @EditAll = 2;
ELSE SET @EditAll = 3;

DECLARE @sqlcommand NVARCHAR(max);
DECLARE @paramList NVARCHAR(2000);
SET @paramList = N'
	 @PortalID INT
	,@ModuleID INT
	,@UserID INT
	,@OrderBy NVARCHAR(30)
	,@ItemsFrom INT
	,@ItemsTo INT
	,@DateRangeType TINYINT
	,@FromDate DATETIME
	,@ToDate DATETIME
	,@OnlyOneCategory INT
	,@Featured BIT
	,@ShowAllAuthors BIT
	,@FilterByAuthor INT
	,@FilterByGroupID INT
	,@FilterByArticles BIT
	,@FilterByDNNUserID INT
	,@FilterByDNNGroupID INT
	,@EditOnlyAsOwner BIT
	,@UserCanApprove BIT
	,@LocaleCode NVARCHAR(20)
	,@IsSocialInstance BIT
	,@FirstOrderBy NVARCHAR(20)
	,@Perm_ViewAllCategores BIT
	,@Perm_EditAllCategores BIT
	,@AdminOrSuperUser BIT
	,@CategoryFilterType TINYINT
	,@PermissionSettingsSource BIT
	,@FillterSettingsSource BIT
	,@StartDate DATETIME
	,@OuterModuleID INT
	,@HideUnlocalizedItems BIT
	,@NewsFilterCategories NVARCHAR(1000)
	,@NewsFilterAuthors NVARCHAR(1000)
	,@NewsFilterGroups NVARCHAR(1000)
	,@ListArchive BIT
	,@FilterByTagID INT
	,@RestrictionByDateRange TINYINT'
	
SET @sqlcommand = N'
SET NOCOUNT ON;
SET DATEFIRST 1;
DECLARE @CurrentDate DATETIME;
SET @CurrentDate = GETUTCDATE(); '

IF @NewsFilterCategories = ''
BEGIN
	IF @OuterModuleID = 0 AND @FilterByArticles = 1
	SET @sqlcommand = @sqlcommand  + N' 
		DECLARE @FilterArticlesTable TABLE (ArticleID INT NOT NULL PRIMARY KEY);
		IF @FillterSettingsSource = 1 -- -- portal settings
			INSERT INTO @FilterArticlesTable SELECT ArticleID FROM dbo.[dnn_EasyDNNNewsPortalFilterByArticles] WHERE FilterPortalID = @PortalID;
		ELSE
			INSERT INTO @FilterArticlesTable SELECT ArticleID FROM dbo.[dnn_EasyDNNNewsFilterByArticles] WHERE FilterModuleID = @ModuleID; '

	-- temp TABLE contains list of TagIDs to filter -> @FilterTagsTable
	IF @FilterByTagID IS NOT NULL
	BEGIN
		SET @sqlcommand = @sqlcommand  + N'
		DECLARE @FilterTagsTable TABLE (TagID INT NOT NULL PRIMARY KEY);
		INSERT INTO @FilterTagsTable SELECT @FilterByTagID '
		SET @FilterByTags = 1
	END	
	ELSE IF @OuterModuleID = 0 AND @FilterByTags = 1
		SET @sqlcommand = @sqlcommand  + N' 
		DECLARE @FilterTagsTable TABLE (TagID INT NOT NULL PRIMARY KEY);
		IF @FillterSettingsSource = 1 -- portal settings
			INSERT INTO @FilterTagsTable SELECT TagID FROM dbo.[dnn_EasyDNNNewsPortalFilterByTagID] WHERE FilterPortalID = @PortalID;
		ELSE
			INSERT INTO @FilterTagsTable SELECT TagID FROM dbo.[dnn_EasyDNNNewsFilterByTagID] WHERE FilterModuleID = @ModuleID; '
END

SET @sqlcommand = @sqlcommand  + N' 

IF OBJECT_ID(''tempdb..#UserInRoles'') IS NOT NULL
	DROP TABLE #UserInRoles;
	
CREATE TABLE #UserInRoles (RoleID INT NOT NULL PRIMARY KEY);
IF @UserID <> -1
INSERT INTO #UserInRoles SELECT DISTINCT r.[RoleID] FROM dbo.[dnn_Roles] AS r INNER JOIN dbo.[dnn_UserRoles] AS ur ON ur.RoleID = r.RoleID WHERE ur.UserID = @UserID AND r.PortalID = @PortalID AND ( ur.ExpiryDate IS NULL OR ur.ExpiryDate > @CurrentDate ) AND (ur.EffectiveDate IS NULL OR ur.EffectiveDate < @CurrentDate);

IF OBJECT_ID(''tempdb..#UserViewCategories'') IS NOT NULL
	DROP TABLE #UserViewCategories;

CREATE TABLE #UserViewCategories (CategoryID INT NOT NULL PRIMARY KEY);
INSERT INTO #UserViewCategories SELECT CategoryID FROM dbo.[dnn_EDS_ViewPermissions] (@PortalID,@ModuleID,@UserID,@AdminOrSuperUser,@Perm_ViewAllCategores,@PermissionSettingsSource,@CurrentDate) '

IF @EditAll = 2
SET @sqlcommand = @sqlcommand  + N' 

IF OBJECT_ID(''tempdb..#UserEditCategories'') IS NOT NULL
	DROP TABLE #UserEditCategories;

CREATE TABLE #UserEditCategories (CategoryID INT NOT NULL PRIMARY KEY);
INSERT INTO #UserEditCategories SELECT CategoryID FROM dbo.[dnn_EDS_EditPermissions] (@PortalID,@ModuleID,@UserID,@AdminOrSuperUser,@Perm_EditAllCategores,@PermissionSettingsSource,@CurrentDate) '

SET @sqlcommand = @sqlcommand  + N'

IF OBJECT_ID(''tempdb..#UserViewCategoriesWithFilter'') IS NOT NULL
	DROP TABLE #UserViewCategoriesWithFilter;

CREATE TABLE #UserViewCategoriesWithFilter (CategoryID INT NOT NULL PRIMARY KEY);

IF OBJECT_ID(''tempdb..#FiltredByCategories'') IS NOT NULL
	DROP TABLE #FiltredByCategories;

CREATE TABLE #FiltredByCategories (CategoryID INT NOT NULL PRIMARY KEY); '

IF @NewsFilterCategories <> ''
BEGIN
	SET @sqlcommand = @sqlcommand  + N'
	INSERT INTO #FiltredByCategories SELECT fc.KeyID FROM dbo.[dnn_EDS_StringListToTable](@NewsFilterCategories) AS fc
	INSERT INTO #UserViewCategoriesWithFilter SELECT [CategoryID] FROM #UserViewCategories WHERE CategoryID IN (SELECT CAtegoryID FROM #FiltredByCategories); '
END
ELSE
BEGIN
	IF @OnlyOneCategory IS NOT NULL -- filtrira se po jednoj kategoriji
	BEGIN
		SET @sqlcommand = @sqlcommand  + N'
		INSERT INTO #UserViewCategoriesWithFilter SELECT [CategoryID] FROM #UserViewCategories WHERE CategoryID = @OnlyOneCategory;
		INSERT INTO #FiltredByCategories SELECT @OnlyOneCategory; '
	END
	ELSE IF @OuterModuleID <> 0
	BEGIN
		IF @CategoryFilterType = 0 -- 0 All categories
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			INSERT INTO #UserViewCategoriesWithFilter SELECT [CategoryID] FROM #UserViewCategories;
			INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
		END
		ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			INSERT INTO #UserViewCategoriesWithFilter 
			SELECT cl.[CategoryID] FROM #UserViewCategories AS cl
			INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @OuterModuleID
				
			INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID; '
		END
		ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			WITH hierarchy AS(
				SELECT [CategoryID], [ParentCategory]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @OuterModuleID)) AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID], c.[ParentCategory]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
				)
			INSERT INTO #FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
			INSERT INTO #UserViewCategoriesWithFilter SELECT CategoryID FROM #UserViewCategories WHERE CategoryID IN (SELECT CategoryID FROM #FiltredByCategories); '
		END
	END
	ELSE
	BEGIN
		IF @CategoryFilterType = 0 -- 0 All categories
		BEGIN
			SET @sqlcommand = @sqlcommand  + N' 
			INSERT INTO #UserViewCategoriesWithFilter SELECT [CategoryID] FROM #UserViewCategories;
			INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE PortalID = @PortalID; '
		END
		ELSE IF @CategoryFilterType = 1 -- 1 - SELECTion
		BEGIN
			IF @FillterSettingsSource = 1 -- portal
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				INSERT INTO #UserViewCategoriesWithFilter 
				SELECT cl.[CategoryID] FROM #UserViewCategories AS cl
				INNER JOIN dbo.[dnn_EasyDNNNewsPortalCategoryItems] AS pci ON pci.CategoryID = cl.CategoryID AND pci.PortalID = @PortalID
				
				INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID; '
			END
			ELSE -- module
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				INSERT INTO #UserViewCategoriesWithFilter 
				SELECT cl.[CategoryID] FROM #UserViewCategories AS cl
				INNER JOIN dbo.[dnn_EasyDNNNewsModuleCategoryItems] AS mci ON mci.CategoryID = cl.CategoryID AND mci.ModuleID = @ModuleID
				
				INSERT INTO #FiltredByCategories SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID; '
			END
		END
		ELSE IF @CategoryFilterType = 2 -- 2 - AutoAdd
		BEGIN
			IF @FillterSettingsSource = 1 -- portal
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				WITH hierarchy AS(
					SELECT [CategoryID], [ParentCategory]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
					WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsPortalCategoryItems] WHERE PortalID = @PortalID)) AND PortalID = @PortalID
					UNION ALL
					SELECT c.[CategoryID], c.[ParentCategory]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
					)
				INSERT INTO #FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
				INSERT INTO #UserViewCategoriesWithFilter SELECT CategoryID FROM #UserViewCategories WHERE CategoryID IN (SELECT CategoryID FROM #FiltredByCategories); '
			END
			ELSE -- module
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				WITH hierarchy AS(
					SELECT [CategoryID], [ParentCategory]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
					WHERE (cl.ParentCategory IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID) OR cl.CategoryID IN (SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID)) AND PortalID = @PortalID
					UNION ALL
					SELECT c.[CategoryID], c.[ParentCategory]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
					)
				INSERT INTO #FiltredByCategories SELECT DISTINCT CategoryID FROM hierarchy;	
				INSERT INTO #UserViewCategoriesWithFilter SELECT CategoryID FROM #UserViewCategories WHERE CategoryID IN (SELECT CategoryID FROM #FiltredByCategories); '
			END
		END
	END
END

DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;

IF @NewsFilterAuthors = '' AND @NewsFilterGroups = ''
BEGIN
	IF @IsSocialInstance = 1
	BEGIN
		IF @FilterByDNNGroupID <> 0
			IF @FilterByAuthor <> 0
				SET @FilterAuthorOrAuthors = 1;
	END
	ELSE
	BEGIN
		IF @OuterModuleID <> 0 AND @ShowAllAuthors = 0
			SET @FilterAuthorOrAuthors = 1;
		ELSE
		BEGIN
		IF @FilterByAuthor = 0 AND @FilterByGroupID = 0 AND @ShowAllAuthors = 0
			SET @FilterAuthorOrAuthors = 1;	
		ELSE IF @FilterByAuthor <> 0
			SET @FilterAuthorOrAuthors = 1;
		ELSE IF @FilterByGroupID <> 0
			SET @FilterAuthorOrAuthors = 1;
		END
	END
END
ELSE
	SET @FilterAuthorOrAuthors = 1;

SET @sqlcommand = @sqlcommand  + N'
DECLARE @FilterBySocialGroup BIT;
SET @FilterBySocialGroup = 0;
DECLARE @FilterAuthorOrAuthors BIT;
SET @FilterAuthorOrAuthors = 0;

DECLARE @TempAuthorsIDList TABLE (UserID INT NOT NULL PRIMARY KEY); '

IF @NewsFilterAuthors = '' AND @NewsFilterGroups = ''
BEGIN
	IF @IsSocialInstance = 1
	BEGIN
		IF @FilterByDNNGroupID <> 0
		BEGIN
			SET @sqlcommand = @sqlcommand  + N' 
			SET @FilterBySocialGroup = 1;
			IF @FilterByAuthor <> 0
			BEGIN
				SET @FilterAuthorOrAuthors = 1;
				INSERT INTO @TempAuthorsIDList SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] WHERE [AuthorProfileID] = @FilterByAuthor;
			END '
		END
	END
	ELSE
	BEGIN
		-- ovaj dio odnosi se na filtriranje autora
		IF @OuterModuleID <> 0 AND @ShowAllAuthors = 0 -- filter iz other modula
		BEGIN
			SET @sqlcommand = @sqlcommand  + N'
			SET @FilterAuthorOrAuthors = 1;
			INSERT INTO @TempAuthorsIDList
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @OuterModuleID
				UNION 
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
					INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
					INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
				WHERE mgi.ModuleID = @OuterModuleID '
		END
		ELSE
		BEGIN
			IF @FilterByAuthor = 0 AND @FilterByGroupID = 0 AND @ShowAllAuthors = 0 -- filter glavnog newsa
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				SET @FilterAuthorOrAuthors = 1;
				IF @FillterSettingsSource = 1 -- by portal
				BEGIN
					INSERT INTO @TempAuthorsIDList
					SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsPortalAuthorsItems] AS pai WHERE pai.PortalID = @PortalID
					UNION 
					SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
						INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
						INNER JOIN dbo.[dnn_EasyDNNNewsPortalGroupItems] AS pgi ON pgi.GroupID = agi.GroupID
						WHERE pgi.PortalID = @PortalID
				END
				ELSE -- by modul
				BEGIN
					INSERT INTO @TempAuthorsIDList
					SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsModuleAuthorsItems] AS mai WHERE mai.ModuleID = @ModuleID
					UNION 
					SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
						INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID
						INNER JOIN dbo.[dnn_EasyDNNNewsModuleGroupItems] AS mgi ON mgi.GroupID = agi.GroupID
						WHERE mgi.ModuleID = @ModuleID
				END '
			END
			ELSE IF @FilterByAuthor <> 0
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				SET @FilterAuthorOrAuthors = 1;
				INSERT INTO @TempAuthorsIDList SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] WHERE [AuthorProfileID] = @FilterByAuthor; '
			END
			ELSE IF @FilterByGroupID <> 0
			BEGIN
				SET @sqlcommand = @sqlcommand  + N' 
				SET @FilterAuthorOrAuthors = 1;
				INSERT INTO @TempAuthorsIDList
				SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
					INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID	
					WHERE agi.GroupID = @FilterByGroupID '
			END
		END
	END
END
ELSE
BEGIN
	-- treba selektirati sve autore ili grupe !!!
	SET @FilterAuthorOrAuthors = 1;
	IF @NewsFilterAuthors <> '' AND @NewsFilterGroups <> ''
		SET @sqlcommand = @sqlcommand  + N' 
		INSERT INTO @TempAuthorsIDList
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterAuthors) AS af ON ap.AuthorProfileID = af.KeyID WHERE PortalID = @PortalID
		UNION
		SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterGroups) AS a ON a.KeyID = agi.GroupID	
		WHERE ap.PortalID = @PortalID '
	ELSE IF @NewsFilterAuthors <> ''
		SET @sqlcommand = @sqlcommand  + N' 
		INSERT INTO @TempAuthorsIDList SELECT [UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterAuthors) AS af ON ap.AuthorProfileID = af.KeyID WHERE PortalID = @PortalID '
	ELSE IF @NewsFilterGroups <> ''
		SET @sqlcommand = @sqlcommand  + N' 
		INSERT INTO @TempAuthorsIDList
		SELECT ap.[UserID] FROM dbo.[dnn_EasyDNNNewsAuthorProfile] AS ap 
			INNER JOIN dbo.[dnn_EasyDNNNewsAutorGroupItems] AS agi ON ap.AuthorProfileID = agi.AuthorProfileID INNER JOIN dbo.[dnn_EDS_StringListToTable](@NewsFilterGroups) AS a ON a.KeyID = agi.GroupID	
		WHERE ap.PortalID = @PortalID '
END

SET @sqlcommand = @sqlcommand  + N' 
IF OBJECT_ID(''tempdb..#LocalizedCategories'') IS NOT NULL
	DROP TABLE #LocalizedCategories;
	
CREATE TABLE #LocalizedCategories (ID INT NOT NULL PRIMARY KEY, Name NVARCHAR(200), Position INT, CategoryURL NVARCHAR(1500)); '
IF @LocaleCode IS NOT NULL
BEGIN
	SET @sqlcommand = @sqlcommand  + N' 
	WITH LocCategories(ID, Name, Position, CategoryURL) AS (
		SELECT Cat.CategoryID AS ID, cl.Title AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN #UserViewCategories AS uvc ON uvc.CategoryID = Cat.CategoryID INNER JOIN dbo.[dnn_EasyDNNNewsCategoryLocalization] AS cl ON uvc.CategoryID = cl.CategoryID WHERE Cat.PortalID = @PortalID AND cl.LocaleCode = @LocaleCode
	),
	NotLocCategories(ID, Name, Position, CategoryURL) AS (
		SELECT Cat.CategoryID AS ID, Cat.CategoryName AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat INNER JOIN #UserViewCategories AS uvc ON uvc.CategoryID = Cat.CategoryID WHERE Cat.PortalID = @PortalID AND Cat.CategoryID NOT IN (SELECT ID FROM LocCategories)
	)
	INSERT INTO #LocalizedCategories SELECT ID, Name, Position, CategoryURL FROM (SELECT ID, Name, Position, CategoryURL FROM LocCategories UNION ALL SELECT ID, Name, Position, CategoryURL FROM NotLocCategories) AS ArticleCategories '
END
ELSE
BEGIN
	SET @sqlcommand = @sqlcommand  + N' 
	INSERT INTO #LocalizedCategories SELECT Cat.CategoryID AS ID, Cat.CategoryName AS Name, Cat.Position, Cat.CategoryURL FROM dbo.[dnn_EasyDNNNewsCategoryList] AS Cat WHERE Cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategories) AND Cat.PortalID = @PortalID '
END

SET @sqlcommand = @sqlcommand  + N'
;WITH MainFilters AS(
	SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na
		INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #FiltredByCategories) '

		IF @HideUnlocalizedItems = 1 SET @sqlcommand = @sqlcommand  + N' INNER JOIN dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl ON ncl.ArticleID = na.ArticleID AND ncl.LocaleCode = @LocaleCode '
		IF @FilterByDNNGroupID <> 0 
			SET @sqlcommand = @sqlcommand  + N'
			INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
			INNER JOIN dbo.[dnn_EasyDNNNewsSocialGroupItems] AS sgi ON sgi.ArticleID = na.ArticleID AND sgi.RoleID = @FilterByDNNGroupID
			INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '
		ELSE IF @FilterByDNNUserID <> 0
			SET @sqlcommand = @sqlcommand  + N'
			INNER JOIN dbo.[dnn_EasyDNNNewsSocialSecurity] AS nss ON nss.ArticleID = na.ArticleID
			INNER JOIN dbo.[dnn_Journal_User_Permissions](@PortalId,@UserID, @FilterByDNNGroupID) AS t ON t.seckey = nss.SecurityKey '

		IF @FilterByTags = 1 SET @sqlcommand = @sqlcommand  + N' INNER JOIN dbo.[dnn_EasyDNNNewsTagsItems] AS ti ON na.ArticleID = ti.ArticleID INNER JOIN @FilterTagsTable AS fbt ON ti.TagID = fbt.TagID '
		IF @FilterByArticles = 1 SET @sqlcommand = @sqlcommand  + N' INNER JOIN @FilterArticlesTable AS fba ON fba.ArticleID = na.ArticleID '
	SET @sqlcommand = @sqlcommand  + N'
	WHERE na.PortalID=@PortalID
		AND na.EventArticle = 1 '
		IF @AdminFuturePostsVisible = 1
		BEGIN
			IF @RestrictionByDateRange IS NOT NULL SET @sqlcommand = @sqlcommand  + N' AND na.PublishDate >= DATEADD(day,-@RestrictionByDateRange,@CurrentDate) AND na.[ExpireDate] >= @CurrentDate '
			ELSE SET @sqlcommand = @sqlcommand  + N' AND @CurrentDate <= na.[ExpireDate] '		
		END
		ELSE IF @RestrictionByDateRange IS NOT NULL SET @sqlcommand = @sqlcommand  + N' AND na.PublishDate BETWEEN DATEADD(day,-@RestrictionByDateRange,@CurrentDate) AND @CurrentDate AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		ELSE SET @sqlcommand = @sqlcommand  + N' AND @CurrentDate BETWEEN na.PublishDate AND na.[ExpireDate] '
		
		IF @LocaleCode IS NULL SET @sqlcommand = @sqlcommand  + N' AND na.HideDefaultLocale = 0 '
		IF @Featured = 1 SET @sqlcommand = @sqlcommand  + N' AND na.Featured = 1 '
		IF @FilterByDNNUserID <> 0 SET @sqlcommand = @sqlcommand  + N' AND na.UserID = @FilterByDNNUserID '
		ELSE IF @FilterAuthorOrAuthors = 1 SET @sqlcommand = @sqlcommand  + N' AND na.UserID IN (SELECT UserID FROM @TempAuthorsIDList) '
	SET @sqlcommand = @sqlcommand  + N'
),
AllContent AS(
	SELECT n.ArticleID,
		CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END AS StartDate,
		CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS RecurringID
	FROM dbo.[dnn_EasyDNNNews] AS n
	INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
	LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON ned.ArticleID = nerd.ArticleID AND ned.Recurring = 1 AND '
	IF @DateRangeType = 2
		SET @sqlcommand = @sqlcommand  + N'
		((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
			 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ned.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime))) '
	ELSE IF @DateRangeType = 1
		BEGIN
			IF @ListArchive = 0
				SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate '
			ELSE
				SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @CurrentDate AND nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate AND nerd.EndDateTime < @CurrentDate '
		END
	ELSE IF @DateRangeType = 0
		SET @sqlcommand = @sqlcommand  + N' (nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ned.UpcomingOccurrences IS NULL THEN 1 ELSE ned.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ned.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)) '
	ELSE SET @sqlcommand = @sqlcommand  + N' 1 = 0'
		SET @sqlcommand = @sqlcommand  + N'
	 WHERE n.ArticleID IN(
		SELECT [ArticleID] FROM (
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 0
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategoriesWithFilter)	
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
			WHERE na.HasPermissions = 0
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
				AND ne.Recurring = 0 '
				IF @EditAll <> 1
				BEGIN
					SET @sqlcommand = @sqlcommand  + N' AND (na.Active = 1 OR na.UserID = @UserID) '
					IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N' AND na.Approved = 1 '
				END
				IF @DateRangeType = 1
				BEGIN
					IF @ListArchive = 0
						SET @sqlcommand = @sqlcommand  + N' AND ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate '
					ELSE
						SET @sqlcommand = @sqlcommand  + N' AND ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate AND ne.EndDate < @CurrentDate '
				END
				ELSE IF @DateRangeType = 2
					SET @sqlcommand = @sqlcommand  + N' AND (ne.StartDate >= @StartDate OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
				SET @sqlcommand = @sqlcommand  + N'
			UNION ALL
			SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 0 AND Recurring 1
				INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS cat ON na.ArticleID = cat.ArticleID AND cat.CategoryID IN (SELECT CategoryID FROM #UserViewCategoriesWithFilter)	
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
				INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND '
			IF @DateRangeType = 2
				SET @sqlcommand = @sqlcommand  + N'
				((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
					 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime))) '
			ELSE IF @DateRangeType = 1
				BEGIN
					IF @ListArchive = 0
						SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate '
					ELSE
						SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @CurrentDate AND nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate AND nerd.EndDateTime < @CurrentDate '
				END
			ELSE IF @DateRangeType = 0
				SET @sqlcommand = @sqlcommand  + N' (nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)) '
			ELSE SET @sqlcommand = @sqlcommand  + N' 1 = 0 '
			SET @sqlcommand = @sqlcommand  + N'
			WHERE na.HasPermissions = 0
				AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
				AND ne.Recurring = 1 '
				IF @EditAll <> 1
				BEGIN
					SET @sqlcommand = @sqlcommand  + N' AND (na.Active = 1 OR na.UserID = @UserID) '
					IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N' AND na.Approved = 1 '
				END
			SET @sqlcommand = @sqlcommand  + N'
		) AS HasPermissionsFalse
		UNION ALL
		SELECT [ArticleID] FROM (
			SELECT [ArticleID] FROM (
				SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND UserPermissions AND Recurring 0
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0
				WHERE na.HasPermissions = 1
					AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
					AND ne.Recurring = 0 '
				IF @EditAll <> 1
				BEGIN
					SET @sqlcommand = @sqlcommand  + N' AND (na.Active = 1 OR na.UserID=@UserID) AND aup.Show = 1 '
					IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N' AND na.Approved = 1 '
					IF @UserID = -1 SET @sqlcommand = @sqlcommand  + N' AND aup.UserID IS NULL '
					ELSE SET @sqlcommand = @sqlcommand  + N' AND aup.UserID = @UserID '
				END
				IF @DateRangeType = 1
				BEGIN
					IF @ListArchive = 0
						SET @sqlcommand = @sqlcommand  + N' AND ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate '
					ELSE
						SET @sqlcommand = @sqlcommand  + N' AND ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate AND ne.EndDate < @CurrentDate '
				END
				ELSE IF @DateRangeType = 2
					SET @sqlcommand = @sqlcommand  + N' AND (ne.StartDate >= @StartDate OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
				SET @sqlcommand = @sqlcommand  + N'
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND RolePermissions AND Recurring 0
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 0	
				WHERE na.HasPermissions = 1
					AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
					AND ne.Recurring = 0 '
				IF @EditAll <> 1
				BEGIN
					SET @sqlcommand = @sqlcommand  + N' AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles) '
					IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N' AND na.Approved = 1 '
				END
				IF @DateRangeType = 1
				BEGIN
					IF @ListArchive = 0
						SET @sqlcommand = @sqlcommand  + N' AND ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate '
					ELSE
						SET @sqlcommand = @sqlcommand  + N' AND ne.StartDate <= @ToDate AND ne.EndDate >= @FromDate AND ne.EndDate < @CurrentDate '
				END
				ELSE IF @DateRangeType = 2
					SET @sqlcommand = @sqlcommand  + N' AND (ne.StartDate >= @StartDate OR (ne.StartDate < @StartDate AND ne.EndDate >= @StartDate)) '
				SET @sqlcommand = @sqlcommand  + N'
			) AS NotRecurring
			UNION ALL
			SELECT [ArticleID] FROM (
				SELECT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND UserPermissions AND Recurring 1
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup ON na.ArticleID = aup.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND '
				IF @DateRangeType = 2
					SET @sqlcommand = @sqlcommand  + N'
					((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime))) '
				ELSE IF @DateRangeType = 1
					BEGIN
						IF @ListArchive = 0
							SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate '
						ELSE
							SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @CurrentDate AND nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate AND nerd.EndDateTime < @CurrentDate '
					END
				ELSE IF @DateRangeType = 0
					SET @sqlcommand = @sqlcommand  + N' (nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)) '
				ELSE SET @sqlcommand = @sqlcommand  + N' 1 = 0 '
				SET @sqlcommand = @sqlcommand  + N'
				WHERE na.HasPermissions = 1
					AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
					AND ne.Recurring = 1 '
				IF @EditAll <> 1
				BEGIN
					SET @sqlcommand = @sqlcommand  + N' AND (na.Active = 1 OR na.UserID=@UserID) AND aup.Show = 1 '
					IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N' AND na.Approved = 1 '
					IF @UserID = -1 SET @sqlcommand = @sqlcommand  + N' AND aup.UserID IS NULL '
					ELSE SET @sqlcommand = @sqlcommand  + N' AND aup.UserID = @UserID '
				END
				SET @sqlcommand = @sqlcommand  + N' 
				UNION
				SELECT DISTINCT na.[ArticleID] FROM dbo.[dnn_EasyDNNNews] AS na -- EV 1 AND HasPermissions 1 AND RolePermissions AND Recurring 0
					INNER JOIN dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp ON na.ArticleID = arp.ArticleID
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ne ON ne.ArticleID = na.ArticleID AND ne.Recurring = 1
					INNER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] as nerd ON ne.ArticleID = nerd.ArticleID AND ne.Recurring = 1 AND '
				IF @DateRangeType = 2
					SET @sqlcommand = @sqlcommand  + N'
					((nerd.StartDateTime <= @CurrentDate AND ((nerd.StartDateTime >= @StartDate) OR (nerd.StartDateTime < @StartDate AND nerd.EndDateTime >= @StartDate)))
						 OR (nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) erd.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS erd WHERE erd.ArticleID = ne.ArticleID AND erd.StartDateTime > @CurrentDate ORDER BY erd.StartDateTime))) '
				ELSE IF @DateRangeType = 1
					BEGIN
						IF @ListArchive = 0
							SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate '
						ELSE
							SET @sqlcommand = @sqlcommand  + N' nerd.StartDateTime <= @CurrentDate AND nerd.StartDateTime <= @ToDate AND nerd.EndDateTime >= @FromDate AND nerd.EndDateTime < @CurrentDate '
					END
				ELSE IF @DateRangeType = 0
					SET @sqlcommand = @sqlcommand  + N' (nerd.StartDateTime <= @CurrentDate OR nerd.RecurringID IN (SELECT TOP(CASE WHEN ne.UpcomingOccurrences IS NULL THEN 1 ELSE ne.UpcomingOccurrences END) nerdInner.RecurringID FROM dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerdInner WHERE nerdInner.ArticleID = ne.ArticleID AND nerdInner.StartDateTime > @CurrentDate ORDER BY nerdInner.StartDateTime)) '
				ELSE SET @sqlcommand = @sqlcommand  + N' 1 = 0 '
				SET @sqlcommand = @sqlcommand  + N'
				WHERE na.HasPermissions = 1
					AND na.ArticleID IN (SELECT ArticleID FROM MainFilters)
					AND ne.Recurring = 1 '
				IF @EditAll <> 1
				BEGIN
					SET @sqlcommand = @sqlcommand  + N' AND (na.Active = 1 OR na.UserID=@UserID) AND arp.Show = 1 AND arp.RoleID IN (SELECT [RoleID] FROM #UserInRoles) '
					IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N' AND na.Approved = 1 '
				END
				SET @sqlcommand = @sqlcommand  + N' 
			) AS Recurring
		) AS HasPermissionsTrue			
	)
),
AllCount AS (
	SELECT COUNT(ArticleID) AS ContentCount FROM AllContent
)'

IF @LocaleCode IS NOT NULL
BEGIN
	SET @sqlcommand = @sqlcommand  + N'	
	, FinalArticleIDsSet (ArticleID,StartDate,RecurringID) AS(
			SELECT TOP (@ItemsTo - @ItemsFrom + 1) ArticleID,StartDate,RecurringID FROM (
				SELECT *, ROW_NUMBER() OVER (ORDER BY '
				IF @FirstOrderBy = 'Featured DESC' SET @sqlcommand = @sqlcommand  + N'Featured DESC, '
				SET @sqlcommand = @sqlcommand  + @OrderBy + N') AS Kulike
				FROM (
					SELECT n.ArticleID,n.Featured,n.PublishDate,n.NumberOfViews,n.RatingValue,n.DateAdded,n.ExpireDate,n.LastModified,n.NumberOfComments,n.Title,ac.StartDate,ac.RecurringID
						FROM dbo.[dnn_EasyDNNNews] AS n
						INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID) AS n)
					AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo ORDER BY '
				IF @FirstOrderBy = 'Featured DESC' SET @sqlcommand = @sqlcommand  + N'Featured DESC, '
				SET @sqlcommand = @sqlcommand  + @OrderBy
				
	SET @sqlcommand = @sqlcommand  + N'
	),
	FinalLocalizedArticleIDsSet (ArticleID,RecurringID,Title,SubTitle,Summary,Article,DetailTypeData,TitleLink,MetaDecription,MetaKeywords,MainImageTitle,MainImageDescription) AS(
			SELECT ncl.ArticleID,fais.RecurringID,ncl.Title,ncl.SubTitle,ncl.Summary,ncl.Article,ncl.DetailTypeData,ncl.clTitleLink AS TitleLink ,ncl.MetaDecription,ncl.MetaKeywords,ncl.MainImageTitle,ncl.MainImageDescription
			FROM dbo.[dnn_EasyDNNNewsContentLocalization] AS ncl INNER JOIN FinalArticleIDsSet AS fais ON ncl.ArticleID = fais.ArticleID AND LocaleCode = @LocaleCode
	) '
END

SET @sqlcommand = @sqlcommand  + N'
SELECT *, '

IF @EditAll = 0 SET @sqlcommand = @sqlcommand  + N'0 AS CanEdit, '
ELSE IF @EditAll = 1 SET @sqlcommand = @sqlcommand  + N'1 AS CanEdit, '
ELSE IF @EditAll = 2
BEGIN
	IF @EditOnlyAsOwner = 0
		SET @sqlcommand = @sqlcommand  + N'
			CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM #UserEditCategories))
				THEN 1
				ELSE
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM #UserInRoles))
					THEN 1
					ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
						END
					END
			END AS CanEdit, '
	ELSE
		SET @sqlcommand = @sqlcommand  + N'
			CASE WHEN EXISTS(SELECT CategoryID FROM dbo.[dnn_EasyDNNNewsCategories] AS c WHERE Result.UserID = @UserID AND c.ArticleID = Result.ArticleID AND c.CategoryID IN (SELECT CategoryID FROM #UserEditCategories))
				THEN 1
				ELSE
					CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM #UserInRoles))
					THEN 1
					ELSE
						CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
							THEN 1
							ELSE 0
						END
					END 
			END AS CanEdit, '
END
ELSE IF @EditAll = 3
BEGIN
	IF @EditOnlyAsOwner = 0
		SET @sqlcommand = @sqlcommand  + N'
			CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM #UserInRoles))
			THEN 1
			ELSE
				CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
					THEN 1
					ELSE 0
				END
			END AS CanEdit, '
	ELSE
		SET @sqlcommand = @sqlcommand  + N'
			CASE WHEN EXISTS(SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleRolePermissions] AS arp WHERE arp.ArticleID = Result.ArticleID AND arp.Edit = 1 AND arp.RoleID IN(SELECT RoleID FROM #UserInRoles))
			THEN 1
			ELSE
				CASE WHEN EXISTS (SELECT [ArticleID] FROM dbo.[dnn_EasyDNNNewsArticleUserPermissions] AS aup WHERE aup.ArticleID = Result.ArticleID AND aup.Edit = 1 AND aup.UserID = @UserID)
					THEN 1
					ELSE 0
				END
			END AS CanEdit, '
END
ELSE SET @sqlcommand = @sqlcommand  + N'0 AS CanEdit, '

SET @sqlcommand = @sqlcommand  + N'
(SELECT cat.ID, cat.Name, cat.CategoryURL FROM #LocalizedCategories AS Cat INNER JOIN dbo.[dnn_EasyDNNNewsCategories] AS c ON c.CategoryID = Cat.ID WHERE c.ArticleID = Result.ArticleID ORDER BY Position FOR XML AUTO, ROOT(''root'')) AS CatToShow,
CASE Result.Active
	WHEN 1 THEN 0
	WHEN 0 THEN 1
END AS Published, '
IF @UserCanApprove = 0 SET @sqlcommand = @sqlcommand  + N'0 AS Approve, '
ELSE SET @sqlcommand = @sqlcommand  + N'
		CASE Result.Approved
			WHEN 1 THEN 0
			WHEN 0 THEN Result.Active
		END AS Approve, '
SET @sqlcommand = @sqlcommand  + N'
(SELECT TOP 1 ContentCount FROM AllCount) AS ContentCount
FROM ( '
IF @LocaleCode IS NULL
BEGIN
	SET @sqlcommand = @sqlcommand  + N'
		SELECT *, ROW_NUMBER() OVER (ORDER BY '
		IF @FirstOrderBy = 'Featured DESC' SET @sqlcommand = @sqlcommand  + N'Featured DESC, '

		SET @sqlcommand = @sqlcommand  + @OrderBy + N') AS Kulike
		
		FROM (
		 
		 SELECT
		 n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
		,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
		,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
		,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
		,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
		,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
		 ac.StartDate,
		 ac.RecurringID
		 ,n.[CFGroupeID]
		 FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN AllContent AS ac ON n.ArticleID = ac.ArticleID
		 ) AS innerAllResult ) AS Result WHERE Kulike BETWEEN @ItemsFrom AND @ItemsTo
		 ORDER BY '
		IF @FirstOrderBy = 'Featured DESC' SET @sqlcommand = @sqlcommand  + N'Featured DESC, '
		SET @sqlcommand = @sqlcommand  + @OrderBy
END
ELSE
BEGIN
	SET @sqlcommand = @sqlcommand  + N'
		SELECT n.[ArticleID],n.[UserID],n.[Title],n.[SubTitle],n.[Summary],n.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
				,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
				,n.[TitleLink],n.[DetailType],n.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
				,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
				,n.[ArticleImageSet],n.[MetaDecription],n.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
				,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],n.[MainImageTitle],n.[MainImageDescription],
				 CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END AS StartDate,
				 CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS RecurringID,
				 n.[CFGroupeID]
				FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON n.ArticleID = ned.ArticleID
				INNER JOIN FinalArticleIDsSet AS fais ON ned.ArticleID = fais.ArticleID
				LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON fais.ArticleID = nerd.ArticleID AND nerd.RecurringID = fais.RecurringID
				WHERE n.ArticleID IN (SELECT ArticleID FROM FinalArticleIDsSet WHERE ArticleID NOT IN (SELECT ArticleID FROM FinalLocalizedArticleIDsSet))
			UNION ALL
			SELECT n.[ArticleID],n.[UserID],fla.[Title],fla.[SubTitle],fla.[Summary],fla.[Article],n.[ArticleImage],n.[DateAdded],n.[LastModified],n.[PublishDate]
				,n.[ExpireDate],n.[Approved],n.[Featured],n.[NumberOfViews],n.[RatingValue],n.[RatingCount],n.[AllowComments],n.[Active]
				,fla.[TitleLink],n.[DetailType],fla.[DetailTypeData],n.[DetailsTemplate],n.[DetailsTheme],n.[GalleryPosition],n.[GalleryDisplayType]
				,n.[ShowMainImage],n.[ShowMainImageFront],n.[CommentsTheme],n.[ArticleImageFolder],n.[NumberOfComments]
				,n.[ArticleImageSet],fla.[MetaDecription],fla.[MetaKeywords],n.[DisplayStyle],n.[DetailTarget]
				,n.[ArticleFromRSS],n.[HasPermissions],n.[EventArticle],n.[DetailMediaType],n.[DetailMediaData],n.[AuthorAliasName],n.[ShowGallery],n.[ArticleGalleryID],fla.[MainImageTitle],fla.[MainImageDescription],
				 CASE WHEN ned.Recurring = 1 THEN nerd.StartDateTime ELSE ned.StartDate END AS StartDate,
				 CASE WHEN ned.Recurring = 1 THEN nerd.RecurringID ELSE NULL END AS RecurringID,
				 n.[CFGroupeID]
			FROM dbo.[dnn_EasyDNNNews] AS n INNER JOIN FinalLocalizedArticleIDsSet AS fla ON fla.ArticleID = n.ArticleID 
			INNER JOIN dbo.[dnn_EasyDNNNewsEventsData] AS ned ON fla.ArticleID = ned.ArticleID
			LEFT OUTER JOIN dbo.[dnn_EasyDNNNewsEventsRecurringData] AS nerd ON fla.ArticleID = nerd.ArticleID AND nerd.RecurringID = fla.RecurringID
			) As Result '

	SET @sqlcommand = @sqlcommand  + N' ORDER BY '
		IF @FirstOrderBy = 'Featured DESC' SET @sqlcommand = @sqlcommand  + N'Featured DESC, '
		SET @sqlcommand = @sqlcommand  + @OrderBy
END

SET @sqlcommand = @sqlcommand  + N'
IF OBJECT_ID(''tempdb..#UserInRoles'') IS NOT NULL
	DROP TABLE #UserInRoles;
IF OBJECT_ID(''tempdb..#UserViewCategories'') IS NOT NULL
	DROP TABLE #UserViewCategories;
IF OBJECT_ID(''tempdb..#UserEditCategories'') IS NOT NULL
	DROP TABLE #UserEditCategories;
IF OBJECT_ID(''tempdb..#UserViewCategoriesWithFilter'') IS NOT NULL
	DROP TABLE #UserViewCategoriesWithFilter;
IF OBJECT_ID(''tempdb..#FiltredByCategories'') IS NOT NULL
	DROP TABLE #FiltredByCategories;
IF OBJECT_ID(''tempdb..#LocalizedCategories'') IS NOT NULL
	DROP TABLE #LocalizedCategories; '

exec sp_executesql @statement = @sqlcommand
	,@paramList = @paramList
	,@PortalID = @PortalID
	,@ModuleID = @ModuleID
	,@UserID = @UserID
	,@OrderBy = @OrderBy
	,@ItemsFrom = @ItemsFrom
	,@ItemsTo = @ItemsTo
	,@DateRangeType = @DateRangeType
	,@FromDate = @FromDate
	,@ToDate = @ToDate
	,@OnlyOneCategory = @OnlyOneCategory
	,@Featured = @Featured
	,@ShowAllAuthors = @ShowAllAuthors
	,@FilterByAuthor = @FilterByAuthor
	,@FilterByGroupID = @FilterByGroupID
	,@FilterByArticles = @FilterByArticles
	,@FilterByDNNUserID = @FilterByDNNUserID
	,@FilterByDNNGroupID = @FilterByDNNGroupID
	,@EditOnlyAsOwner = @EditOnlyAsOwner
	,@UserCanApprove = @UserCanApprove
	,@LocaleCode = @LocaleCode
	,@IsSocialInstance = @IsSocialInstance
	,@FirstOrderBy = @FirstOrderBy
	,@Perm_ViewAllCategores = @Perm_ViewAllCategores
	,@Perm_EditAllCategores = @Perm_EditAllCategores
	,@AdminOrSuperUser = @AdminOrSuperUser
	,@CategoryFilterType = @CategoryFilterType
	,@PermissionSettingsSource = @PermissionSettingsSource
	,@FillterSettingsSource = @FillterSettingsSource
	,@StartDate = @StartDate
	,@OuterModuleID = @OuterModuleID
	,@HideUnlocalizedItems = @HideUnlocalizedItems
	,@NewsFilterCategories = @NewsFilterCategories
	,@NewsFilterAuthors = @NewsFilterAuthors
	,@NewsFilterGroups = @NewsFilterGroups
	,@ListArchive = @ListArchive
	,@FilterByTagID = @FilterByTagID
	,@RestrictionByDateRange = @RestrictionByDateRange


﻿CREATE TABLE [dbo].[dnn_EasyDNNNewsChameleonSettings] (
    [Id]                             INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]                       INT             NOT NULL,
    [ModuleID]                       INT             NULL,
    [ArticleID]                      INT             NULL,
    [MainImageWidth]                 INT             NOT NULL,
    [MainImageHeight]                INT             NOT NULL,
    [Template]                       NVARCHAR (150)  NULL,
    [Theme]                          NVARCHAR (50)   NOT NULL,
    [ThemeStyle]                     NVARCHAR (50)   NOT NULL,
    [Responsive]                     BIT             NOT NULL,
    [CSSThemeDisplayStyle]           NVARCHAR (50)   NOT NULL,
    [AudioPlayPlace]                 NVARCHAR (50)   NOT NULL,
    [VideoPlayPlace]                 NVARCHAR (50)   NOT NULL,
    [NothngOnClick]                  BIT             NOT NULL,
    [ShowGalleryTitle]               BIT             NOT NULL,
    [ShowGalleryDescription]         BIT             NOT NULL,
    [ShowNavigation]                 BIT             NOT NULL,
    [ShowPlayPause]                  BIT             NOT NULL,
    [ThumbDirection]                 NVARCHAR (50)   NOT NULL,
    [CategoryDirection]              NVARCHAR (50)   NOT NULL,
    [ThumbPanelInOut]                NVARCHAR (50)   NOT NULL,
    [ThumbPanelLRTB]                 NVARCHAR (50)   NOT NULL,
    [CategoryHeight]                 INT             NOT NULL,
    [CategoryWidth]                  INT             NOT NULL,
    [CategoryY]                      INT             NOT NULL,
    [CategoryX]                      INT             NOT NULL,
    [CategoryInOut]                  NVARCHAR (50)   NOT NULL,
    [CategoryLRTB]                   NVARCHAR (50)   NOT NULL,
    [GalleryCaptionHeight]           INT             NOT NULL,
    [GalleryCaptionWidth]            INT             NOT NULL,
    [GalleryCaptionY]                INT             NOT NULL,
    [GalleryCaptionX]                INT             NOT NULL,
    [GalleryCaptionInOut]            NVARCHAR (50)   NOT NULL,
    [GalleryCaptionLRTB]             NVARCHAR (50)   NOT NULL,
    [CaptionHeight]                  INT             NOT NULL,
    [CaptionWidth]                   INT             NOT NULL,
    [CaptionY]                       INT             NOT NULL,
    [CaptionX]                       INT             NOT NULL,
    [CaptionInOut]                   NVARCHAR (50)   NOT NULL,
    [CaptionLRTB]                    NVARCHAR (50)   NOT NULL,
    [ImapgePanelTopY]                INT             NOT NULL,
    [ImapgePanelTopX]                INT             NOT NULL,
    [ImapgePanelWidth]               INT             NOT NULL,
    [ImapgePanelHeight]              INT             NOT NULL,
    [ThumbPanelWidth]                INT             NOT NULL,
    [ThumbPanelHeight]               INT             NOT NULL,
    [ThumbPanelY]                    INT             NOT NULL,
    [ThumbPanelX]                    INT             NOT NULL,
    [ShowTwitter]                    BIT             NOT NULL,
    [ShowGooglePlus]                 BIT             NOT NULL,
    [ShowFacebook]                   BIT             NOT NULL,
    [NestedSortingType]              NVARCHAR (10)   NOT NULL,
    [NestedSorting]                  NVARCHAR (25)   NOT NULL,
    [SocialSharingButtons]           BIT             NOT NULL,
    [LightboxSocialSharing]          BIT             NOT NULL,
    [LightboxShowPrint]              BIT             NOT NULL,
    [LightboxShowEmail]              BIT             NOT NULL,
    [LightboxType]                   NVARCHAR (25)   NOT NULL,
    [LightboxTitle]                  BIT             NOT NULL,
    [LightboxDescription]            BIT             NOT NULL,
    [LightboxOpacity]                INT             NOT NULL,
    [LightboxPadding]                INT             NOT NULL,
    [OverlayGallery]                 BIT             NOT NULL,
    [ShowTitle]                      BIT             NOT NULL,
    [ShowDescription]                BIT             NOT NULL,
    [ShowMediaTitle]                 BIT             NOT NULL,
    [ShowMediaDescription]           BIT             NOT NULL,
    [ShowMediaTitleThumbnail]        BIT             NOT NULL,
    [OpenMediaUrl]                   BIT             NOT NULL,
    [NewWindow]                      BIT             NOT NULL,
    [ASSInterval]                    INT             NOT NULL,
    [RandomizeMedia]                 BIT             NOT NULL,
    [SSImageWidth]                   DECIMAL (10, 2) NOT NULL,
    [SSImageHeight]                  INT             NOT NULL,
    [SSThumbImageWidth]              INT             NOT NULL,
    [SSThumbImageHeight]             INT             NOT NULL,
    [SliderEffect]                   NVARCHAR (50)   NOT NULL,
    [SSAutoSlide]                    BIT             NOT NULL,
    [SSAutoSlidePause]               NVARCHAR (50)   NOT NULL,
    [OverlayColor]                   BIT             NOT NULL,
    [TGImageWidth]                   INT             NOT NULL,
    [TGImageHeight]                  INT             NOT NULL,
    [TGCSSFile]                      NVARCHAR (50)   NOT NULL,
    [NGShowName]                     BIT             NOT NULL,
    [NGShowdescription]              BIT             NOT NULL,
    [NGThumbWidth]                   INT             NOT NULL,
    [NGThumbHeight]                  INT             NOT NULL,
    [VGSkin]                         NVARCHAR (50)   NOT NULL,
    [PlayOnLoad]                     BIT             NOT NULL,
    [AudioPlayOnLoad]                BIT             NOT NULL,
    [MediaSorting]                   NVARCHAR (25)   NOT NULL,
    [MediaSortingAscType]            NVARCHAR (10)   NOT NULL,
    [UseFlowPlayer]                  BIT             NOT NULL,
    [CategoryHeightResponsive]       BIT             NOT NULL,
    [CategoryWidthResponsive]        BIT             NOT NULL,
    [CategoryYResponsive]            BIT             NOT NULL,
    [CategoryXResponsive]            BIT             NOT NULL,
    [GalleryCaptionHeightResponsive] BIT             NOT NULL,
    [GalleryCaptionWidthResponsive]  BIT             NOT NULL,
    [GalleryCaptionYResponsive]      BIT             NOT NULL,
    [GalleryCaptionXResponsive]      BIT             NOT NULL,
    [CaptionHeightResponsive]        BIT             NOT NULL,
    [CaptionWidthResponsive]         BIT             NOT NULL,
    [CaptionYResponsive]             BIT             NOT NULL,
    [CaptionXResponsive]             BIT             NOT NULL,
    [ImapgePanelTopYResponsive]      BIT             NOT NULL,
    [ImapgePanelTopXResponsive]      BIT             NOT NULL,
    [ImapgePanelWidthResponsive]     BIT             NOT NULL,
    [ImapgePanelHeightResponsive]    BIT             NOT NULL,
    [ThumbPanelWidthResponsive]      BIT             NOT NULL,
    [ThumbPanelHeightResponsive]     BIT             NOT NULL,
    [ThumbPanelYResponsive]          BIT             NOT NULL,
    [ThumbPanelXResponsive]          BIT             NOT NULL,
    [SSImageWidthResponsive]         BIT             NOT NULL,
    [SSImageHeightResponsive]        BIT             NOT NULL,
    [MainImageResizeMode]            INT             NOT NULL,
    [ResponsiveMainImageWidth]       INT             CONSTRAINT [DF_dnn_EasyDNNNewsChameleonSettings_ResponsiveMainImageWidth] DEFAULT ((600)) NOT NULL,
    [GalleryLightbox]                TINYINT         CONSTRAINT [DF_dnn_EasyDNNNewsChameleonSettings_GalleryLightbox] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsChameleonSettings] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsChameleonSettings_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsChameleonSettings_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsChameleonSettings_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsChameleonSettings] UNIQUE NONCLUSTERED ([PortalID] ASC, [ModuleID] ASC, [ArticleID] ASC)
);


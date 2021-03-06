﻿CREATE PROCEDURE [dbo].[dnn_DeleteUserPortal]
	@UserID		int,
	@PortalID   int
AS
	IF @PortalID IS NULL
		BEGIN
			UPDATE dbo.dnn_Users
				SET
					IsDeleted = 1
				WHERE  UserId = @UserID
		END
	ELSE
		BEGIN
			UPDATE dbo.dnn_UserPortals
				SET
					IsDeleted = 1
				WHERE  UserId = @UserID
					AND PortalId = @PortalID
		END


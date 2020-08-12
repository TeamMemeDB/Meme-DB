SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";
CREATE DATABASE IF NOT EXISTS `meme` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `meme`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `AddEdge`$$
CREATE DEFINER=`meme`@`192.168.1.103` PROCEDURE `AddEdge` (IN `pMemeId` INT(10) UNSIGNED, IN `pUserId` BIGINT(22) UNSIGNED, IN `pValue` TINYINT(1) UNSIGNED)  INSERT INTO edge(memeId,userId,Rating) VALUES(pMemeId,pUserId,pValue)
ON DUPLICATE KEY UPDATE Rating = pValue$$

DROP PROCEDURE IF EXISTS `AddMeme`$$
CREATE DEFINER=`meme`@`192.168.1.103` PROCEDURE `AddMeme` (IN `pDiscordOrigin` BIGINT(22) UNSIGNED, IN `pType` VARCHAR(10), IN `pCollectionParent` INT(10) UNSIGNED, IN `pUrl` VARCHAR(255), OUT `MID` INT(10) UNSIGNED)  BEGIN
    IF(NOT EXISTS(SELECT Id FROM meme WHERE Url = pUrl OR OriginalUrl = pUrl)) THEN
        INSERT INTO meme(DiscordOrigin,Type,CollectionParent,Url)
        VALUES(pDiscordOrigin,pType,pCollectionParent,pUrl);
		SELECT LAST_INSERT_ID() INTO MID;
    ELSE
    	SELECT Id INTO MID FROM meme WHERE DiscordOrigin = pDiscordOrigin OR Url = pUrl;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `AddMemeVote`$$
CREATE DEFINER=`meme`@`192.168.1.103` PROCEDURE `AddMemeVote` (IN `pMemeId` INT(10) UNSIGNED, IN `pUserId` BIGINT(22) UNSIGNED, IN `pValue` TINYINT(1))  INSERT INTO memevote(memeId,userId,Value) VALUES(pMemeId,pUserId,pValue)
ON DUPLICATE KEY UPDATE Value=pValue$$

DROP PROCEDURE IF EXISTS `AddUser`$$
CREATE DEFINER=`meme`@`192.168.1.103` PROCEDURE `AddUser` (IN `pId` BIGINT(22) UNSIGNED, IN `pUsername` VARCHAR(32), IN `pDiscrim` INT(4) UNSIGNED, IN `pAvatar` VARCHAR(32))  BEGIN
    IF EXISTS(SELECT Id FROM user WHERE Id = pId) THEN
    	IF pUsername IS NOT NULL THEN
    		UPDATE user SET Username = pUsername, Discriminator = pDiscrim, Avatar = pAvatar WHERE Id = pId;
    	END IF;
    ELSE
		INSERT INTO user(Id,Username,Discriminator)
		VALUES(pId, pUsername, pDiscrim, pAvatar);
	END IF;
END$$

DELIMITER ;

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `categorysuggestion`;
CREATE TABLE `categorysuggestion` (
  `Id` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `categoryvote`;
CREATE TABLE `categoryvote` (
  `categoryId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `CategoryPoints`;
DELIMITER $$
CREATE TRIGGER `CategoryPoints` AFTER INSERT ON `categoryvote` FOR EACH ROW UPDATE user SET Points = Points + 2 WHERE Id = new.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `CategoryPointsUndo`;
DELIMITER $$
CREATE TRIGGER `CategoryPointsUndo` AFTER DELETE ON `categoryvote` FOR EACH ROW UPDATE user SET Points = Points - 2 WHERE Id = old.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `OnSoleCatDownvote_INSERT`;
DELIMITER $$
CREATE TRIGGER `OnSoleCatDownvote_INSERT` AFTER INSERT ON `categoryvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM categoryvote WHERE memeId=NEW.memeId AND categoryId=NEW.categoryId) = -1) THEN
DELETE FROM categoryvote WHERE meme.Id=NEW.memeId AND categoryId=NEW.categoryId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `OnSoleCatDownvote_UPDATE`;
DELIMITER $$
CREATE TRIGGER `OnSoleCatDownvote_UPDATE` AFTER UPDATE ON `categoryvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM categoryvote WHERE memeId=NEW.memeId AND categoryId=NEW.categoryId) = -1) THEN
DELETE FROM categoryvote WHERE meme.Id=NEW.memeId AND categoryId=NEW.categoryId;
END IF
$$
DELIMITER ;

DROP TABLE IF EXISTS `description`;
CREATE TABLE `description` (
  `Id` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `editId` int(10) UNSIGNED DEFAULT NULL,
  `Text` varchar(10000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `DescriptionPoints`;
DELIMITER $$
CREATE TRIGGER `DescriptionPoints` AFTER INSERT ON `description` FOR EACH ROW UPDATE user SET Points = Points + 8 WHERE Id = new.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `DescriptionPointsUndo`;
DELIMITER $$
CREATE TRIGGER `DescriptionPointsUndo` AFTER DELETE ON `description` FOR EACH ROW UPDATE user SET Points = Points - 8 WHERE Id = old.userId
$$
DELIMITER ;

DROP TABLE IF EXISTS `descvote`;
CREATE TABLE `descvote` (
  `descId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `OnSoleDescDownvote_INSERT`;
DELIMITER $$
CREATE TRIGGER `OnSoleDescDownvote_INSERT` AFTER INSERT ON `descvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM descvote WHERE descId=NEW.descId) = -1) THEN
DELETE FROM descvote WHERE descId=NEW.descId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `OnSoleDescDownvote_UPDATE`;
DELIMITER $$
CREATE TRIGGER `OnSoleDescDownvote_UPDATE` AFTER UPDATE ON `descvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM descvote WHERE descId=NEW.descId) = -1) THEN
DELETE FROM descvote WHERE descId=NEW.descId;
END IF
$$
DELIMITER ;

DROP TABLE IF EXISTS `edge`;
CREATE TABLE `edge` (
  `memeId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Rating` tinyint(1) UNSIGNED NOT NULL COMMENT '0=anarchy, 1=edgy, 2=divisive, 3=illegal, 4=admins only'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `EdgePoints`;
DELIMITER $$
CREATE TRIGGER `EdgePoints` AFTER INSERT ON `edge` FOR EACH ROW UPDATE user SET Points = Points + 1 WHERE Id = new.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `EdgePointsUndo`;
DELIMITER $$
CREATE TRIGGER `EdgePointsUndo` AFTER DELETE ON `edge` FOR EACH ROW UPDATE user SET Points = Points - 1 WHERE Id = old.userId
$$
DELIMITER ;

DROP TABLE IF EXISTS `favourites`;
CREATE TABLE `favourites` (
  `userId` bigint(22) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED DEFAULT NULL,
  `dateAdded` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `list`;
CREATE TABLE `list` (
  `listId` int(11) UNSIGNED NOT NULL,
  `userId` bigint(20) UNSIGNED NOT NULL COMMENT 'ID of creator of list',
  `creationDate` datetime NOT NULL DEFAULT current_timestamp(),
  `updateDate` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Name` varchar(50) NOT NULL,
  `Privacy` tinyint(1) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `listmeme`;
CREATE TABLE `listmeme` (
  `listId` int(10) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `meme`;
CREATE TABLE `meme` (
  `Id` int(10) UNSIGNED NOT NULL,
  `DiscordOrigin` bigint(18) DEFAULT NULL,
  `Type` varchar(10) NOT NULL DEFAULT 'unoun',
  `CollectionParent` int(10) UNSIGNED DEFAULT NULL,
  `Url` varchar(255) DEFAULT NULL COMMENT 'Null means the file was taken down',
  `OriginalUrl` varchar(255) DEFAULT NULL,
  `Color` char(7) DEFAULT NULL,
  `Width` smallint(5) UNSIGNED DEFAULT NULL,
  `Height` smallint(5) UNSIGNED DEFAULT NULL,
  `Downloadable` tinyint(1) NOT NULL DEFAULT 1,
  `Hash` char(32) DEFAULT NULL,
  `Date` datetime NOT NULL DEFAULT current_timestamp(),
  `Hidden` tinyint(1) NOT NULL DEFAULT 0,
  `Nsfw` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `OnMeme_DELETE`;
DELIMITER $$
CREATE TRIGGER `OnMeme_DELETE` BEFORE DELETE ON `meme` FOR EACH ROW IF (SELECT COUNT(*) FROM meme WHERE CollectionParent = OLD.Id) > 0 THEN
	INSERT INTO memetodelete(memeId)
    	SELECT Id FROM meme WHERE meme.CollectionParent = OLD.Id;
END IF
$$
DELIMITER ;

DROP TABLE IF EXISTS `memetodelete`;
CREATE TABLE `memetodelete` (
  `memeId` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `memevote`;
CREATE TABLE `memevote` (
  `memeId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `OnSoleDownvote_INSERT`;
DELIMITER $$
CREATE TRIGGER `OnSoleDownvote_INSERT` AFTER INSERT ON `memevote` FOR EACH ROW IF ((SELECT AVG(Value) FROM memevote WHERE memeId=NEW.memeId) = -1) THEN
DELETE FROM meme WHERE meme.Id=NEW.memeId OR meme.CollectionParent=NEW.memeId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `OnSoleDownvote_UPDATE`;
DELIMITER $$
CREATE TRIGGER `OnSoleDownvote_UPDATE` AFTER UPDATE ON `memevote` FOR EACH ROW IF ((SELECT AVG(Value) FROM memevote WHERE memeId=NEW.memeId) = -1) THEN
DELETE FROM meme WHERE meme.Id=NEW.memeId OR meme.CollectionParent=NEW.memeId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `VotePoints`;
DELIMITER $$
CREATE TRIGGER `VotePoints` AFTER INSERT ON `memevote` FOR EACH ROW UPDATE user SET Points = Points + 1 WHERE Id = new.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `VotePointsUndo`;
DELIMITER $$
CREATE TRIGGER `VotePointsUndo` AFTER DELETE ON `memevote` FOR EACH ROW UPDATE user SET Points = Points - 1 WHERE Id = old.userId
$$
DELIMITER ;

DROP TABLE IF EXISTS `report`;
CREATE TABLE `report` (
  `ticket` int(10) UNSIGNED NOT NULL,
  `reporter` bigint(22) UNSIGNED NOT NULL,
  `reportee` bigint(22) UNSIGNED DEFAULT NULL,
  `memeId` int(10) UNSIGNED DEFAULT NULL,
  `descId` int(10) UNSIGNED DEFAULT NULL,
  `transId` int(10) UNSIGNED DEFAULT NULL,
  `tagId` int(10) UNSIGNED DEFAULT NULL,
  `complaint` varchar(2000) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` set('PLACED','NEEDS DETAIL','INVALID','ACKNOWLEDGED','CHANGES MADE') NOT NULL DEFAULT 'PLACED',
  `respondant` bigint(22) UNSIGNED DEFAULT NULL,
  `response` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `tagvote`;
CREATE TABLE `tagvote` (
  `tagId` int(10) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `OnSoleTagDownvote_INSERT`;
DELIMITER $$
CREATE TRIGGER `OnSoleTagDownvote_INSERT` AFTER INSERT ON `tagvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM tagvote WHERE memeId=NEW.memeId AND tagId=NEW.tagId) = -1) THEN
DELETE FROM tagvote WHERE meme.Id=NEW.memeId AND tagId=NEW.tagId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `OnSoleTagDownvote_UPDATE`;
DELIMITER $$
CREATE TRIGGER `OnSoleTagDownvote_UPDATE` AFTER UPDATE ON `tagvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM tagvote WHERE memeId=NEW.memeId AND tagId=NEW.tagId) = -1) THEN
DELETE FROM tagvote WHERE meme.Id=NEW.memeId AND tagId=NEW.tagId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `TagPoints`;
DELIMITER $$
CREATE TRIGGER `TagPoints` AFTER INSERT ON `tagvote` FOR EACH ROW UPDATE user SET Points = Points + 2 WHERE Id = new.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `TagPointsUndo`;
DELIMITER $$
CREATE TRIGGER `TagPointsUndo` AFTER DELETE ON `tagvote` FOR EACH ROW UPDATE user SET Points = Points - 2 WHERE Id = old.userId
$$
DELIMITER ;

DROP TABLE IF EXISTS `transcription`;
CREATE TABLE `transcription` (
  `Id` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED DEFAULT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `editId` int(10) UNSIGNED DEFAULT NULL,
  `Text` varchar(10000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `TranscriptionPoints`;
DELIMITER $$
CREATE TRIGGER `TranscriptionPoints` AFTER INSERT ON `transcription` FOR EACH ROW UPDATE user SET Points = Points + 5 WHERE Id = new.userId
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `TranscriptionPointsUndo`;
DELIMITER $$
CREATE TRIGGER `TranscriptionPointsUndo` AFTER DELETE ON `transcription` FOR EACH ROW UPDATE user SET Points = Points - 5 WHERE Id = old.userId
$$
DELIMITER ;

DROP TABLE IF EXISTS `transvote`;
CREATE TABLE `transvote` (
  `transId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DROP TRIGGER IF EXISTS `OnSoleTransDownvote_INSERT`;
DELIMITER $$
CREATE TRIGGER `OnSoleTransDownvote_INSERT` AFTER INSERT ON `transvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM transvote WHERE transId=NEW.transId) = -1) THEN
DELETE FROM transvote WHERE transId=NEW.transId;
END IF
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `OnSoleTransDownvote_UPDATE`;
DELIMITER $$
CREATE TRIGGER `OnSoleTransDownvote_UPDATE` AFTER UPDATE ON `transvote` FOR EACH ROW IF ((SELECT AVG(Value) FROM transvote WHERE transId=NEW.transId) = -1) THEN
DELETE FROM transvote WHERE transId=NEW.transId;
END IF
$$
DELIMITER ;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `Id` bigint(22) UNSIGNED NOT NULL,
  `Username` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `Discriminator` int(4) UNSIGNED DEFAULT NULL,
  `Avatar` varchar(32) DEFAULT NULL,
  `Admin` tinyint(1) NOT NULL DEFAULT 0,
  `Banned` tinyint(1) NOT NULL DEFAULT 0,
  `FavouritesPrivacy` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `Points` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Cache for discord user auth';

DROP TABLE IF EXISTS `usermessage`;
CREATE TABLE `usermessage` (
  `userId` bigint(22) UNSIGNED NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `title` tinytext NOT NULL,
  `content` varchar(512) NOT NULL,
  `acknowledged` tinyint(1) NOT NULL DEFAULT 0,
  `answer` tinytext DEFAULT NULL COMMENT 'Find a way to encode whatever the response is (if any)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE `category`
  ADD PRIMARY KEY (`Id`);

ALTER TABLE `categorysuggestion`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `UniqueName` (`Name`) USING BTREE,
  ADD KEY `Suggester` (`userId`);

ALTER TABLE `categoryvote`
  ADD UNIQUE KEY `UniqueVote` (`categoryId`,`userId`,`memeId`) USING BTREE,
  ADD KEY `User` (`userId`),
  ADD KEY `Meme` (`memeId`);

ALTER TABLE `description`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `UniqueDesc` (`userId`,`memeId`),
  ADD KEY `MemeDescription` (`memeId`),
  ADD KEY `DescEdit` (`editId`);

ALTER TABLE `descvote`
  ADD UNIQUE KEY `UniqueVote` (`descId`,`userId`),
  ADD KEY `DescVoter` (`userId`);

ALTER TABLE `edge`
  ADD UNIQUE KEY `UniqueVote` (`memeId`,`userId`),
  ADD KEY `EdgeVoter` (`userId`);

ALTER TABLE `favourites`
  ADD UNIQUE KEY `FavouriteMeme` (`memeId`,`userId`) USING BTREE,
  ADD KEY `FavUser` (`userId`),
  ADD KEY `dateAdded` (`dateAdded`);

ALTER TABLE `list`
  ADD PRIMARY KEY (`listId`),
  ADD UNIQUE KEY `ListName` (`userId`,`Name`) USING BTREE;

ALTER TABLE `listmeme`
  ADD UNIQUE KEY `ListMeme` (`listId`,`memeId`),
  ADD KEY `ListsMeme` (`memeId`);

ALTER TABLE `meme`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `UniqueURL` (`Url`),
  ADD UNIQUE KEY `UniqueHash` (`Hash`),
  ADD KEY `MemeType` (`Type`),
  ADD KEY `PubDate` (`Date`),
  ADD KEY `CollectionParent` (`CollectionParent`);

ALTER TABLE `memetodelete`
  ADD KEY `MemePendingDelete` (`memeId`);

ALTER TABLE `memevote`
  ADD UNIQUE KEY `UniqueVote` (`memeId`,`userId`),
  ADD KEY `Voter` (`userId`),
  ADD KEY `memeId` (`memeId`);

ALTER TABLE `report`
  ADD PRIMARY KEY (`ticket`),
  ADD UNIQUE KEY `UniqueReport` (`reporter`,`reportee`,`memeId`,`descId`,`transId`,`tagId`),
  ADD KEY `status` (`status`),
  ADD KEY `date` (`date`),
  ADD KEY `Reportee` (`reportee`),
  ADD KEY `Description` (`descId`),
  ADD KEY `Transcription` (`transId`),
  ADD KEY `Tag` (`tagId`),
  ADD KEY `Respondant` (`respondant`),
  ADD KEY `ReportedMeme` (`memeId`);

ALTER TABLE `tag`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Name` (`Name`);

ALTER TABLE `tagvote`
  ADD UNIQUE KEY `UniqueVote` (`tagId`,`memeId`,`userId`),
  ADD KEY `VoteUser` (`userId`),
  ADD KEY `TagMeme` (`memeId`);

ALTER TABLE `transcription`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `TransAuthor` (`userId`),
  ADD KEY `TransEdit` (`editId`),
  ADD KEY `TransMeme` (`memeId`) USING BTREE;

ALTER TABLE `transvote`
  ADD UNIQUE KEY `UniqueVote` (`transId`,`userId`),
  ADD KEY `userId` (`userId`);

ALTER TABLE `user`
  ADD PRIMARY KEY (`Id`);

ALTER TABLE `usermessage`
  ADD KEY `Alertee` (`userId`);


ALTER TABLE `category`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `categorysuggestion`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `description`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `list`
  MODIFY `listId` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `meme`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `report`
  MODIFY `ticket` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `tag`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `transcription`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `categorysuggestion`
  ADD CONSTRAINT `Suggester` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `categoryvote`
  ADD CONSTRAINT `Category` FOREIGN KEY (`categoryId`) REFERENCES `category` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Meme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `User` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `description`
  ADD CONSTRAINT `DescAuthor` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `DescEdit` FOREIGN KEY (`editId`) REFERENCES `description` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `MemeDescription` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `descvote`
  ADD CONSTRAINT `DescVoter` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `DescriptionVote` FOREIGN KEY (`descId`) REFERENCES `description` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `edge`
  ADD CONSTRAINT `EdgeVoter` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `MemeEdge` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `favourites`
  ADD CONSTRAINT `FavMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `FavUser` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `list`
  ADD CONSTRAINT `ListCreator` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `listmeme`
  ADD CONSTRAINT `List` FOREIGN KEY (`listId`) REFERENCES `list` (`listId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ListsMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `meme`
  ADD CONSTRAINT `CollectionParent` FOREIGN KEY (`CollectionParent`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `memetodelete`
  ADD CONSTRAINT `MemePendingDelete` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `memevote`
  ADD CONSTRAINT `MemeVote` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Voter` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `report`
  ADD CONSTRAINT `Description` FOREIGN KEY (`descId`) REFERENCES `description` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ReportedMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Reportee` FOREIGN KEY (`reportee`) REFERENCES `user` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Reporter` FOREIGN KEY (`reporter`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Respondant` FOREIGN KEY (`respondant`) REFERENCES `user` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Tag` FOREIGN KEY (`tagId`) REFERENCES `tag` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Transcription` FOREIGN KEY (`transId`) REFERENCES `transcription` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE `tagvote`
  ADD CONSTRAINT `TagMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `TagVote` FOREIGN KEY (`tagId`) REFERENCES `tag` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `VoteUser` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `transcription`
  ADD CONSTRAINT `MemeTranscription` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `TransAuthor` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `TransEdit` FOREIGN KEY (`editId`) REFERENCES `transcription` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL;

ALTER TABLE `transvote`
  ADD CONSTRAINT `TransVote` FOREIGN KEY (`transId`) REFERENCES `transcription` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `userId` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `usermessage`
  ADD CONSTRAINT `Alertee` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$
DROP EVENT `PurgeDeadMemes`$$
CREATE DEFINER=`meme`@`localhost` EVENT `PurgeDeadMemes` ON SCHEDULE EVERY 1 DAY STARTS '2020-01-21 23:59:59' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE m
    FROM meme m
    LEFT JOIN memevote v ON m.Id = v.memeId
    WHERE v.memeId IS NULL AND m.CollectionParent IS NULL;
DELETE m
    FROM meme m
    INNER JOIN memetodelete d ON d.memeId = m.Id
    WHERE m.Id = d.memeId;
DELETE FROM memetodelete;
END$$

DELIMITER ;
COMMIT;

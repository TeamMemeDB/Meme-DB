-- phpMyAdmin SQL Dump
-- version 4.9.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 18, 2020 at 05:43 PM
-- Server version: 10.3.22-MariaDB-0+deb10u1-log
-- PHP Version: 7.3.14-1~deb10u1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `meme`
--
CREATE DATABASE IF NOT EXISTS `meme` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `meme`;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `categorysuggestion`
--

DROP TABLE IF EXISTS `categorysuggestion`;
CREATE TABLE `categorysuggestion` (
  `Id` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `categoryvote`
--

DROP TABLE IF EXISTS `categoryvote`;
CREATE TABLE `categoryvote` (
  `categoryId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `categoryvote`
--
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

-- --------------------------------------------------------

--
-- Table structure for table `description`
--

DROP TABLE IF EXISTS `description`;
CREATE TABLE `description` (
  `Id` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `editId` int(10) UNSIGNED DEFAULT NULL,
  `Text` varchar(10000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `descvote`
--

DROP TABLE IF EXISTS `descvote`;
CREATE TABLE `descvote` (
  `descId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `descvote`
--
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

-- --------------------------------------------------------

--
-- Table structure for table `edge`
--

DROP TABLE IF EXISTS `edge`;
CREATE TABLE `edge` (
  `memeId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Rating` tinyint(1) UNSIGNED NOT NULL COMMENT '0=anarchy, 1=edgy, 2=divisive, 3=illegal, 4=admins only'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `favourites`
--

DROP TABLE IF EXISTS `favourites`;
CREATE TABLE `favourites` (
  `userId` bigint(22) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED DEFAULT NULL,
  `dateAdded` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `meme`
--

DROP TABLE IF EXISTS `meme`;
CREATE TABLE `meme` (
  `Id` int(10) UNSIGNED NOT NULL,
  `DiscordOrigin` bigint(18) DEFAULT NULL,
  `Type` varchar(10) NOT NULL DEFAULT 'unoun',
  `CollectionParent` int(10) UNSIGNED DEFAULT NULL,
  `Url` varchar(255) DEFAULT NULL COMMENT 'Null means the file was taken down',
  `OriginalUrl` varchar(255) DEFAULT NULL,
  `Downloadable` bit(1) NOT NULL DEFAULT b'1',
  `Date` datetime NOT NULL DEFAULT current_timestamp(),
  `Hidden` bit(1) NOT NULL DEFAULT b'0',
  `Nsfw` bit(1) NOT NULL DEFAULT b'0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `meme`
--
DROP TRIGGER IF EXISTS `OnMeme_DELETE`;
DELIMITER $$
CREATE TRIGGER `OnMeme_DELETE` BEFORE DELETE ON `meme` FOR EACH ROW IF (SELECT COUNT(*) FROM meme WHERE CollectionParent = OLD.Id) > 0 THEN
	INSERT INTO memetodelete(memeId)
    	SELECT Id FROM meme WHERE meme.CollectionParent = OLD.Id;
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `memetodelete`
--

DROP TABLE IF EXISTS `memetodelete`;
CREATE TABLE `memetodelete` (
  `memeId` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `memevote`
--

DROP TABLE IF EXISTS `memevote`;
CREATE TABLE `memevote` (
  `memeId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `memevote`
--
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

-- --------------------------------------------------------

--
-- Table structure for table `report`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tagvote`
--

DROP TABLE IF EXISTS `tagvote`;
CREATE TABLE `tagvote` (
  `tagId` int(10) UNSIGNED NOT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `tagvote`
--
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

-- --------------------------------------------------------

--
-- Table structure for table `transcription`
--

DROP TABLE IF EXISTS `transcription`;
CREATE TABLE `transcription` (
  `Id` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED DEFAULT NULL,
  `memeId` int(10) UNSIGNED NOT NULL,
  `editId` int(10) UNSIGNED DEFAULT NULL,
  `Text` varchar(10000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `transvote`
--

DROP TABLE IF EXISTS `transvote`;
CREATE TABLE `transvote` (
  `transId` int(10) UNSIGNED NOT NULL,
  `userId` bigint(22) UNSIGNED NOT NULL,
  `Value` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `transvote`
--
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

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `Id` bigint(22) UNSIGNED NOT NULL,
  `Username` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `Discriminator` int(4) UNSIGNED DEFAULT NULL,
  `Admin` bit(1) NOT NULL DEFAULT b'0',
  `Banned` bit(1) NOT NULL DEFAULT b'0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Cache for discord user auth';

-- --------------------------------------------------------

--
-- Table structure for table `usermessage`
--

DROP TABLE IF EXISTS `usermessage`;
CREATE TABLE `usermessage` (
  `userId` bigint(22) UNSIGNED NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `title` tinytext NOT NULL,
  `content` varchar(512) NOT NULL,
  `acknowledged` bit(1) NOT NULL DEFAULT b'0',
  `answer` tinytext DEFAULT NULL COMMENT 'Find a way to encode whatever the response is (if any)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `categorysuggestion`
--
ALTER TABLE `categorysuggestion`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `UniqueName` (`Name`) USING BTREE,
  ADD KEY `Suggester` (`userId`);

--
-- Indexes for table `categoryvote`
--
ALTER TABLE `categoryvote`
  ADD UNIQUE KEY `UniqueVote` (`categoryId`,`userId`,`memeId`) USING BTREE,
  ADD KEY `User` (`userId`),
  ADD KEY `Meme` (`memeId`);

--
-- Indexes for table `description`
--
ALTER TABLE `description`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `UniqueDesc` (`userId`,`memeId`),
  ADD KEY `MemeDescription` (`memeId`),
  ADD KEY `DescEdit` (`editId`);

--
-- Indexes for table `descvote`
--
ALTER TABLE `descvote`
  ADD UNIQUE KEY `UniqueVote` (`descId`,`userId`),
  ADD KEY `DescVoter` (`userId`);

--
-- Indexes for table `edge`
--
ALTER TABLE `edge`
  ADD UNIQUE KEY `UniqueVote` (`memeId`,`userId`),
  ADD KEY `EdgeVoter` (`userId`);

--
-- Indexes for table `favourites`
--
ALTER TABLE `favourites`
  ADD UNIQUE KEY `FavouriteMeme` (`memeId`,`userId`) USING BTREE,
  ADD KEY `FavUser` (`userId`),
  ADD KEY `dateAdded` (`dateAdded`);

--
-- Indexes for table `meme`
--
ALTER TABLE `meme`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `UniqueURL` (`Url`),
  ADD KEY `MemeType` (`Type`),
  ADD KEY `PubDate` (`Date`),
  ADD KEY `CollectionParent` (`CollectionParent`);

--
-- Indexes for table `memetodelete`
--
ALTER TABLE `memetodelete`
  ADD KEY `MemePendingDelete` (`memeId`);

--
-- Indexes for table `memevote`
--
ALTER TABLE `memevote`
  ADD UNIQUE KEY `UniqueVote` (`memeId`,`userId`),
  ADD KEY `Voter` (`userId`),
  ADD KEY `memeId` (`memeId`);

--
-- Indexes for table `report`
--
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

--
-- Indexes for table `tag`
--
ALTER TABLE `tag`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Name` (`Name`);

--
-- Indexes for table `tagvote`
--
ALTER TABLE `tagvote`
  ADD UNIQUE KEY `UniqueVote` (`tagId`,`memeId`,`userId`),
  ADD KEY `VoteUser` (`userId`),
  ADD KEY `TagMeme` (`memeId`);

--
-- Indexes for table `transcription`
--
ALTER TABLE `transcription`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `TransAuthor` (`userId`),
  ADD KEY `TransEdit` (`editId`),
  ADD KEY `TransMeme` (`memeId`) USING BTREE;

--
-- Indexes for table `transvote`
--
ALTER TABLE `transvote`
  ADD UNIQUE KEY `UniqueVote` (`transId`,`userId`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `usermessage`
--
ALTER TABLE `usermessage`
  ADD KEY `Alertee` (`userId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categorysuggestion`
--
ALTER TABLE `categorysuggestion`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `description`
--
ALTER TABLE `description`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `meme`
--
ALTER TABLE `meme`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `report`
--
ALTER TABLE `report`
  MODIFY `ticket` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tag`
--
ALTER TABLE `tag`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transcription`
--
ALTER TABLE `transcription`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categorysuggestion`
--
ALTER TABLE `categorysuggestion`
  ADD CONSTRAINT `Suggester` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `categoryvote`
--
ALTER TABLE `categoryvote`
  ADD CONSTRAINT `Category` FOREIGN KEY (`categoryId`) REFERENCES `category` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Meme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `User` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `description`
--
ALTER TABLE `description`
  ADD CONSTRAINT `DescAuthor` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `DescEdit` FOREIGN KEY (`editId`) REFERENCES `description` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `MemeDescription` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `descvote`
--
ALTER TABLE `descvote`
  ADD CONSTRAINT `DescVoter` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `DescriptionVote` FOREIGN KEY (`descId`) REFERENCES `description` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `edge`
--
ALTER TABLE `edge`
  ADD CONSTRAINT `EdgeVoter` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `MemeEdge` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `favourites`
--
ALTER TABLE `favourites`
  ADD CONSTRAINT `FavMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `FavUser` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `meme`
--
ALTER TABLE `meme`
  ADD CONSTRAINT `CollectionParent` FOREIGN KEY (`CollectionParent`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `memetodelete`
--
ALTER TABLE `memetodelete`
  ADD CONSTRAINT `MemePendingDelete` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `memevote`
--
ALTER TABLE `memevote`
  ADD CONSTRAINT `MemeVote` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Voter` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `report`
--
ALTER TABLE `report`
  ADD CONSTRAINT `Description` FOREIGN KEY (`descId`) REFERENCES `description` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ReportedMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Reportee` FOREIGN KEY (`reportee`) REFERENCES `user` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Reporter` FOREIGN KEY (`reporter`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Respondant` FOREIGN KEY (`respondant`) REFERENCES `user` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Tag` FOREIGN KEY (`tagId`) REFERENCES `tag` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `Transcription` FOREIGN KEY (`transId`) REFERENCES `transcription` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `tagvote`
--
ALTER TABLE `tagvote`
  ADD CONSTRAINT `TagMeme` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `TagVote` FOREIGN KEY (`tagId`) REFERENCES `tag` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `VoteUser` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transcription`
--
ALTER TABLE `transcription`
  ADD CONSTRAINT `MemeTranscription` FOREIGN KEY (`memeId`) REFERENCES `meme` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `TransAuthor` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `TransEdit` FOREIGN KEY (`editId`) REFERENCES `transcription` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `transvote`
--
ALTER TABLE `transvote`
  ADD CONSTRAINT `TransVote` FOREIGN KEY (`transId`) REFERENCES `transcription` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `userId` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `usermessage`
--
ALTER TABLE `usermessage`
  ADD CONSTRAINT `Alertee` FOREIGN KEY (`userId`) REFERENCES `user` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

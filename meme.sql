-- phpMyAdmin SQL Dump
-- version 4.9.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 29, 2020 at 05:10 PM
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
-- Database: `pukekohost`
--
CREATE DATABASE IF NOT EXISTS `pukekohost` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `pukekohost`;

-- --------------------------------------------------------

--
-- Table structure for table `error`
--

DROP TABLE IF EXISTS `error`;
CREATE TABLE `error` (
  `GMSId` int(10) UNSIGNED DEFAULT NULL,
  `GameserverId` int(10) UNSIGNED DEFAULT NULL,
  `TransactionId` int(10) UNSIGNED DEFAULT NULL,
  `DiscordAlert` bigint(22) UNSIGNED DEFAULT NULL,
  `Description` text DEFAULT NULL,
  `Resolved` tinyint(1) NOT NULL DEFAULT 0,
  `ResolutionMessage` tinytext DEFAULT NULL,
  `ResolutionMessageSeen` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `game`
--

DROP TABLE IF EXISTS `game`;
CREATE TABLE `game` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Description` text NOT NULL,
  `Perks` varchar(1000) NOT NULL,
  `API` varchar(255) DEFAULT NULL,
  `Background` varchar(128) DEFAULT NULL,
  `Foreground` varchar(128) DEFAULT NULL,
  `Icon` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gameserver`
--

DROP TABLE IF EXISTS `gameserver`;
CREATE TABLE `gameserver` (
  `Id` int(10) UNSIGNED NOT NULL,
  `GameId` int(10) UNSIGNED NOT NULL,
  `TierId` tinyint(1) UNSIGNED NOT NULL,
  `GMSId` int(10) UNSIGNED NOT NULL,
  `OwnerId` bigint(22) UNSIGNED NOT NULL,
  `GuildId` bigint(22) UNSIGNED DEFAULT NULL COMMENT 'Discord Server Id',
  `ChatId` bigint(22) UNSIGNED DEFAULT NULL COMMENT 'Discord Text Channel',
  `Name` tinytext NOT NULL,
  `Port` smallint(5) UNSIGNED NOT NULL COMMENT 'Must be unique amongst active gameservers in one gms',
  `Active` tinyint(1) NOT NULL DEFAULT 1,
  `Running` tinyint(1) NOT NULL DEFAULT 0,
  `RemainingMinutes` mediumint(9) NOT NULL DEFAULT 0 COMMENT 'Expecting at most 3 months',
  `CurrentPlayers` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `MaxPlayers` tinyint(3) UNSIGNED DEFAULT NULL,
  `LastPoll` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gameserverport`
--

DROP TABLE IF EXISTS `gameserverport`;
CREATE TABLE `gameserverport` (
  `GameId` int(10) UNSIGNED NOT NULL,
  `TierId` tinyint(1) UNSIGNED NOT NULL,
  `Port` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gamesupport`
--

DROP TABLE IF EXISTS `gamesupport`;
CREATE TABLE `gamesupport` (
  `ServerID` int(11) UNSIGNED NOT NULL,
  `GameID` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gametier`
--

DROP TABLE IF EXISTS `gametier`;
CREATE TABLE `gametier` (
  `GameId` int(10) UNSIGNED NOT NULL,
  `TierNumber` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  `Name` varchar(20) NOT NULL,
  `Icon` varchar(255) NOT NULL,
  `TierPerks` varchar(1000) NOT NULL,
  `PriceMultiplier` float(4,2) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gsms`
--

DROP TABLE IF EXISTS `gsms`;
CREATE TABLE `gsms` (
  `Id` int(10) UNSIGNED NOT NULL,
  `Perks` varchar(200) NOT NULL,
  `Specs` varchar(200) NOT NULL,
  `InitRate` decimal(4,2) NOT NULL DEFAULT 0.99 COMMENT 'One time initialization fee',
  `UptimeRate` decimal(4,2) NOT NULL DEFAULT 0.05 COMMENT 'Hourly rate',
  `DomainName` varchar(64) NOT NULL,
  `IPv4` varchar(15) DEFAULT NULL COMMENT '0.0.0.0',
  `IPv6` varchar(39) DEFAULT NULL COMMENT '::1',
  `UpDown` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
CREATE TABLE `transaction` (
  `Id` int(11) UNSIGNED NOT NULL,
  `UserId` int(10) UNSIGNED NOT NULL,
  `ServerId` int(10) UNSIGNED DEFAULT NULL,
  `PayPalId` int(11) UNSIGNED DEFAULT NULL,
  `Balance` decimal(5,2) NOT NULL COMMENT 'Maximum $999 in one transaction',
  `Comment` varchar(255) DEFAULT NULL,
  `TransactionType` enum('topup','serveruptime','serverinit','refund','other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `Id` int(10) UNSIGNED NOT NULL,
  `DiscordId` bigint(22) UNSIGNED DEFAULT NULL,
  `Username` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `Password` varchar(255) DEFAULT NULL,
  `Discriminator` smallint(4) UNSIGNED DEFAULT NULL,
  `Email` tinytext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `userguild`
--

DROP TABLE IF EXISTS `userguild`;
CREATE TABLE `userguild` (
  `userId` bigint(22) UNSIGNED NOT NULL,
  `guildId` bigint(22) UNSIGNED NOT NULL,
  `Pos` tinyint(3) UNSIGNED DEFAULT NULL,
  `guildFolder` bigint(22) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `error`
--
ALTER TABLE `error`
  ADD KEY `TransactionFault` (`TransactionId`),
  ADD KEY `GMSFault` (`GMSId`),
  ADD KEY `GameserverFault` (`GameserverId`);

--
-- Indexes for table `game`
--
ALTER TABLE `game`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Name` (`Name`);

--
-- Indexes for table `gameserver`
--
ALTER TABLE `gameserver`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Name` (`Name`(32)),
  ADD KEY `ServerGame` (`GameId`),
  ADD KEY `ServerGMS` (`GMSId`),
  ADD KEY `ServerOwner` (`OwnerId`),
  ADD KEY `ServerGuild` (`GuildId`);

--
-- Indexes for table `gameserverport`
--
ALTER TABLE `gameserverport`
  ADD UNIQUE KEY `GameId` (`GameId`,`TierId`,`Port`);

--
-- Indexes for table `gamesupport`
--
ALTER TABLE `gamesupport`
  ADD UNIQUE KEY `UniqueGameTier` (`ServerID`,`GameID`) USING BTREE,
  ADD KEY `SupportedGame` (`GameID`);

--
-- Indexes for table `gametier`
--
ALTER TABLE `gametier`
  ADD UNIQUE KEY `GameTier` (`GameId`,`TierNumber`);

--
-- Indexes for table `gsms`
--
ALTER TABLE `gsms`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `PayPalId` (`PayPalId`),
  ADD KEY `TransactionUser` (`UserId`),
  ADD KEY `TransactionServer` (`ServerId`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Email` (`Email`(255)),
  ADD UNIQUE KEY `DiscordId` (`DiscordId`);

--
-- Indexes for table `userguild`
--
ALTER TABLE `userguild`
  ADD UNIQUE KEY `UserGuild` (`userId`,`guildId`),
  ADD KEY `MemberGuild` (`guildId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `game`
--
ALTER TABLE `game`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gameserver`
--
ALTER TABLE `gameserver`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gsms`
--
ALTER TABLE `gsms`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaction`
--
ALTER TABLE `transaction`
  MODIFY `Id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `Id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `error`
--
ALTER TABLE `error`
  ADD CONSTRAINT `GMSFault` FOREIGN KEY (`GMSId`) REFERENCES `gsms` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `GameserverFault` FOREIGN KEY (`GameserverId`) REFERENCES `gameserver` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `TransactionFault` FOREIGN KEY (`TransactionId`) REFERENCES `transaction` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `gameserver`
--
ALTER TABLE `gameserver`
  ADD CONSTRAINT `ServerGMS` FOREIGN KEY (`GMSId`) REFERENCES `gsms` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ServerGame` FOREIGN KEY (`GameId`) REFERENCES `game` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `ServerOwner` FOREIGN KEY (`OwnerId`) REFERENCES `user` (`DiscordId`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `gameserverport`
--
ALTER TABLE `gameserverport`
  ADD CONSTRAINT `Game` FOREIGN KEY (`GameId`) REFERENCES `game` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `GamePort` FOREIGN KEY (`GameId`,`TierId`) REFERENCES `gametier` (`GameId`, `TierNumber`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `gamesupport`
--
ALTER TABLE `gamesupport`
  ADD CONSTRAINT `SupportedGame` FOREIGN KEY (`GameID`) REFERENCES `game` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `SupportingServer` FOREIGN KEY (`ServerID`) REFERENCES `gsms` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `gametier`
--
ALTER TABLE `gametier`
  ADD CONSTRAINT `GameTier` FOREIGN KEY (`GameId`) REFERENCES `game` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `TransactionServer` FOREIGN KEY (`ServerId`) REFERENCES `gameserver` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `TransactionUser` FOREIGN KEY (`UserId`) REFERENCES `user` (`Id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `userguild`
--
ALTER TABLE `userguild`
  ADD CONSTRAINT `GuildUser` FOREIGN KEY (`userId`) REFERENCES `user` (`DiscordId`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

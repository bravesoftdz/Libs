# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2018-02-22 19:00:43
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "core_groups"
#

DROP TABLE IF EXISTS `core_groups`;
CREATE TABLE `core_groups` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_group_id` int(11) DEFAULT NULL,
  `root_chain` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `parent_group_id` (`parent_group_id`),
  CONSTRAINT `core_groups_ibfk_2` FOREIGN KEY (`parent_group_id`) REFERENCES `core_groups` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=303 DEFAULT CHARSET=utf8;

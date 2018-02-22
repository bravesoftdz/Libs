# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2018-02-22 19:01:20
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "core_records"
#

DROP TABLE IF EXISTS `core_records`;
CREATE TABLE `core_records` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_group_id` int(11) NOT NULL DEFAULT '0',
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` longtext NOT NULL,
  PRIMARY KEY (`Id`),
  KEY `group_id` (`owner_group_id`),
  CONSTRAINT `core_records_ibfk_1` FOREIGN KEY (`owner_group_id`) REFERENCES `groups` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=328 DEFAULT CHARSET=utf8;

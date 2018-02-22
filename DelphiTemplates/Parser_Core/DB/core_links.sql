# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2018-02-22 19:01:09
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "core_links"
#

DROP TABLE IF EXISTS `core_links`;
CREATE TABLE `core_links` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) DEFAULT '0',
  `owner_group_id` int(11) DEFAULT NULL,
  `body_group_id` int(11) DEFAULT NULL,
  `url` text NOT NULL,
  `handled_type_id` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`Id`),
  KEY `handle_type_id` (`handled_type_id`),
  KEY `body_group_id` (`body_group_id`),
  KEY `owner_group_id` (`owner_group_id`),
  KEY `job_id` (`job_id`,`handled_type_id`,`level`),
  CONSTRAINT `core_links_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `core_jobs` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `core_links_ibfk_2` FOREIGN KEY (`handled_type_id`) REFERENCES `core_link_handled_types` (`Id`),
  CONSTRAINT `core_links_ibfk_3` FOREIGN KEY (`owner_group_id`) REFERENCES `core_groups` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `core_links_ibfk_4` FOREIGN KEY (`body_group_id`) REFERENCES `core_groups` (`Id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=utf8;


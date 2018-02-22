# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2018-02-22 19:00:53
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "core_jobs"
#

DROP TABLE IF EXISTS `core_jobs`;
CREATE TABLE `core_jobs` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `caption` varchar(255) NOT NULL DEFAULT '',
  `zero_link` text NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

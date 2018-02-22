# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2018-02-22 19:04:18
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "core_link_handled_types"
#

DROP TABLE IF EXISTS `core_link_handled_types`;
CREATE TABLE `core_link_handled_types` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `handled_type` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

#
# Data for table "core_link_handled_types"
#

INSERT INTO `core_link_handled_types` VALUES (1,'new link'),(2,'in handling'),(3,'success handled'),(4,'error handled');

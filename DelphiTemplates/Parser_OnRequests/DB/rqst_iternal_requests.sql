# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2018-02-22 19:03:24
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "rqst_iternal_requests"
#

DROP TABLE IF EXISTS `rqst_iternal_requests`;
CREATE TABLE `rqst_iternal_requests` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `link_id` int(11) NOT NULL DEFAULT '0',
  `url` text NOT NULL,
  `post_data` text,
  `headers` text,
  PRIMARY KEY (`Id`),
  KEY `link_id` (`link_id`),
  CONSTRAINT `rqst_iternal_requests_ibfk_1` FOREIGN KEY (`link_id`) REFERENCES `core_links` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

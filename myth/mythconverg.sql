-- MySQL dump 10.13  Distrib 5.5.38, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: mythconverg
-- ------------------------------------------------------
-- Server version	5.5.38-0ubuntu0.12.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `capturecard`
--

DROP TABLE IF EXISTS `capturecard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `capturecard` (
  `cardid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `videodevice` varchar(128) DEFAULT NULL,
  `audiodevice` varchar(128) DEFAULT NULL,
  `vbidevice` varchar(128) DEFAULT NULL,
  `cardtype` varchar(32) DEFAULT 'V4L',
  `defaultinput` varchar(32) DEFAULT 'Television',
  `audioratelimit` int(11) DEFAULT NULL,
  `hostname` varchar(64) DEFAULT NULL,
  `dvb_swfilter` int(11) DEFAULT '0',
  `dvb_sat_type` int(11) NOT NULL DEFAULT '0',
  `dvb_wait_for_seqstart` int(11) NOT NULL DEFAULT '1',
  `skipbtaudio` tinyint(1) DEFAULT '0',
  `dvb_on_demand` tinyint(4) NOT NULL DEFAULT '0',
  `dvb_diseqc_type` smallint(6) DEFAULT NULL,
  `firewire_speed` int(10) unsigned NOT NULL DEFAULT '0',
  `firewire_model` varchar(32) DEFAULT NULL,
  `firewire_connection` int(10) unsigned NOT NULL DEFAULT '0',
  `signal_timeout` int(11) NOT NULL DEFAULT '1000',
  `channel_timeout` int(11) NOT NULL DEFAULT '3000',
  `dvb_tuning_delay` int(10) unsigned NOT NULL DEFAULT '0',
  `contrast` int(11) NOT NULL DEFAULT '0',
  `brightness` int(11) NOT NULL DEFAULT '0',
  `colour` int(11) NOT NULL DEFAULT '0',
  `hue` int(11) NOT NULL DEFAULT '0',
  `diseqcid` int(10) unsigned DEFAULT NULL,
  `dvb_eitscan` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`cardid`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capturecard`
--

LOCK TABLES `capturecard` WRITE;
/*!40000 ALTER TABLE `capturecard` DISABLE KEYS */;
INSERT INTO `capturecard` VALUES (1,'/dev/dvb/adapter0/frontend0',NULL,NULL,'DVB','Television',NULL,'s',0,0,1,0,0,NULL,0,NULL,0,1000,3000,0,0,0,0,0,0,1),(2,'/dev/dvb/adapter0/frontend0',NULL,NULL,'DVB','Television',NULL,'s',0,0,1,0,0,0,0,NULL,0,1000,3000,0,0,0,0,0,0,1);
/*!40000 ALTER TABLE `capturecard` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cardinput`
--

DROP TABLE IF EXISTS `cardinput`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cardinput` (
  `cardinputid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cardid` int(10) unsigned NOT NULL DEFAULT '0',
  `sourceid` int(10) unsigned NOT NULL DEFAULT '0',
  `inputname` varchar(32) NOT NULL DEFAULT '',
  `externalcommand` varchar(128) DEFAULT NULL,
  `changer_device` varchar(128) DEFAULT NULL,
  `changer_model` varchar(128) DEFAULT NULL,
  `tunechan` varchar(10) DEFAULT NULL,
  `startchan` varchar(10) DEFAULT NULL,
  `displayname` varchar(64) NOT NULL DEFAULT '',
  `dishnet_eit` tinyint(1) NOT NULL DEFAULT '0',
  `recpriority` int(11) NOT NULL DEFAULT '0',
  `quicktune` tinyint(4) NOT NULL DEFAULT '0',
  `schedorder` int(10) unsigned NOT NULL DEFAULT '0',
  `livetvorder` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`cardinputid`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cardinput`
--

LOCK TABLES `cardinput` WRITE;
/*!40000 ALTER TABLE `cardinput` DISABLE KEYS */;
INSERT INTO `cardinput` VALUES (1,1,1,'DVBInput',NULL,NULL,NULL,NULL,'1','usb dvb fusion',0,0,0,1,1),(2,2,1,'DVBInput',NULL,NULL,NULL,NULL,'1','usb dvb fusion',0,0,0,1,1);
/*!40000 ALTER TABLE `cardinput` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channel`
--

DROP TABLE IF EXISTS `channel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channel` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `channum` varchar(10) NOT NULL DEFAULT '',
  `freqid` varchar(10) DEFAULT NULL,
  `sourceid` int(10) unsigned DEFAULT NULL,
  `callsign` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `icon` varchar(255) NOT NULL DEFAULT '',
  `finetune` int(11) DEFAULT NULL,
  `videofilters` varchar(255) NOT NULL DEFAULT '',
  `xmltvid` varchar(255) NOT NULL DEFAULT '',
  `recpriority` int(10) NOT NULL DEFAULT '0',
  `contrast` int(11) DEFAULT '32768',
  `brightness` int(11) DEFAULT '32768',
  `colour` int(11) DEFAULT '32768',
  `hue` int(11) DEFAULT '32768',
  `tvformat` varchar(10) NOT NULL DEFAULT 'Default',
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `outputfilters` varchar(255) NOT NULL DEFAULT '',
  `useonairguide` tinyint(1) DEFAULT '0',
  `mplexid` smallint(6) DEFAULT NULL,
  `serviceid` mediumint(8) unsigned DEFAULT NULL,
  `tmoffset` int(11) NOT NULL DEFAULT '0',
  `atsc_major_chan` int(10) unsigned NOT NULL DEFAULT '0',
  `atsc_minor_chan` int(10) unsigned NOT NULL DEFAULT '0',
  `last_record` datetime NOT NULL,
  `default_authority` varchar(32) NOT NULL DEFAULT '',
  `commmethod` int(11) NOT NULL DEFAULT '-1',
  `iptvid` smallint(6) unsigned DEFAULT NULL,
  PRIMARY KEY (`chanid`),
  KEY `channel_src` (`channum`,`sourceid`),
  KEY `sourceid` (`sourceid`,`xmltvid`,`chanid`),
  KEY `visible` (`visible`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
INSERT INTO `channel` VALUES (1021,'21','50',1,'VIVA','VIVA','viva_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,25728,0,0,0,'0000-00-00 00:00:00','bds.tv',-2,NULL),(1019,'19','50',1,'Yesterday','Yesterday','yesterday_uktv.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,25792,0,0,0,'0000-00-00 00:00:00','bds.tv',-2,NULL),(1022,'22','50',1,'Ideal World','Ideal World','ideal_world.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,25920,0,0,0,'0000-00-00 00:00:00','bds.tv',-2,NULL),(1045,'45','50',1,'Film4+1','Film4+1','film4_plus1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,27104,0,0,0,'2014-06-23 22:54:30','www.channel4.com',-2,NULL),(1047,'47','50',1,'4seven','4seven','channel4_seven_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,27168,0,0,0,'2014-01-20 03:39:30','www.channel4.com',-2,NULL),(1083,'83','50',1,'Al Jazeera Eng','Al Jazeera Eng','al_jazeera.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,27712,0,0,0,'0000-00-00 00:00:00','rovicorp.com',-2,NULL),(1024,'24','50',1,'ITV4','ITV4','itv4.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,28032,0,0,0,'2014-06-13 22:04:30','www.itv.com',-2,NULL),(1231,'231','50',1,'Racing UK','Racing UK','racing_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,1,28416,0,0,0,'0000-00-00 00:00:00','',-2,NULL),(1030,'30','54',1,'5*','5*','channel5_star.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,12928,0,0,0,'2014-07-15 17:59:30','www.five.tv',-2,NULL),(1031,'31','54',1,'5 USA','5 USA','channel5_usa.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,12992,0,0,0,'0000-00-00 00:00:00','www.five.tv',-2,NULL),(1044,'44','54',1,'Channel 5+1','Channel 5+1','channel5_region1_plus1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,13024,0,0,0,'2014-01-20 20:59:30','www.five.tv',-2,NULL),(1016,'16','54',1,'QVC','QVC','qvc_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,13120,0,0,0,'0000-00-00 00:00:00','',-2,NULL),(1023,'23','54',1,'bid','bid','bid_tv.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,14272,0,0,0,'0000-00-00 00:00:00','',-2,NULL),(1038,'38','54',1,'QUEST','QUEST','quest.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,14498,0,0,0,'0000-00-00 00:00:00','www.questtv.co.uk',-2,NULL),(1027,'27','54',1,'ITV2 +1','ITV2 +1','itv2_plus1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,15952,0,0,0,'2014-03-01 19:54:30','www.itv.com',-2,NULL),(1063,'63','54',1,'ITV3+1','ITV3+1','',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,16016,0,0,0,'0000-00-00 00:00:00','www.itv.com',-2,NULL),(1072,'72','54',1,'CITV','CITV','citv_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,16032,0,0,0,'2014-07-17 12:49:30','www.itv.com',-2,NULL),(1010,'10','54',1,'ITV3','ITV3','itv3.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,16048,0,0,0,'2014-06-08 23:04:30','www.itv.com',-2,NULL),(1055,'55','54',1,'5 Later','5 Later','',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,16080,0,0,0,'0000-00-00 00:00:00','www.channel5.com',-2,NULL),(1025,'25','54',1,'Dave ja vu','Dave ja vu','dave_ja_vu.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,16176,0,0,0,'0000-00-00 00:00:00','bds.tv',-2,NULL),(1020,'20','54',1,'Drama','Drama','drama_uktv.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,2,16208,0,0,0,'2014-06-01 22:44:30','bds.tv',-2,NULL),(1001,'1','55',1,'BBC ONE','BBC ONE','bbc_one.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4163,0,0,0,'2014-07-13 20:50:09','fp.bbc.co.uk',-2,NULL),(1002,'2','55',1,'BBC TWO','BBC TWO','bbc_two_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4287,0,0,0,'2014-06-01 07:59:30','fp.bbc.co.uk',-2,NULL),(1007,'7','55',1,'BBC THREE','BBC THREE','bbc_three.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4288,0,0,0,'2014-06-03 19:23:39','fp.bbc.co.uk',-2,NULL),(1080,'80','55',1,'BBC NEWS','BBC NEWS','bbc_news.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4352,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1200,'200','55',1,'BBC Red Button','BBC Red Button','bbc_red_button_2.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4416,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1009,'9','55',1,'BBC FOUR','BBC FOUR','bbc_four_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4544,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1070,'70','55',1,'CBBC Channel','CBBC Channel','bbc_cbbc.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4608,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1071,'71','55',1,'CBeebies','CBeebies','bbc_cbeebies.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4672,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1081,'81','55',1,'BBC Parliament','BBC Parliament','bbc_parliament.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,4736,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1301,'301','55',1,'BBC RB 301','BBC RB 301','bbc_red_button_2.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,7168,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1302,'302','55',1,'302','302','',0,'','',0,32768,32768,32768,32768,'',1,'',1,3,7232,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1003,'3','56',1,'ITV','ITV','itv_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8270,0,0,0,'2014-07-09 20:56:26','www.itv.com',-2,NULL),(1006,'6','56',1,'ITV2','ITV2','itv2.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8325,0,0,0,'2014-05-08 20:00:00','www.itv.com',-2,NULL),(1033,'33','56',1,'ITV +1','ITV +1','itv_uk_plus1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8370,0,0,0,'2014-06-12 19:25:50','www.itv.com',-2,NULL),(1004,'4','56',1,'Channel 4','Channel 4','channel4_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8384,0,0,0,'2014-07-12 20:00:20','www.channel4.com',-2,NULL),(1015,'15','56',1,'Film4','Film4','film4.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8385,0,0,0,'2014-07-14 19:59:30','www.channel4.com',-2,NULL),(1014,'14','56',1,'More 4','More 4','channel4_more4_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8442,0,0,0,'2014-04-14 20:59:30','www.channel4.com',-2,NULL),(1028,'28','56',1,'E4','E4','e4_uk.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8448,0,0,0,'2013-11-10 19:59:30','www.channel4.com',-2,NULL),(1013,'13','56',1,'Channel 4+1','Channel 4+1','channel4_london_plus1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8452,0,0,0,'2014-06-21 21:01:59','www.channel4.com',-2,NULL),(1005,'5','56',1,'Channel 5','Channel 5','channel5_region1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,4,8500,0,0,0,'2014-07-21 17:59:30','www.five.tv',-2,NULL),(1102,'102','58',1,'BBC TWO HD','BBC TWO HD','bbc_two_england_hd.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,17472,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1101,'101','58',1,'BBC ONE HD','BBC ONE HD','bbc_one_hd.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,17540,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1103,'103','58',1,'ITV HD','ITV HD','itv_uk_hd.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,17603,0,0,0,'0000-00-00 00:00:00','www.itv.com',-2,NULL),(1104,'104','58',1,'Channel 4 HD','Channel 4 HD','channel4_hd.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,17664,0,0,0,'0000-00-00 00:00:00','www.channel4.com',-2,NULL),(1105,'105','58',1,'BBC THREE HD','BBC THREE HD','bbc_three.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,17920,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1073,'73','58',1,'CBBC HD','CBBC HD','bbc_cbbc.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,18112,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1303,'303','58',1,'BBC RB 303 HD','BBC RB 303 HD','bbc_red_button_3.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,5,19648,0,0,0,'0000-00-00 00:00:00','fp.bbc.co.uk',-2,NULL),(1082,'82','59',1,'Sky News','Sky News','sky_uk_news.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,22080,0,0,0,'0000-00-00 00:00:00','www.sky.com',-2,NULL),(1011,'11','59',1,'Pick','Pick','pick_tv.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,22208,0,0,0,'0000-00-00 00:00:00','www.sky.com',-2,NULL),(1012,'12','59',1,'Dave','Dave','dave_uktv.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,22272,0,0,0,'0000-00-00 00:00:00','bds.tv',-2,NULL),(1029,'29','59',1,'E4+1','E4+1','e4_uk_plus1.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,22336,0,0,0,'2014-06-08 19:59:37','www.channel4.com',-2,NULL),(1017,'17','59',1,'Really','Really','really_uktv.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,23712,0,0,0,'0000-00-00 00:00:00','bds.tv',-2,NULL),(1032,'32','59',1,'Movie Mix','Movie Mix','',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,24032,0,0,0,'0000-00-00 00:00:00','',-2,NULL),(1087,'87','59',1,'COMMUNITY','COMMUNITY','community_channel.jpg',0,'','',0,32768,32768,32768,32768,'',1,'',1,6,24064,0,0,0,'0000-00-00 00:00:00','communitychannel.org',-2,NULL);
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videosource`
--

DROP TABLE IF EXISTS `videosource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videosource` (
  `sourceid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '',
  `xmltvgrabber` varchar(128) DEFAULT NULL,
  `userid` varchar(128) NOT NULL DEFAULT '',
  `freqtable` varchar(16) NOT NULL DEFAULT 'default',
  `lineupid` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL,
  `useeit` smallint(6) NOT NULL DEFAULT '0',
  `configpath` varchar(4096) DEFAULT NULL,
  `dvb_nit_id` int(6) DEFAULT '-1',
  PRIMARY KEY (`sourceid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videosource`
--

LOCK TABLES `videosource` WRITE;
/*!40000 ALTER TABLE `videosource` DISABLE KEYS */;
INSERT INTO `videosource` VALUES (1,'eit','eitonly','','default',NULL,NULL,1,NULL,-1);
/*!40000 ALTER TABLE `videosource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelgroupnames`
--

DROP TABLE IF EXISTS `channelgroupnames`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelgroupnames` (
  `grpid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '0',
  PRIMARY KEY (`grpid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelgroupnames`
--

LOCK TABLES `channelgroupnames` WRITE;
/*!40000 ALTER TABLE `channelgroupnames` DISABLE KEYS */;
/*!40000 ALTER TABLE `channelgroupnames` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelgroup`
--

DROP TABLE IF EXISTS `channelgroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelgroup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `chanid` int(11) unsigned NOT NULL DEFAULT '0',
  `grpid` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelgroup`
--

LOCK TABLES `channelgroup` WRITE;
/*!40000 ALTER TABLE `channelgroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `channelgroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `value` varchar(128) NOT NULL DEFAULT '',
  `data` varchar(16000) NOT NULL DEFAULT '',
  `hostname` varchar(64) DEFAULT NULL,
  KEY `value` (`value`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('mythfilldatabaseLastRunStart','',NULL),('mythfilldatabaseLastRunEnd','',NULL),('mythfilldatabaseLastRunStatus','',NULL),('DataDirectMessage','',NULL),('HaveRepeats','0',NULL),('DBSchemaVer','1317',NULL),('DefaultTranscoder','0',NULL),('MythFillSuggestedRunTime','1970-01-01T00:00:00',NULL),('MythFillGrabberSuggestsTime','1',NULL),('BackendServerIP','127.0.0.1','s'),('BackendServerPort','6543','s'),('BackendStatusPort','6544','s'),('MasterServerIP','127.0.0.1',NULL),('MasterServerPort','6543',NULL),('RecordFilePrefix','/var/lib/mythtv/recordings','s'),('TruncateDeletesSlowly','1','s'),('TVFormat','PAL',NULL),('VbiFormat','None',NULL),('FreqTable','europe-west',NULL),('TimeOffset','None',NULL),('MasterBackendOverride','1',NULL),('DeletesFollowLinks','0',NULL),('EITTimeOffset','Auto',NULL),('EITTransportTimeout','5',NULL),('EITIgnoresSource','0',NULL),('EITCrawIdleStart','60',NULL),('startupCommand','',NULL),('blockSDWUwithoutClient','1',NULL),('idleTimeoutSecs','',NULL),('idleWaitForRecordingTime','15',NULL),('StartupSecsBeforeRecording','120',NULL),('WakeupTimeFormat','hh:mm yyyy-MM-dd',NULL),('SetWakeuptimeCommand','',NULL),('ServerHaltCommand','sudo /sbin/halt -p',NULL),('preSDWUCheckCommand','',NULL),('WOLbackendReconnectWaitTime','',NULL),('WOLbackendConnectRetry','5',NULL),('WOLbackendCommand','',NULL),('WOLslaveBackendsCommand','',NULL),('JobQueueMaxSimultaneousJobs','1','s'),('JobQueueCheckFrequency','60','s'),('JobQueueWindowStart','00:00','s'),('JobQueueWindowEnd','23:59','s'),('JobQueueCPU','0','s'),('JobAllowCommFlag','1','s'),('JobAllowTranscode','1','s'),('JobAllowUserJob1','0','s'),('JobAllowUserJob2','0','s'),('JobAllowUserJob3','0','s'),('JobAllowUserJob4','0','s'),('JobsRunOnRecordHost','0',NULL),('AutoCommflagWhileRecording','0',NULL),('JobQueueCommFlagCommand','mythcommflag',NULL),('JobQueueTranscodeCommand','mythtranscode',NULL),('AutoTranscodeBeforeAutoCommflag','0',NULL),('SaveTranscoding','0',NULL),('UserJobDesc1','User Job #1',NULL),('UserJob1','',NULL),('UserJobDesc2','User Job #2',NULL),('UserJob2','',NULL),('UserJobDesc3','User Job #3',NULL),('UserJob3','',NULL),('UserJobDesc4','User Job #4',NULL),('UserJob4','',NULL),('upnp:UDN:urn:schemas-upnp-org:device:MediaServer:1','256a89b4-1266-49ca-9ac7-f0b4b4641e7f','s'),('Deinterlace','0','s'),('DeinterlaceFilter','linearblend','s'),('CustomFilters','','s'),('PreferredMPEG2Decoder','ffmpeg','s'),('UseOpenGLVSync','0','s'),('RealtimePriority','1','s'),('UseVideoTimebase','0','s'),('DecodeExtraAudio','1','s'),('AspectOverride','0','s'),('PIPLocation','0','s'),('PlaybackExitPrompt','0','s'),('EndOfRecordingExitPrompt','0','s'),('ClearSavedPosition','1','s'),('AltClearSavedPosition','1','s'),('UseOutputPictureControls','0','s'),('AudioNag','1','s'),('UDPNotifyPort','6948','s'),('PlayBoxOrdering','1','s'),('PlayBoxEpisodeSort','Date','s'),('GeneratePreviewPixmaps','0','s'),('PreviewPixmapOffset','64',NULL),('PreviewFromBookmark','1','s'),('PlaybackPreview','1','s'),('PlaybackPreviewLowCPU','0','s'),('PlaybackBoxStartInTitle','1','s'),('ShowGroupInfo','0','s'),('OSDSubFont','FreeSans','test-virtualbox'),('DisplayRecGroup','All Programs','s'),('QueryInitialFilter','0','s'),('RememberRecGroup','1','s'),('DispRecGroupAsAllProg','0','s'),('LiveTVInAllPrograms','0','s'),('DisplayGroupDefaultView','0','s'),('DisplayGroupTitleSort','0','s'),('PVR350OutputEnable','0','s'),('PVR350VideoDev','/dev/video16','s'),('PVR350EPGAlphaValue','164','s'),('PVR350InternalAudioOnly','0','s'),('SmartForward','0','s'),('StickyKeys','0','s'),('FFRewReposTime','100','s'),('FFRewReverse','1','s'),('ExactSeeking','0','s'),('AutoCommercialSkip','0','s'),('CommRewindAmount','','s'),('CommNotifyAmount','','s'),('MaximumCommercialSkip','3600',NULL),('CommSkipAllBlanks','1',NULL),('VertScanPercentage','','s'),('HorizScanPercentage','','s'),('XScanDisplacement','','s'),('YScanDisplacement','','s'),('OSDTheme','BlackCurves-OSD','s'),('OSDGeneralTimeout','2','s'),('OSDProgramInfoTimeout','3','s'),('OSDNotifyTimeout','5','s'),('OSDFont','FreeMono.ttf','s'),('OSDCCFont','FreeMono.ttf','s'),('OSDThemeFontSizeType','default','s'),('CCBackground','0','s'),('DefaultCCMode','0','s'),('PersistentBrowseMode','1','s'),('EnableMHEG','0','s'),('OSDCC708TextZoom','100','s'),('OSDCC708DefaultFontType','MonoSerif','s'),('OSDCC708MonoSerifFont','FreeMono.ttf','s'),('OSDCC708PropSerifFont','FreeMono.ttf','s'),('OSDCC708MonoSansSerifFont','FreeMono.ttf','s'),('OSDCC708PropSansSerifFont','FreeMono.ttf','s'),('OSDCC708CasualFont','FreeMono.ttf','s'),('OSDCC708CursiveFont','FreeMono.ttf','s'),('OSDCC708CapitalsFont','FreeMono.ttf','s'),('OSDCC708MonoSerifItalicFont','FreeMono.ttf','s'),('OSDCC708PropSerifItalicFont','FreeMono.ttf','s'),('OSDCC708MonoSansSerifItalicFont','FreeMono.ttf','s'),('OSDCC708PropSansSerifItalicFont','FreeMono.ttf','s'),('OSDCC708CasualItalicFont','FreeMono.ttf','s'),('OSDCC708CursiveItalicFont','FreeMono.ttf','s'),('OSDCC708CapitalsItalicFont','FreeMono.ttf','s'),('ChannelOrdering','channum','s'),('ChannelFormat','<num> <sign>','s'),('LongChannelFormat','<num> <name>','s'),('SmartChannelChange','0','s'),('LastFreeCard','0',NULL),('AutoExpireMethod','2',NULL),('AutoExpireDayPriority','3',NULL),('AutoExpireDefault','1',NULL),('AutoExpireLiveTVMaxAge','1',NULL),('AutoExpireExtraSpace','1',NULL),('AutoCommercialFlag','1',NULL),('CommercialSkipMethod','7',NULL),('AggressiveCommDetect','1',NULL),('AutoTranscode','0',NULL),('AutoRunUserJob1','0',NULL),('AutoRunUserJob2','0',NULL),('AutoRunUserJob3','0',NULL),('AutoRunUserJob4','0',NULL),('RecordPreRoll','30',NULL),('RecordOverTime','120',NULL),('OverTimeCategory','category name',NULL),('CategoryOverTime','30',NULL),('ATSCCheckSignalThreshold','65',NULL),('ATSCCheckSignalWait','5000',NULL),('HDRingbufferSize','9400',NULL),('EPGFillType','10','s'),('EPGShowCategoryColors','1','s'),('EPGShowCategoryText','1','s'),('EPGScrollType','1','s'),('EPGShowChannelIcon','1','s'),('EPGShowFavorites','0','s'),('WatchTVGuide','0','s'),('chanPerPage','5','s'),('timePerPage','4','s'),('UnknownTitle','Unknown','s'),('UnknownCategory','Unknown','s'),('DefaultTVChannel','3','s'),('SelectChangesChannel','0','s'),('SelChangeRecThreshold','16','s'),('EPGEnableJumpToChannel','0',NULL),('ThemePainter','qt','s'),('Style','','s'),('ThemeFontSizeType','default','s'),('RandomTheme','0','s'),('MenuTheme','default','s'),('XineramaScreen','0','s'),('XineramaMonitorAspectRatio','1.3333','s'),('GuiWidth','','s'),('GuiHeight','','s'),('GuiOffsetX','','s'),('GuiOffsetY','','s'),('GuiSizeForTV','1','s'),('HideMouseCursor','1','s'),('RunFrontendInWindow','0','s'),('UseVideoModes','0','s'),('GuiVidModeResolution','640x480','s'),('TVVidModeResolution','640x480','s'),('TVVidModeForceAspect','0.0','s'),('VidModeWidth0','','s'),('VidModeHeight0','','s'),('TVVidModeResolution0','640x480','s'),('TVVidModeForceAspect0','0.0','s'),('VidModeWidth1','','s'),('VidModeHeight1','','s'),('TVVidModeResolution1','640x480','s'),('TVVidModeForceAspect1','0.0','s'),('VidModeWidth2','','s'),('VidModeHeight2','','s'),('TVVidModeResolution2','640x480','s'),('TVVidModeForceAspect2','0.0','s'),('ISO639Language0','eng',NULL),('ISO639Language1','eng',NULL),('DateFormat','ddd d MMM yyyy','s'),('ShortDateFormat','ddd d','s'),('TimeFormat','hh:mm','s'),('QtFontSmall','12','s'),('QtFontMedium','16','s'),('QtFontBig','25','s'),('PlayBoxTransparency','1','s'),('PlayBoxShading','0','s'),('UseVirtualKeyboard','1','s'),('LCDEnable','0','s'),('LCDShowTime','1','s'),('LCDShowMenu','1','s'),('LCDShowMusic','1','s'),('LCDShowMusicItems','ArtistTitle','s'),('LCDShowChannel','1','s'),('LCDShowRecStatus','0','s'),('LCDShowVolume','1','s'),('LCDShowGeneric','1','s'),('LCDBacklightOn','1','s'),('LCDHeartBeatOn','0','s'),('LCDBigClock','0','s'),('LCDKeyString','ABCDEF','s'),('LCDPopupTime','5','s'),('AudioOutputDevice','ALSA:hdmi:CARD=NVidia,DEV=0','s'),('PassThruOutputDevice','Default','s'),('AC3PassThru','0','s'),('DTSPassThru','0','s'),('AggressiveSoundcardBuffer','0','s'),('MythControlsVolume','1','s'),('MixerDevice','default','s'),('MixerControl','PCM','s'),('MasterMixerVolume','100','s'),('PCMMixerVolume','100','s'),('IndividualMuteControl','0','s'),('AllowQuitShutdown','4','s'),('NoPromptOnExit','1','s'),('HaltCommand','','s'),('LircKeyPressedApp','','s'),('UseArrowAccels','1','s'),('NetworkControlEnabled','1','s'),('NetworkControlPort','6546','s'),('SetupPinCodeRequired','0','s'),('MonitorDrives','0','s'),('EnableXbox','0','s'),('LogEnabled','0',NULL),('LogPrintLevel','8','s'),('LogCleanEnabled','0','s'),('LogCleanPeriod','14','s'),('LogCleanDays','14','s'),('LogCleanMax','30','s'),('LogMaxCount','100','s'),('MythFillEnabled','0',NULL),('MythFillDatabasePath','/usr/bin/mythfilldatabase',NULL),('MythFillDatabaseArgs','',NULL),('MythFillDatabaseLog','',NULL),('MythFillPeriod','1',NULL),('MythFillMinHour','2',NULL),('MythFillMaxHour','5',NULL),('SchedMoveHigher','1',NULL),('DefaultStartOffset','0',NULL),('DefaultEndOffset','0',NULL),('ComplexPriority','0',NULL),('PrefInputPriority','2',NULL),('OnceRecPriority','0',NULL),('HDTVRecPriority','',NULL),('CCRecPriority','',NULL),('SingleRecordRecPriority','1',NULL),('OverrideRecordRecPriority','0',NULL),('FindOneRecordRecPriority','-1',NULL),('WeekslotRecordRecPriority','0',NULL),('TimeslotRecordRecPriority','0',NULL),('ChannelRecordRecPriority','0',NULL),('AllRecordRecPriority','0',NULL),('ArchiveDBSchemaVer','1005',NULL),('MythArchiveTempDir','/var/lib/mytharchive/temp','s'),('MythArchiveShareDir','/usr/share/mythtv/mytharchive/','s'),('MythArchiveVideoFormat','PAL','s'),('MythArchiveFileFilter','*.mpg *.mov *.avi *.mpeg *.nuv','s'),('MythArchiveDVDLocation','/dev/dvd','s'),('MythArchiveEncodeToAc3','0','s'),('MythArchiveCopyRemoteFiles','0','s'),('MythArchiveAlwaysUseMythTranscode','1','s'),('MythArchiveUseFIFO','1','s'),('MythArchiveMainMenuAR','16:9','s'),('MythArchiveChapterMenuAR','Video','s'),('MythArchiveDateFormat','%a %d %b %Y','s'),('MythArchiveTimeFormat','%H:%M','s'),('MythArchiveFfmpegCmd','ffmpeg','s'),('MythArchiveMplexCmd','mplex','s'),('MythArchiveDvdauthorCmd','dvdauthor','s'),('MythArchiveSpumuxCmd','spumux','s'),('MythArchiveMpeg2encCmd','mpeg2enc','s'),('MythArchiveMkisofsCmd','mkisofs','s'),('MythArchiveGrowisofsCmd','growisofs','s'),('MythArchiveTcrequantCmd','tcrequant','s'),('MythArchivePng2yuvCmd','png2yuv','s'),('BackendServerIP6','::1','s'),('DVDDeviceLocation','/dev/dvd','s'),('VCDDeviceLocation','/dev/cdrom','s'),('DVDOnInsertDVD','1','s'),('mythdvd.DVDPlayerCommand','Internal','s'),('VCDPlayerCommand','mplayer vcd:// -cdrom-device %d -fs -zoom -vo xv','s'),('DVDRipLocation','/var/lib/mythdvd/temp','s'),('TitlePlayCommand','Internal','s'),('SubTitleCommand','-sid %s','s'),('TranscodeCommand','transcode','s'),('MTDPort','2442','s'),('MTDNiceLevel','20','s'),('MTDConcurrentTranscodes','1','s'),('MTDRipSize','0','s'),('MTDLogFlag','0','s'),('MTDac3Flag','0','s'),('MTDxvidFlag','1','s'),('mythvideo.TrustTranscodeFRDetect','1','s'),('GalleryDBSchemaVer','1003',NULL),('GalleryDir','/var/lib/mythtv/pictures','s'),('GalleryThumbnailLocation','1','s'),('GallerySortOrder','20','s'),('GalleryImportDirs','/media/cdrom:/media/usbdisk','s'),('GalleryMoviePlayerCmd','Internal','s'),('SlideshowOpenGLTransition','none','s'),('SlideshowOpenGLTransitionLength','2000','s'),('GalleryOverlayCaption','','s'),('SlideshowTransition','none','s'),('SlideshowBackground','','s'),('SlideshowDelay','5','s'),('GameDBSchemaVer','1016',NULL),('MusicDBSchemaVer','1020',NULL),('MusicLocation','/var/lib/mythtv/music/','s'),('MusicAudioDevice','default','s'),('CDDevice','/dev/cdrom','s'),('TreeLevels','splitartist artist album title','s'),('NonID3FileNameFormat','GENRE/ARTIST/ALBUM/TRACK_TITLE','s'),('Ignore_ID3','0','s'),('AutoLookupCD','1','s'),('AutoPlayCD','0','s'),('KeyboardAccelerators','1','s'),('CDWriterEnabled','1','s'),('CDDiskSize','1','s'),('CDCreateDir','1','s'),('CDWriteSpeed','0','s'),('CDBlankType','fast','s'),('PlayMode','none','s'),('IntelliRatingWeight','35','s'),('IntelliPlayCountWeight','25','s'),('IntelliLastPlayWeight','25','s'),('IntelliRandomWeight','15','s'),('MusicShowRatings','0','s'),('ShowWholeTree','0','s'),('ListAsShuffled','0','s'),('VisualMode','Random','s'),('VisualCycleOnSongChange','0','s'),('VisualModeDelay','0','s'),('VisualScaleWidth','1','s'),('VisualScaleHeight','1','s'),('ParanoiaLevel','Full','s'),('FilenameTemplate','ARTIST/ALBUM/TRACK-TITLE','s'),('TagSeparator',' - ','s'),('NoWhitespace','0','s'),('PostCDRipScript','','s'),('EjectCDAfterRipping','1','s'),('OnlyImportNewMusic','0','s'),('EncoderType','ogg','s'),('DefaultRipQuality','0','s'),('Mp3UseVBR','0','s'),('PhoneDBSchemaVer','1001',NULL),('SipRegisterWithProxy','1','s'),('SipProxyName','fwd.pulver.com','s'),('SipProxyAuthName','','s'),('SipProxyAuthPassword','','s'),('MySipName','Me','s'),('SipAutoanswer','0','s'),('SipBindInterface','eth0','s'),('SipLocalPort','5060','s'),('NatTraversalMethod','None','s'),('NatIpAddress','http://checkip.dyndns.org','s'),('AudioLocalPort','21232','s'),('VideoLocalPort','21234','s'),('MicrophoneDevice','None','s'),('CodecPriorityList','GSM;G.711u;G.711a','s'),('PlayoutAudioCall','40','s'),('PlayoutVideoCall','110','s'),('TxResolution','176x144','s'),('TransmitFPS','5','s'),('TransmitBandwidth','256','s'),('CaptureResolution','352x288','s'),('TimeToAnswer','10','s'),('DefaultVxmlUrl','http://127.0.0.1/vxml/index.vxml','s'),('DefaultVoicemailPrompt','I am not at home, please leave a message after the tone','s'),('VideoStartupDir','/var/lib/mythtv/videos','s'),('VideoArtworkDir','/var/lib/mythtv/coverart','s'),('VideoDefaultParentalLevel','4','s'),('VideoAggressivePC','0','s'),('Default MythVideo View','2','s'),('VideoListUnknownFiletypes','1','s'),('VideoBrowserNoDB','0','s'),('VideoGalleryNoDB','0','s'),('VideoTreeNoDB','0','s'),('VideoTreeLoadMetaData','1','s'),('VideoNewBrowsable','1','s'),('mythvideo.sort_ignores_case','1','s'),('mythvideo.db_folder_view','1','s'),('mythvideo.ImageCacheSize','50','s'),('AutomaticSetWatched','0','s'),('AlwaysStreamFiles','0','s'),('JumpToProgramOSD','1','s'),('ContinueEmbeddedTVPlay','0','s'),('VideoGalleryColsPerPage','4','s'),('VideoGalleryRowsPerPage','3','s'),('VideoGallerySubtitle','1','s'),('VideoGalleryAspectRatio','1','s'),('VideoDefaultPlayer','Internal','s'),('MythFillFixProgramIDsHasRunOnce','1','s'),('DisplayGroupDefaultViewMask','32769','s'),('SecurityPin','0000','s'),('MiscStatusScript','','s'),('DisableFirewireReset','0','s'),('Theme','Mythbuntu','localhost'),('Theme','Mythbuntu','s'),('MythFillFixProgramIDsHasRunOnce','1','s'),('BackupDBLastRunStart','2013-11-20 21:24:43',NULL),('BackupDBLastRunEnd','2013-11-20 21:24:44',NULL),('Language','en_GB','s'),('BackendServerIP','127.0.0.1','s'),('BackendServerPort','6543','s'),('BackendStatusPort','6544','s'),('SecurityPin','','s'),('TruncateDeletesSlowly','0','s'),('MiscStatusScript','','s'),('DisableFirewireReset','0','s'),('JobQueueMaxSimultaneousJobs','1','s'),('JobQueueCheckFrequency','60','s'),('JobQueueWindowStart','00:00','s'),('JobQueueWindowEnd','23:59','s'),('JobQueueCPU','0','s'),('JobAllowCommFlag','1','s'),('JobAllowTranscode','1','s'),('JobAllowUserJob1','0','s'),('JobAllowUserJob2','0','s'),('JobAllowUserJob3','0','s'),('JobAllowUserJob4','0','s'),('StorageScheduler','Combination',NULL),('AdjustFill','6','s'),('LetterboxColour','0','s'),('GeneratePreviewRemotely','0','s'),('HWAccelPlaybackPreview','0','s'),('PlaybackWatchList','0','s'),('PlaybackWLStart','0','s'),('PlaybackWLAutoExpire','0','s'),('PlaybackWLMaxAge','60','s'),('PlaybackWLBlackOut','2','s'),('BrowseAllTuners','0','s'),('Prefer708Captions','1','s'),('SubtitleCodec','UTF-8','s'),('LiveTVPriority','0',NULL),('RerecordWatched','1',NULL),('AutoExpireWatchedPriority','1',NULL),('AutoExpireInsteadOfDelete','0',NULL),('DeletedFifoOrder','0',NULL),('ChannelGroupRememberLast','0','s'),('ChannelGroupDefault','-1','s'),('BrowseChannelGroup','0','s'),('ThemeCacheSize','1','s'),('UseFixedWindowSize','1','s'),('TVVidModeRefreshRate','60.000','s'),('TVVidModeRefreshRate0','60.000','s'),('TVVidModeRefreshRate1','60.000','s'),('TVVidModeRefreshRate2','60.000','s'),('MaxChannels','2','s'),('AudioUpmixType','0','s'),('ScreenShotPath','/tmp/','s'),('MediaChangeEvents','0','s'),('OverrideExitMenu','0','s'),('RebootCommand','','s'),('LircSocket','/dev/lircd','s'),('SchedOpenEnd','0',NULL),('MythArchiveDVDPlayerCmd','Internal','s'),('MythArchiveUseProjectX','0','s'),('MythArchiveAddSubtitles','0','s'),('MythArchiveDefaultEncProfile','SP','s'),('MythArchiveJpeg2yuvCmd','jpeg2yuv','s'),('MythArchiveProjectXCmd','projectx','s'),('SlideshowUseOpenGL','0','s'),('MythMovies.LastGrabDate','','s'),('MythMovies.DatabaseVersion','4','s'),('ArtistTreeGroups','0','s'),('MusicTagEncoding','utf16','s'),('CDWriterDevice','default','s'),('ResumeMode','off','s'),('MusicExitAction','prompt','s'),('MaxSearchResults','300','s'),('VisualAlbumArtOnSongChange','0','s'),('VisualRandomize','0','s'),('mythvideo.screenshotDir','/var/lib/mythtv/screenshots','s'),('mythvideo.bannerDir','/var/lib/mythtv/banners','s'),('mythvideo.fanartDir','/var/lib/mythtv/fanart','s'),('mythvideo.db_group_view','1','s'),('mythvideo.VideoTreeRemember','0','s'),('mythvideo.db_group_type','0','s'),('DVDDriveSpeed','12','s'),('EnableDVDBookmark','0','s'),('DVDBookmarkPrompt','0','s'),('DVDBookmarkDays','10','s'),('MovieListCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -M','s'),('MoviePosterCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -P','s'),('MovieFanartCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -B','s'),('MovieDataCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -D','s'),('mythvideo.ParentalLevelFromRating','0','s'),('mythvideo.AutoR2PL1','G','s'),('mythvideo.AutoR2PL2','PG','s'),('mythvideo.AutoR2PL3','PG-13','s'),('mythvideo.AutoR2PL4','R:NC-17','s'),('mythvideo.TrailersDir','/home/test/.mythtv/MythVideo/Trailers','s'),('mythvideo.TrailersRandomEnabled','0','s'),('mythvideo.TrailersRandomCount','3','s'),('mythvideo.TVListCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -M','s'),('mythvideo.TVPosterCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -mP','s'),('mythvideo.TVFanartCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -tF','s'),('mythvideo.TVBannerCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -tB','s'),('mythvideo.TVDataCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -D','s'),('mythvideo.TVTitleSubCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -N','s'),('mythvideo.TVScreenshotCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -S','s'),('mythvideo.EnableAlternatePlayer','0','s'),('mythvideo.VideoAlternatePlayer','Internal','s'),('WeatherDBSchemaVer','1006',NULL),('DisableAutomaticBackup','0',NULL),('BackendStopCommand','killall mythbackend',NULL),('BackendStartCommand','mythbackend',NULL),('UPnP/WMPSource','0',NULL),('UPnP/RebuildDelay','30','s'),('AudioDefaultUpmix','1','s'),('AdvancedAudioSettings','0','s'),('SRCQualityOverride','0','s'),('SRCQuality','1','s'),('BrowserDBSchemaVer','1002',NULL),('WebBrowserCommand','Internal','s'),('WebBrowserZoomLevel','1','s'),('NetvisionDBSchemaVer','1004',NULL),('NewsDBSchemaVer','1001',NULL),('MusicDefaultUpmix','0','s'),('Country','US','test-virtualbox'),('CommFlagFast','0',NULL),('Audio48kOverride','0','test-virtualbox'),('PassThruDeviceOverride','0','test-virtualbox'),('StereoPCM','0','test-virtualbox'),('Country','US','s'),('BackendServerIP6','::1','s'),('DefaultVideoPlaybackProfile','VDPAU Normal','s'),('DefaultSubtitleFont','FreeMono','s'),('AutoMetadataLookup','1',NULL),('GalleryAutoLoad','0','s'),('GalleryFilterType','0','s'),('ThemeUpdateStatus','','s'),('MusicBookmark','-1','s'),('MusicBookmarkPosition','0','s'),('RepeatMode','all','s'),('MusicAutoShowPlayer','1','s'),('MusicLastVisualizer','0','s'),('mythvideo.VideoTreeLastActive','Video Home\nHero Squad Search and Rescue','s'),('DisplayRecGroupIsCategory','0','s'),('LastMusicPlaylistPush','0','s'),('FrontendIdleTimeout','90','s'),('HardwareProfileEnabled','0',NULL),('WebDBSchemaVer','4',NULL),('WebPrefer_Channum','1',NULL),('WebFLV_w','320',NULL),('recommend_enabled','',NULL),('recommend_server','http://myth-recommendations.aws.af.cm/',NULL),('recommend_key','REQUIRED',NULL),('AirPlayId','553D4D3F605F','s'),('AirPlayFullScreen','0','s'),('AirPlayEnabled','1','s'),('AirPlayAudioOnly','0','s'),('AirPlayPasswordEnabled','0','s'),('AirPlayPassword','0000','s'),('MythArchiveM2VRequantiserCmd','M2VRequantiser','s'),('AllowLinkLocal','1','s'),('JobAllowMetadata','1','s'),('LiveTVIdleTimeout','120','s'),('DefaultChanid','1001','s'),('EPGSortReverse','0','s'),('AlwaysOnTop','0','s');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-07-22 21:25:58

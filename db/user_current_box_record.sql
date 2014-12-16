CREATE TABLE `user_current_box_records` (
  `card_id` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `data_string` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0',
  `box_id` int(10) unsigned NOT NULL DEFAULT '0',
  `machine_id` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `time` datetime NOT NULL,
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`card_id`),
  KEY `ucbr_box_id` (`box_id`) USING BTREE,
  KEY `ucbr_time_index` (`time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
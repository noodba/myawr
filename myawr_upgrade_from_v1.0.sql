alter table  myawr_cpu_info                                           add snap_time datetime;
alter table  myawr_innodb_info                                        add snap_time datetime;
alter table  myawr_io_info                                            add snap_time datetime;
alter table  myawr_isam_info                                          add snap_time datetime;
alter table  myawr_load_info                                          add snap_time datetime;
alter table  myawr_mysql_info                                         add snap_time datetime;
alter table  myawr_snapshot_events_waits_summary_global_by_event_name add snap_time datetime;
alter table  myawr_snapshot_file_summary_by_event_name                add snap_time datetime;              
alter table  myawr_swap_net_disk_info                                 add snap_time datetime;
 
update myawr_cpu_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_innodb_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_io_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_isam_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_load_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_mysql_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_snapshot_events_waits_summary_global_by_event_name a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_snapshot_file_summary_by_event_name a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);
update myawr_swap_net_disk_info a set  snap_time=(select b.snap_time from myawr_snapshot b where a.snap_id=b.snap_id and a.host_id=b.host_id);


rename table myawr_cpu_info                                           to myawr_cpu_info_old                                           ;
rename table myawr_innodb_info                                        to myawr_innodb_info_old                                        ;
rename table myawr_io_info                                            to myawr_io_info_old                                            ;
rename table myawr_isam_info                                          to myawr_isam_info_old                                          ;
rename table myawr_load_info                                          to myawr_load_info_old                                          ;
rename table myawr_mysql_info                                         to myawr_mysql_info_old                                         ;
rename table myawr_query_review_history                               to myawr_query_review_history_old                               ;
rename table myawr_snapshot                                           to myawr_snapshot_old                                           ;
rename table myawr_snapshot_events_waits_summary_by_instance          to myawr_snapshot_events_waits_summary_by_instance_old          ;
rename table myawr_snapshot_events_waits_summary_global_by_event_name to myawr_snapshot_events_waits_summary_global_by_event_name_old ;
rename table myawr_snapshot_file_summary_by_event_name                to myawr_snapshot_file_summary_by_event_name_old                ;
rename table myawr_snapshot_file_summary_by_instance                  to myawr_snapshot_file_summary_by_instance_old                  ;
rename table myawr_swap_net_disk_info                                 to myawr_swap_net_disk_info_old                                 ;


CREATE TABLE `myawr_cpu_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `cpu_user` float(10,2) DEFAULT NULL,
  `cpu_system` float(10,2) DEFAULT NULL,
  `cpu_idle` float(10,2) DEFAULT NULL,
  `cpu_iowait` float(10,2) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_cpu_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_cpu_info_snap_time` (`snap_time`),
  KEY `idx_myawr_cpu_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22806 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);

CREATE TABLE `myawr_innodb_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `Innodb_rows_inserted` float(26,2) DEFAULT NULL,
  `Innodb_rows_updated` float(26,2) DEFAULT NULL,
  `Innodb_rows_deleted` float(26,2) DEFAULT NULL,
  `Innodb_rows_read` float(26,2) DEFAULT NULL,
  `Innodb_buffer_pool_read_requests` float(26,2) DEFAULT NULL,
  `Innodb_buffer_pool_reads` float(26,2) DEFAULT NULL,
  `Innodb_buffer_pool_pages_data` float(26,2) DEFAULT NULL,
  `Innodb_buffer_pool_pages_free` float(26,2) DEFAULT NULL,
  `Innodb_buffer_pool_pages_dirty` float(26,2) DEFAULT NULL,
  `Innodb_buffer_pool_pages_flushed` float(26,2) DEFAULT NULL,
  `Innodb_data_reads` float(26,2) DEFAULT NULL,
  `Innodb_data_writes` float(26,2) DEFAULT NULL,
  `Innodb_data_read` float(26,2) DEFAULT NULL,
  `Innodb_data_written` float(26,2) DEFAULT NULL,
  `Innodb_os_log_fsyncs` float(26,2) DEFAULT NULL,
  `Innodb_os_log_written` float(26,2) DEFAULT NULL,
  `history_list` float(26,2) DEFAULT NULL,
  `log_bytes_written` float(26,2) DEFAULT NULL,
  `log_bytes_flushed` float(26,2) DEFAULT NULL,
  `last_checkpoint` float(26,2) DEFAULT NULL,
  `queries_inside` float(26,2) DEFAULT NULL,
  `queries_queued` float(26,2) DEFAULT NULL,
  `read_views` float(26,2) DEFAULT NULL,
  `innodb_open_files` float(26,2) DEFAULT NULL,
  `innodb_log_waits` float(26,2) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_innodb_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_innodb_info_snap_time` (`snap_time`),
  KEY `idx_myawr_innodb_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22802 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);


CREATE TABLE `myawr_io_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `rd_ios_s` float(10,2) DEFAULT NULL,
  `wr_ios_s` float(10,2) DEFAULT NULL,
  `rkbs` float(10,2) DEFAULT NULL,
  `wkbs` float(10,2) DEFAULT NULL,
  `queue` float(10,2) DEFAULT NULL,
  `wait` float(10,2) DEFAULT NULL,
  `svc_t` float(10,2) DEFAULT NULL,
  `busy` float(10,2) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_io_info_snap_time` (`snap_time`),
  KEY `idx_myawr_io_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_io_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22806 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);

CREATE TABLE `myawr_isam_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `key_buffer_size` float(26,2) DEFAULT NULL,
  `join_buffer_size` float(26,2) DEFAULT NULL,
  `sort_buffer_size` float(26,2) DEFAULT NULL,
  `Key_blocks_not_flushed` float(26,2) DEFAULT NULL,
  `Key_blocks_unused` float(26,2) DEFAULT NULL,
  `Key_blocks_used` float(26,2) DEFAULT NULL,
  `Key_read_requests` float(26,2) DEFAULT NULL,
  `Key_reads` float(26,2) DEFAULT NULL,
  `Key_write_requests` float(26,2) DEFAULT NULL,
  `Key_writes` float(26,2) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_isam_info_snap_time` (`snap_time`),
  KEY `idx_myawr_isam_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_isam_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22802 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);


CREATE TABLE `myawr_load_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `load1` float(10,2) DEFAULT NULL,
  `load5` float(10,2) DEFAULT NULL,
  `load15` float(10,2) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_load_info_snap_time` (`snap_time`),
  KEY `idx_myawr_load_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_load_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22806 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);



CREATE TABLE `myawr_mysql_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `query_cache_size` float(26,2) DEFAULT NULL,
  `thread_cache_size` float(26,2) DEFAULT NULL,
  `table_definition_cache` float(26,2) DEFAULT NULL,
  `max_connections` float(26,2) DEFAULT NULL,
  `table_open_cache` float(26,2) DEFAULT NULL,
  `slow_launch_time` float(26,2) DEFAULT NULL,
  `log_slow_queries` float(26,2) DEFAULT NULL,
  `max_heap_table_size` float(26,2) DEFAULT NULL,
  `tmp_table_size` float(26,2) DEFAULT NULL,
  `open_files_limit` float(26,2) DEFAULT NULL,
  `Max_used_connections` float(26,2) DEFAULT NULL,
  `Threads_connected` float(26,2) DEFAULT NULL,
  `Threads_cached` float(26,2) DEFAULT NULL,
  `Threads_created` float(26,2) DEFAULT NULL,
  `Threads_running` float(26,2) DEFAULT NULL,
  `Connections` float(26,2) DEFAULT NULL,
  `Questions` float(26,2) DEFAULT NULL,
  `Com_select` float(26,2) DEFAULT NULL,
  `Com_insert` float(26,2) DEFAULT NULL,
  `Com_update` float(26,2) DEFAULT NULL,
  `Com_delete` float(26,2) DEFAULT NULL,
  `Bytes_received` float(26,2) DEFAULT NULL,
  `Bytes_sent` float(26,2) DEFAULT NULL,
  `Qcache_hits` float(26,2) DEFAULT NULL,
  `Qcache_inserts` float(26,2) DEFAULT NULL,
  `Select_full_join` float(26,2) DEFAULT NULL,
  `Select_scan` float(26,2) DEFAULT NULL,
  `Slow_queries` float(26,2) DEFAULT NULL,
  `Com_commit` float(26,2) DEFAULT NULL,
  `Com_rollback` float(26,2) DEFAULT NULL,
  `Open_files` float(26,2) DEFAULT NULL,
  `Open_table_definitions` float(26,2) DEFAULT NULL,
  `Open_tables` float(26,2) DEFAULT NULL,
  `Opened_files` float(26,2) DEFAULT NULL,
  `Opened_table_definitions` float(26,2) DEFAULT NULL,
  `Opened_tables` float(26,2) DEFAULT NULL,
  `Created_tmp_disk_tables` float(26,2) DEFAULT NULL,
  `Created_tmp_files` float(26,2) DEFAULT NULL,
  `Created_tmp_tables` float(26,2) DEFAULT NULL,
  `Binlog_cache_disk_use` float(26,2) DEFAULT NULL,
  `Binlog_cache_use` float(26,2) DEFAULT NULL,
  `Aborted_clients` float(26,2) DEFAULT NULL,
  `Sort_merge_passes` float(26,2) DEFAULT NULL,
  `Sort_range` float(26,2) DEFAULT NULL,
  `Sort_rows` float(26,2) DEFAULT NULL,
  `Sort_scan` float(26,2) DEFAULT NULL,
  `Table_locks_immediate` float(26,2) DEFAULT NULL,
  `Table_locks_waited` float(26,2) DEFAULT NULL,
  `Handler_read_first` float(26,2) DEFAULT NULL,
  `Handler_read_key` float(26,2) DEFAULT NULL,
  `Handler_read_last` float(26,2) DEFAULT NULL,
  `Handler_read_next` float(26,2) DEFAULT NULL,
  `Handler_read_prev` float(26,2) DEFAULT NULL,
  `Handler_read_rnd` float(26,2) DEFAULT NULL,
  `Handler_read_rnd_next` float(26,2) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_mysql_info_snap_time` (`snap_time`),
  KEY `idx_myawr_mysql_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_mysql_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22802 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);





CREATE TABLE `myawr_snapshot_events_waits_summary_global_by_event_name` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `EVENT_NAME` varchar(128) NOT NULL,
  `COUNT_STAR` bigint(20) unsigned NOT NULL,
  `SUM_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `MIN_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `AVG_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `MAX_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `snap_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_waits_summary_global_snap_time` (`snap_time`),
  KEY `idx_waits_summary_global_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_waits_summary_global_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5058638 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p20130510 VALUES LESS THAN (to_days('2013-05-10')) ENGINE = InnoDB,
PARTITION p20130511 VALUES LESS THAN (to_days('2013-05-11')) ENGINE = InnoDB,
PARTITION p20130512 VALUES LESS THAN (to_days('2013-05-12')) ENGINE = InnoDB,
PARTITION p20130513 VALUES LESS THAN (to_days('2013-05-13')) ENGINE = InnoDB,
PARTITION p20130514 VALUES LESS THAN (to_days('2013-05-14')) ENGINE = InnoDB,
PARTITION p20130515 VALUES LESS THAN (to_days('2013-05-15')) ENGINE = InnoDB,
PARTITION p20130516 VALUES LESS THAN (to_days('2013-05-16')) ENGINE = InnoDB,
PARTITION p20130517 VALUES LESS THAN (to_days('2013-05-17')) ENGINE = InnoDB,
PARTITION p20130518 VALUES LESS THAN (to_days('2013-05-18')) ENGINE = InnoDB,
PARTITION p20130519 VALUES LESS THAN (to_days('2013-05-19')) ENGINE = InnoDB,
PARTITION p20130520 VALUES LESS THAN (to_days('2013-05-20')) ENGINE = InnoDB,
PARTITION p20130521 VALUES LESS THAN (to_days('2013-05-21')) ENGINE = InnoDB,
PARTITION p20130522 VALUES LESS THAN (to_days('2013-05-22')) ENGINE = InnoDB,
PARTITION p20130523 VALUES LESS THAN (to_days('2013-05-23')) ENGINE = InnoDB,
PARTITION p20130524 VALUES LESS THAN (to_days('2013-05-24')) ENGINE = InnoDB,
PARTITION p20130525 VALUES LESS THAN (to_days('2013-05-25')) ENGINE = InnoDB,
PARTITION p20130526 VALUES LESS THAN (to_days('2013-05-26')) ENGINE = InnoDB,
PARTITION p20130527 VALUES LESS THAN (to_days('2013-05-27')) ENGINE = InnoDB,
PARTITION p20130528 VALUES LESS THAN (to_days('2013-05-28')) ENGINE = InnoDB,
PARTITION p20130529 VALUES LESS THAN (to_days('2013-05-29')) ENGINE = InnoDB,
PARTITION p20130530 VALUES LESS THAN (to_days('2013-05-30')) ENGINE = InnoDB,
PARTITION p20130531 VALUES LESS THAN (to_days('2013-05-31')) ENGINE = InnoDB,
PARTITION p20130601 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p20130602 VALUES LESS THAN (to_days('2013-06-02')) ENGINE = InnoDB,
PARTITION p20130603 VALUES LESS THAN (to_days('2013-06-03')) ENGINE = InnoDB,
PARTITION p20130604 VALUES LESS THAN (to_days('2013-06-04')) ENGINE = InnoDB,
PARTITION p20130605 VALUES LESS THAN (to_days('2013-06-05')) ENGINE = InnoDB,
PARTITION p20130606 VALUES LESS THAN (to_days('2013-06-06')) ENGINE = InnoDB,
PARTITION p20130607 VALUES LESS THAN (to_days('2013-06-07')) ENGINE = InnoDB,
PARTITION p20130608 VALUES LESS THAN (to_days('2013-06-08')) ENGINE = InnoDB,
PARTITION p20130609 VALUES LESS THAN (to_days('2013-06-09')) ENGINE = InnoDB,
PARTITION p20130610 VALUES LESS THAN (to_days('2013-06-10')) ENGINE = InnoDB,
PARTITION p20130611 VALUES LESS THAN (to_days('2013-06-11')) ENGINE = InnoDB,
PARTITION p20130612 VALUES LESS THAN (to_days('2013-06-12')) ENGINE = InnoDB,
PARTITION p20130613 VALUES LESS THAN (to_days('2013-06-13')) ENGINE = InnoDB
);


CREATE TABLE `myawr_snapshot_file_summary_by_event_name` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `EVENT_NAME` varchar(128) NOT NULL,
  `COUNT_READ` bigint(20) unsigned NOT NULL,
  `COUNT_WRITE` bigint(20) unsigned NOT NULL,
  `SUM_NUMBER_OF_BYTES_READ` bigint(20) unsigned NOT NULL,
  `SUM_NUMBER_OF_BYTES_WRITE` bigint(20) unsigned NOT NULL,
  `snap_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_file_summary_by_event_snap_time` (`snap_time`),
  KEY `idx_file_summary_by_event_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_file_summary_by_event_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1022861 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p20130510 VALUES LESS THAN (to_days('2013-05-10')) ENGINE = InnoDB,
PARTITION p20130511 VALUES LESS THAN (to_days('2013-05-11')) ENGINE = InnoDB,
PARTITION p20130512 VALUES LESS THAN (to_days('2013-05-12')) ENGINE = InnoDB,
PARTITION p20130513 VALUES LESS THAN (to_days('2013-05-13')) ENGINE = InnoDB,
PARTITION p20130514 VALUES LESS THAN (to_days('2013-05-14')) ENGINE = InnoDB,
PARTITION p20130515 VALUES LESS THAN (to_days('2013-05-15')) ENGINE = InnoDB,
PARTITION p20130516 VALUES LESS THAN (to_days('2013-05-16')) ENGINE = InnoDB,
PARTITION p20130517 VALUES LESS THAN (to_days('2013-05-17')) ENGINE = InnoDB,
PARTITION p20130518 VALUES LESS THAN (to_days('2013-05-18')) ENGINE = InnoDB,
PARTITION p20130519 VALUES LESS THAN (to_days('2013-05-19')) ENGINE = InnoDB,
PARTITION p20130520 VALUES LESS THAN (to_days('2013-05-20')) ENGINE = InnoDB,
PARTITION p20130521 VALUES LESS THAN (to_days('2013-05-21')) ENGINE = InnoDB,
PARTITION p20130522 VALUES LESS THAN (to_days('2013-05-22')) ENGINE = InnoDB,
PARTITION p20130523 VALUES LESS THAN (to_days('2013-05-23')) ENGINE = InnoDB,
PARTITION p20130524 VALUES LESS THAN (to_days('2013-05-24')) ENGINE = InnoDB,
PARTITION p20130525 VALUES LESS THAN (to_days('2013-05-25')) ENGINE = InnoDB,
PARTITION p20130526 VALUES LESS THAN (to_days('2013-05-26')) ENGINE = InnoDB,
PARTITION p20130527 VALUES LESS THAN (to_days('2013-05-27')) ENGINE = InnoDB,
PARTITION p20130528 VALUES LESS THAN (to_days('2013-05-28')) ENGINE = InnoDB,
PARTITION p20130529 VALUES LESS THAN (to_days('2013-05-29')) ENGINE = InnoDB,
PARTITION p20130530 VALUES LESS THAN (to_days('2013-05-30')) ENGINE = InnoDB,
PARTITION p20130531 VALUES LESS THAN (to_days('2013-05-31')) ENGINE = InnoDB,
PARTITION p20130601 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p20130602 VALUES LESS THAN (to_days('2013-06-02')) ENGINE = InnoDB,
PARTITION p20130603 VALUES LESS THAN (to_days('2013-06-03')) ENGINE = InnoDB,
PARTITION p20130604 VALUES LESS THAN (to_days('2013-06-04')) ENGINE = InnoDB,
PARTITION p20130605 VALUES LESS THAN (to_days('2013-06-05')) ENGINE = InnoDB,
PARTITION p20130606 VALUES LESS THAN (to_days('2013-06-06')) ENGINE = InnoDB,
PARTITION p20130607 VALUES LESS THAN (to_days('2013-06-07')) ENGINE = InnoDB,
PARTITION p20130608 VALUES LESS THAN (to_days('2013-06-08')) ENGINE = InnoDB,
PARTITION p20130609 VALUES LESS THAN (to_days('2013-06-09')) ENGINE = InnoDB,
PARTITION p20130610 VALUES LESS THAN (to_days('2013-06-10')) ENGINE = InnoDB,
PARTITION p20130611 VALUES LESS THAN (to_days('2013-06-11')) ENGINE = InnoDB,
PARTITION p20130612 VALUES LESS THAN (to_days('2013-06-12')) ENGINE = InnoDB,
PARTITION p20130613 VALUES LESS THAN (to_days('2013-06-13')) ENGINE = InnoDB
);


CREATE TABLE `myawr_snapshot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `snap_time` datetime NOT NULL,
  `snap_id` int(11) DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_snapshot_snap_time` (`snap_time`),
  KEY `idx_myawr_snapshot_host_id` (`host_id`,`snap_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22805 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);


CREATE TABLE `myawr_swap_net_disk_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `swap_in` float(10,2) DEFAULT NULL,
  `swap_out` float(10,2) DEFAULT NULL,
  `net_recv` float(10,2) DEFAULT NULL,
  `net_send` float(10,2) DEFAULT NULL,
  `file_system` varchar(50) DEFAULT NULL,
  `total_mb` float(10,2) DEFAULT NULL,
  `used_mb` float(10,2) DEFAULT NULL,
  `used_pct` float(10,2) DEFAULT NULL,
  `mount_point` varchar(50) DEFAULT NULL,
  `snap_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`,`snap_time`),
  KEY `idx_myawr_swap_net_info_snap_time` (`snap_time`),
  KEY `idx_myawr_swap_net_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_swap_net_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22817 DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(snap_time))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);

CREATE TABLE `myawr_query_review_history` (
  `hostid_max` int(11) DEFAULT NULL,
  `db_max` varchar(64) DEFAULT NULL,
  `checksum` bigint(20) unsigned NOT NULL,
  `sample` text NOT NULL,
  `ts_min` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ts_max` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ts_cnt` float DEFAULT NULL,
  `Query_time_sum` float DEFAULT NULL,
  `Query_time_min` float DEFAULT NULL,
  `Query_time_max` float DEFAULT NULL,
  `Query_time_pct_95` float DEFAULT NULL,
  `Query_time_stddev` float DEFAULT NULL,
  `Query_time_median` float DEFAULT NULL,
  `Lock_time_sum` float DEFAULT NULL,
  `Lock_time_min` float DEFAULT NULL,
  `Lock_time_max` float DEFAULT NULL,
  `Lock_time_pct_95` float DEFAULT NULL,
  `Lock_time_stddev` float DEFAULT NULL,
  `Lock_time_median` float DEFAULT NULL,
  `Rows_sent_sum` float DEFAULT NULL,
  `Rows_sent_min` float DEFAULT NULL,
  `Rows_sent_max` float DEFAULT NULL,
  `Rows_sent_pct_95` float DEFAULT NULL,
  `Rows_sent_stddev` float DEFAULT NULL,
  `Rows_sent_median` float DEFAULT NULL,
  `Rows_examined_sum` float DEFAULT NULL,
  `Rows_examined_min` float DEFAULT NULL,
  `Rows_examined_max` float DEFAULT NULL,
  `Rows_examined_pct_95` float DEFAULT NULL,
  `Rows_examined_stddev` float DEFAULT NULL,
  `Rows_examined_median` float DEFAULT NULL,
  `Rows_affected_sum` float DEFAULT NULL,
  `Rows_affected_min` float DEFAULT NULL,
  `Rows_affected_max` float DEFAULT NULL,
  `Rows_affected_pct_95` float DEFAULT NULL,
  `Rows_affected_stddev` float DEFAULT NULL,
  `Rows_affected_median` float DEFAULT NULL,
  `Rows_read_sum` float DEFAULT NULL,
  `Rows_read_min` float DEFAULT NULL,
  `Rows_read_max` float DEFAULT NULL,
  `Rows_read_pct_95` float DEFAULT NULL,
  `Rows_read_stddev` float DEFAULT NULL,
  `Rows_read_median` float DEFAULT NULL,
  `Merge_passes_sum` float DEFAULT NULL,
  `Merge_passes_min` float DEFAULT NULL,
  `Merge_passes_max` float DEFAULT NULL,
  `Merge_passes_pct_95` float DEFAULT NULL,
  `Merge_passes_stddev` float DEFAULT NULL,
  `Merge_passes_median` float DEFAULT NULL,
  `InnoDB_IO_r_ops_min` float DEFAULT NULL,
  `InnoDB_IO_r_ops_max` float DEFAULT NULL,
  `InnoDB_IO_r_ops_pct_95` float DEFAULT NULL,
  `InnoDB_IO_r_ops_stddev` float DEFAULT NULL,
  `InnoDB_IO_r_ops_median` float DEFAULT NULL,
  `InnoDB_IO_r_bytes_min` float DEFAULT NULL,
  `InnoDB_IO_r_bytes_max` float DEFAULT NULL,
  `InnoDB_IO_r_bytes_pct_95` float DEFAULT NULL,
  `InnoDB_IO_r_bytes_stddev` float DEFAULT NULL,
  `InnoDB_IO_r_bytes_median` float DEFAULT NULL,
  `InnoDB_IO_r_wait_min` float DEFAULT NULL,
  `InnoDB_IO_r_wait_max` float DEFAULT NULL,
  `InnoDB_IO_r_wait_pct_95` float DEFAULT NULL,
  `InnoDB_IO_r_wait_stddev` float DEFAULT NULL,
  `InnoDB_IO_r_wait_median` float DEFAULT NULL,
  `InnoDB_rec_lock_wait_min` float DEFAULT NULL,
  `InnoDB_rec_lock_wait_max` float DEFAULT NULL,
  `InnoDB_rec_lock_wait_pct_95` float DEFAULT NULL,
  `InnoDB_rec_lock_wait_stddev` float DEFAULT NULL,
  `InnoDB_rec_lock_wait_median` float DEFAULT NULL,
  `InnoDB_queue_wait_min` float DEFAULT NULL,
  `InnoDB_queue_wait_max` float DEFAULT NULL,
  `InnoDB_queue_wait_pct_95` float DEFAULT NULL,
  `InnoDB_queue_wait_stddev` float DEFAULT NULL,
  `InnoDB_queue_wait_median` float DEFAULT NULL,
  `InnoDB_pages_distinct_min` float DEFAULT NULL,
  `InnoDB_pages_distinct_max` float DEFAULT NULL,
  `InnoDB_pages_distinct_pct_95` float DEFAULT NULL,
  `InnoDB_pages_distinct_stddev` float DEFAULT NULL,
  `InnoDB_pages_distinct_median` float DEFAULT NULL,
  `QC_Hit_cnt` float DEFAULT NULL,
  `QC_Hit_sum` float DEFAULT NULL,
  `Full_scan_cnt` float DEFAULT NULL,
  `Full_scan_sum` float DEFAULT NULL,
  `Full_join_cnt` float DEFAULT NULL,
  `Full_join_sum` float DEFAULT NULL,
  `Tmp_table_cnt` float DEFAULT NULL,
  `Tmp_table_sum` float DEFAULT NULL,
  `Tmp_table_on_disk_cnt` float DEFAULT NULL,
  `Tmp_table_on_disk_sum` float DEFAULT NULL,
  `Filesort_cnt` float DEFAULT NULL,
  `Filesort_sum` float DEFAULT NULL,
  `Filesort_on_disk_cnt` float DEFAULT NULL,
  `Filesort_on_disk_sum` float DEFAULT NULL,
  PRIMARY KEY (`checksum`,`ts_min`,`ts_max`),
  KEY `idx_myawr_query_review_history_host_id` (`hostid_max`,`ts_max`),
  KEY `idx_myawr_query_review_history_ts_max` (`ts_max`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
PARTITION BY RANGE (to_days(ts_max))
(
PARTITION p1305 VALUES LESS THAN (to_days('2013-06-01')) ENGINE = InnoDB,
PARTITION p1306 VALUES LESS THAN (to_days('2013-07-01')) ENGINE = InnoDB,
PARTITION p1307 VALUES LESS THAN (to_days('2013-08-01')) ENGINE = InnoDB,
PARTITION p1308 VALUES LESS THAN (to_days('2013-09-01')) ENGINE = InnoDB,
PARTITION p1309 VALUES LESS THAN (to_days('2013-10-01')) ENGINE = InnoDB,
PARTITION p1310 VALUES LESS THAN (to_days('2013-11-01')) ENGINE = InnoDB,
PARTITION p1311 VALUES LESS THAN (to_days('2013-12-01')) ENGINE = InnoDB,
PARTITION p1312 VALUES LESS THAN (to_days('2014-01-01')) ENGINE = InnoDB
);






insert into myawr_cpu_info select * from myawr_cpu_info_old;
insert into myawr_innodb_info select * from myawr_innodb_info_old;                                      
insert into myawr_io_info                                            select * from myawr_io_info_old                                             ;
insert into myawr_isam_info                                          select * from myawr_isam_info_old                                           ;
insert into myawr_load_info                                          select * from myawr_load_info_old                                           ;
insert into myawr_mysql_info                                         select * from myawr_mysql_info_old                                          ;
insert into myawr_query_review_history                               select * from myawr_query_review_history_old                                ;
insert into myawr_snapshot                                           select * from myawr_snapshot_old                                            ;
insert into myawr_snapshot_events_waits_summary_global_by_event_name select * from myawr_snapshot_events_waits_summary_global_by_event_name_old  ;
insert into myawr_snapshot_file_summary_by_event_name                select * from myawr_snapshot_file_summary_by_event_name_old                 ;
insert into myawr_swap_net_disk_info                                 select * from myawr_swap_net_disk_info_old                                  ;


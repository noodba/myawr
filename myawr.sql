CREATE DATABASE `myawr`  DEFAULT CHARACTER SET utf8;

grant all on myawr.* to 'user'@'localhost' identified by "111111";

CREATE TABLE `myawr_host` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_name` varchar(50) NOT NULL,
  `ip_addr`  varchar(50) NOT NULL,
  `port` int(11) NOT NULL DEFAULT '3306',
  `db_role`  varchar(50) NOT NULL,
  `version` varchar(50) NOT NULL,
  `uptime`  varchar(50) NOT NULL,
  `check_time`  datetime,  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `myawr_snapshot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `snap_time` datetime NOT NULL,
  `snap_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_myawr_snapshot_host_id` (`host_id`,`snap_id`)
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_snapshot_events_waits_summary_by_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `EVENT_NAME` varchar(128) NOT NULL,
  `OBJECT_INSTANCE_BEGIN` bigint(20) NOT NULL,
  `COUNT_STAR` bigint(20) unsigned NOT NULL,
  `SUM_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `MIN_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `AVG_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  `MAX_TIMER_WAIT` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_waits_summary_by_instance_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_waits_summary_by_instance_host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


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
  PRIMARY KEY (`id`),
  KEY `idx_waits_summary_global_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_waits_summary_global_host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_snapshot_file_summary_by_event_name` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `EVENT_NAME` varchar(128) NOT NULL,
  `COUNT_READ` bigint(20) unsigned NOT NULL,
  `COUNT_WRITE` bigint(20) unsigned NOT NULL,
  `SUM_NUMBER_OF_BYTES_READ` bigint(20) unsigned NOT NULL,
  `SUM_NUMBER_OF_BYTES_WRITE` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_file_summary_by_event_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_file_summary_by_event_host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_snapshot_file_summary_by_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `FILE_NAME` varchar(512) NOT NULL,
  `EVENT_NAME` varchar(128) NOT NULL,
  `COUNT_READ` bigint(20) unsigned NOT NULL,
  `COUNT_WRITE` bigint(20) unsigned NOT NULL,
  `SUM_NUMBER_OF_BYTES_READ` bigint(20) unsigned NOT NULL,
  `SUM_NUMBER_OF_BYTES_WRITE` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_file_summary_by_instance_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_file_summary_by_instance_host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




CREATE TABLE `myawr_load_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `load1`  float(10,2) ,
  `load5`  float(10,2) ,
  `load15`  float(10,2) ,
  PRIMARY KEY (`id`),
  KEY `idx_myawr_load_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_load_info_host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_cpu_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `cpu_user`   float(10,2) ,
  `cpu_system`  float(10,2) ,
  `cpu_idle`  float(10,2) ,
  `cpu_iowait`  float(10,2) ,
  KEY `idx_myawr_cpu_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_cpu_info_host_id` (`host_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  PRIMARY KEY (`id`),
  KEY `idx_myawr_swap_net_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_swap_net_info_host_id` (`host_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_io_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `rd_ios_s`  float(10,2) ,
  `wr_ios_s`  float(10,2) ,
  `rkbs`  float(10,2) ,
  `wkbs`  float(10,2) ,
  `queue`  float(10,2) ,
  `wait`  float(10,2) ,
  `svc_t`  float(10,2) ,
  `busy`  float(10,2) ,
  KEY `idx_myawr_io_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_io_info_host_id` (`host_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE myawr_mysql_info (
  id bigint(20) NOT NULL AUTO_INCREMENT,
  snap_id int(11) NOT NULL,
  host_id int(11) NOT NULL,
  query_cache_size   float(26,2) ,
  thread_cache_size   float(26,2) ,
  table_definition_cache   float(26,2) ,
  max_connections   float(26,2) ,
  table_open_cache   float(26,2) ,
  slow_launch_time   float(26,2) ,
  log_slow_queries   float(26,2) ,
  max_heap_table_size   float(26,2) ,
  tmp_table_size   float(26,2) , 
  open_files_limit   float(26,2) ,
  Max_used_connections   float(26,2) ,
  Threads_connected   float(26,2) ,
  Threads_cached   float(26,2) ,   
  Threads_created   float(26,2) ,  
  Threads_running   float(26,2) ,
  Connections   float(26,2) ,
  Questions   float(26,2) ,
  Com_select float(26,2) ,
  Com_insert float(26,2) ,
  Com_update float(26,2) ,
  Com_delete  float(26,2) ,
  Bytes_received   float(26,2) ,
  Bytes_sent   float(26,2) ,
  Qcache_hits   float(26,2) ,            
  Qcache_inserts   float(26,2) ,
  Select_full_join   float(26,2) ,
  Select_scan   float(26,2) ,
  Slow_queries   float(26,2) ,
  Com_commit   float(26,2) ,
  Com_rollback   float(26,2) ,
  Open_files   float(26,2) ,              
  Open_table_definitions   float(26,2) ,  
  Open_tables   float(26,2) ,             
  Opened_files   float(26,2) ,            
  Opened_table_definitions   float(26,2) ,
  Opened_tables   float(26,2) ,
  Created_tmp_disk_tables   float(26,2) ,
  Created_tmp_files   float(26,2) ,      
  Created_tmp_tables   float(26,2) ,
  Binlog_cache_disk_use   float(26,2) ,
  Binlog_cache_use   float(26,2) ,
  Aborted_clients    float(26,2) ,
  Sort_merge_passes       float(26,2) ,
  Sort_range              float(26,2) ,
  Sort_rows               float(26,2) ,
  Sort_scan               float(26,2) ,
  Table_locks_immediate   float(26,2) , 
  Table_locks_waited      float(26,2) ,
  Handler_read_first      float(26,2) ,
  Handler_read_key        float(26,2) ,
  Handler_read_last       float(26,2) ,
  Handler_read_next       float(26,2) ,
  Handler_read_prev       float(26,2) ,
  Handler_read_rnd        float(26,2) ,
  Handler_read_rnd_next   float(26,2) ,
  KEY idx_myawr_mysql_info_snap_host_id (snap_id,host_id),
  KEY idx_myawr_mysql_info_host_id (host_id),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_innodb_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `Innodb_rows_inserted`  float(26,2) ,
  `Innodb_rows_updated`  float(26,2) ,
  `Innodb_rows_deleted`  float(26,2) ,
  `Innodb_rows_read`  float(26,2) ,
  `Innodb_buffer_pool_read_requests`  float(26,2) ,
  `Innodb_buffer_pool_reads`  float(26,2) ,
  `Innodb_buffer_pool_pages_data`  float(26,2) ,
  `Innodb_buffer_pool_pages_free`  float(26,2) ,
  `Innodb_buffer_pool_pages_dirty`  float(26,2) ,
  `Innodb_buffer_pool_pages_flushed`  float(26,2) ,
  `Innodb_data_reads`  float(26,2) ,
  `Innodb_data_writes`  float(26,2) ,
  `Innodb_data_read`  float(26,2) ,
  `Innodb_data_written`  float(26,2) ,
  `Innodb_os_log_fsyncs`  float(26,2) ,
  `Innodb_os_log_written`  float(26,2) ,
  `history_list`  float(26,2) ,
  `log_bytes_written`  float(26,2) ,
  `log_bytes_flushed`  float(26,2) ,
  `last_checkpoint`  float(26,2) ,
  `queries_inside`  float(26,2) ,
  `queries_queued`  float(26,2) ,
  `read_views`  float(26,2) ,
   innodb_open_files   float(26,2) ,
   innodb_log_waits   float(26,2) ,
  KEY `idx_myawr_mysql_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_mysql_info_host_id` (`host_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_isam_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `snap_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  key_buffer_size   float(26,2),
  join_buffer_size   float(26,2),
	sort_buffer_size   float(26,2),
	Key_blocks_not_flushed   float(26,2),
	Key_blocks_unused   float(26,2),     
	Key_blocks_used   float(26,2),       
	Key_read_requests   float(26,2),     
	Key_reads   float(26,2),             
	Key_write_requests   float(26,2),    
	Key_writes   float(26,2), 
  KEY `idx_myawr_mysql_info_snap_host_id` (`snap_id`,`host_id`),
  KEY `idx_myawr_mysql_info_host_id` (`host_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `myawr_query_review` (
  `checksum` bigint(20) unsigned NOT NULL,
  `fingerprint` text NOT NULL,
  `sample` longtext NOT NULL,
  `first_seen` datetime DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  `reviewed_by` varchar(20) DEFAULT NULL,
  `reviewed_on` datetime DEFAULT NULL,
  `comments` text,
  `reviewed_status` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`checksum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


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
  KEY `idx_myawr_query_review_history_host_id` (`hostid_max`),
  PRIMARY KEY (`checksum`,`ts_min`,`ts_max`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

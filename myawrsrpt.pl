use strict;
use Getopt::Long;     
use POSIX qw(strftime);     
use Socket;    

Getopt::Long::Configure qw(no_ignore_case);    

my %opt;
   

# Options
#----->
my $tid;
my $port = 3306;              
my $user = "user";
my $pswd;
my $lhost;

my $rprint = 60;

my $iscontinue=0;
my $myawrrpt_head=
'<html lang="en"><head><title>Mysql Snapshot Report</title>
<style type="text/css">
/* roScripts
Table Design by Mihalcea Romeo
www.roscripts.com
----------------------------------------------- */
table { border-collapse:collapse;
  	background:#EFF4FB url(http://www.roscripts.com/images/teaser.gif) repeat-x;
		border-left:1px solid #686868;
		border-right:1px solid #686868;
		font:0.8em/145% "Trebuchet MS",helvetica,arial,verdana;
		color: #333;}
td, th {padding:1px;}
caption {padding: 0 0 .5em 0;
		text-align: left;
		font-size: 1.4em;
		font-weight: bold;
		text-transform: uppercase;
		color: #333;
		background: transparent;}
/* =links----------------------------------------------- */
table a {color:#950000;	text-decoration:none;}
table a:link {}
table a:visited {font-weight:normal;color:#666;text-decoration: line-through;}
table a:hover {	border-bottom: 1px dashed #bbb;}
/* =head =foot----------------------------------------------- */
thead th, tfoot th, tfoot td {background:#333 url(http://www.roscripts.com/images/llsh.gif) repeat-x;color:#fff}
tfoot td {		text-align:right}
/* =body----------------------------------------------- */
tbody th, tbody td {border-bottom: dotted 1px #333;}
tbody th {white-space: nowrap;}
tbody th a {color:#333;}
.odd {}
tbody tr:hover {background:#fafafa}
</style></head><body>
<h1 >
Mysql Snapshot Report
</h1>
<p /><hr />
';

my $myawrrpt_foot='<p /><h2>--------The      End -----------</h2></body></html>';

#<-----

my($host_name,$ip_addr,$port_num,$db_role,$version,$uptime,$old_end_snap_id);
my($start_snap_id,$end_snap_id,$rpt_file_name,$rcount,$start_snap_time,$end_snap_time,$start_unix_s,$end_unix_s,$snap_elapsed);
my($max_snap_id,$min_snap_id,$max_snap_time,$min_snap_time,$snap_interval,$max_unix_s,$mid_unix_s); 

my($start_query_cache_size,$start_thread_cache_size,$start_table_definition_cache,$start_max_connections,$start_table_open_cache,$start_slow_launch_time,$start_max_heap_table_size,$start_tmp_table_size,$start_open_files_limit,$start_Max_used_connections,$start_Threads_connected,$start_Threads_cached,$start_Threads_created,$start_Threads_running,$start_Connections,$start_Questions,$start_Com_select,$start_Com_insert,$start_Com_update,$start_Com_delete,$start_Bytes_received,$start_Bytes_sent,$start_Qcache_hits,$start_Qcache_inserts,$start_Select_full_join,$start_Select_scan,$start_Slow_queries,$start_Com_commit,$start_Com_rollback,$start_Open_files,$start_Open_table_definitions,$start_Open_tables,$start_Opened_files,$start_Opened_table_definitions,$start_Opened_tables,$start_Created_tmp_disk_tables,$start_Created_tmp_files,$start_Created_tmp_tables,$start_Binlog_cache_disk_use,$start_Binlog_cache_use,$start_Aborted_clients,$start_Sort_merge_passes,$start_Sort_range,$start_Sort_rows,$start_Sort_scan,$start_Table_locks_immediate,$start_Table_locks_waited,$start_Handler_read_first,$start_Handler_read_key,$start_Handler_read_last,$start_Handler_read_next,$start_Handler_read_prev,$start_Handler_read_rnd,$start_Handler_read_rnd_next);
my($start_Innodb_rows_inserted,$start_Innodb_rows_updated,$start_Innodb_rows_deleted,$start_Innodb_rows_read,$start_Innodb_buffer_pool_read_requests,$start_Innodb_buffer_pool_reads,$start_Innodb_buffer_pool_pages_data,$start_Innodb_buffer_pool_pages_free,$start_Innodb_buffer_pool_pages_dirty,$start_Innodb_buffer_pool_pages_flushed,$start_Innodb_data_reads,$start_Innodb_data_writes,$start_Innodb_data_read,$start_Innodb_data_written,$start_Innodb_os_log_fsyncs,$start_Innodb_os_log_written,$start_history_list,$start_log_bytes_written,$start_log_bytes_flushed,$start_last_checkpoint,$start_queries_inside,$start_queries_queued,$start_read_views,$start_innodb_open_files,$start_innodb_log_waits) ;
my($start_key_buffer_size,$start_join_buffer_size,$start_sort_buffer_size,$start_Key_blocks_not_flushed,$start_Key_blocks_unused,$start_Key_blocks_used,$start_Key_read_requests,$start_Key_reads,$start_Key_write_requests,$start_Key_writes);

my($end_query_cache_size,$end_thread_cache_size,$end_table_definition_cache,$end_max_connections,$end_table_open_cache,$end_slow_launch_time,$end_max_heap_table_size,$end_tmp_table_size,$end_open_files_limit,$end_Max_used_connections,$end_Threads_connected,$end_Threads_cached,$end_Threads_created,$end_Threads_running,$end_Connections,$end_Questions,$end_Com_select,$end_Com_insert,$end_Com_update,$end_Com_delete,$end_Bytes_received,$end_Bytes_sent,$end_Qcache_hits,$end_Qcache_inserts,$end_Select_full_join,$end_Select_scan,$end_Slow_queries,$end_Com_commit,$end_Com_rollback,$end_Open_files,$end_Open_table_definitions,$end_Open_tables,$end_Opened_files,$end_Opened_table_definitions,$end_Opened_tables,$end_Created_tmp_disk_tables,$end_Created_tmp_files,$end_Created_tmp_tables,$end_Binlog_cache_disk_use,$end_Binlog_cache_use,$end_Aborted_clients,$end_Sort_merge_passes,$end_Sort_range,$end_Sort_rows,$end_Sort_scan,$end_Table_locks_immediate,$end_Table_locks_waited,$end_Handler_read_first,$end_Handler_read_key,$end_Handler_read_last,$end_Handler_read_next,$end_Handler_read_prev,$end_Handler_read_rnd,$end_Handler_read_rnd_next);
my($end_Innodb_rows_inserted,$end_Innodb_rows_updated,$end_Innodb_rows_deleted,$end_Innodb_rows_read,$end_Innodb_buffer_pool_read_requests,$end_Innodb_buffer_pool_reads,$end_Innodb_buffer_pool_pages_data,$end_Innodb_buffer_pool_pages_free,$end_Innodb_buffer_pool_pages_dirty,$end_Innodb_buffer_pool_pages_flushed,$end_Innodb_data_reads,$end_Innodb_data_writes,$end_Innodb_data_read,$end_Innodb_data_written,$end_Innodb_os_log_fsyncs,$end_Innodb_os_log_written,$end_history_list,$end_log_bytes_written,$end_log_bytes_flushed,$end_last_checkpoint,$end_queries_inside,$end_queries_queued,$end_read_views,$end_innodb_open_files,$end_innodb_log_waits) ;
my($end_key_buffer_size,$end_join_buffer_size,$end_sort_buffer_size,$end_Key_blocks_not_flushed,$end_Key_blocks_unused,$end_Key_blocks_used,$end_Key_read_requests,$end_Key_reads,$end_Key_write_requests,$end_Key_writes);

my($tps,$sec_Com_select,$sec_Com_insert,$sec_Com_update,$sec_Com_delete,$Innodb_tps);
my($sec_Innodb_rows_inserted,$sec_Innodb_rows_updated,$sec_Innodb_rows_deleted,$sec_Innodb_data_reads,$sec_Innodb_data_read);
my($sec_Innodb_data_writes,$sec_Innodb_rows_read,$sec_Innodb_data_written,$sec_Innodb_os_log_fsyncs,$sec_Innodb_os_log_written);



# Get options info
&get_options();

&get_snapinfo();


&get_myawrrpt() if $iscontinue==1;

# ----------------------------------------------------------------------------------------
# 
# Func :  print usage
# ----------------------------------------------------------------------------------------
sub print_usage {

	#print BLUE(),BOLD(),<<EOF,RESET();
	print <<EOF;

==========================================================================================
Info  :
        Created By noodba (www.noodba.com).

Usage :
Command line options :

   -h,--help           Print Help Info. 
  
   -P,--port           Port number to use for local mysql connection(default 3306).
   -u,--user           user name for local mysql(default user).
   -p,--pswd           user password for local mysql(can't be null).
   -lh,--lhost         localhost(ip) for mysql where info is got(can't be null).
   -n,--rname          file name for snapshot report(default "snaprpt_" + "hostid" + "_" + "snapid" + ".html").
   -s,--snapid         snap id(can't be null).

   -I,--tid            db instance register id(can't be null).    
  
Sample :
   shell> perl myawrrpt.pl -p 111111 -lh 192.168.1.111 -I 11 -s 26
==========================================================================================
EOF
	exit;
}

# ----------------------------------------------------------------------------------------
# 
# Func : get options and set option flag
# ----------------------------------------------------------------------------------------
sub get_options {

	# Get options info
	GetOptions(
		\%opt,
		'h|help',          # OUT : print help info
		'P|port=i',        # IN  : port
		'u|user=s',        # IN  : user
		'p|pswd=s',        # IN  : password
		'lh|lhost=s',      # IN  : host
		'n|rname=s',      # IN  : file name	
		's|snapid=s',      # IN  : snap id
		'I|tid=i',         # IN  : instance id
	) or print_usage();

	if ( !scalar(%opt) ) {
		&print_usage();
	}

	# Handle for options
	$opt{'h'}  and print_usage();
	$opt{'P'}  and $port = $opt{'P'};
	$opt{'u'}  and $user = $opt{'u'};
	$opt{'p'}  and $pswd = $opt{'p'};
	$opt{'lh'} and $lhost = $opt{'lh'};
    $opt{'n'} and $rpt_file_name = $opt{'n'};
	$opt{'s'} and $end_snap_id = $opt{'s'};
	$opt{'I'}  and $tid = $opt{'I'};

	if (
		!(
			defined $lhost
		    and defined $tid
		    and defined $end_snap_id
		)
	  )
	{
		&print_usage();
	}

   
	if(!(defined $rpt_file_name)) {
		$rpt_file_name="snaprpt_" . $tid . "_" . $end_snap_id . ".html";
	}
	if(-e $rpt_file_name){
		print "A file called this name:$rpt_file_name already exitsts!\n";
		exit;
	}
}


sub get_snapinfo {
    use DBI;
    
	use DBI qw(:sql_types);

    my $vars;
    my $sql;
    my $sth;
    
	my $dbh = DBI->connect( "DBI:mysql:database=myawr;host=$lhost;port=$port","$user", "$pswd", { 'RaiseError' => 0 ,AutoCommit => 1} );
	if(not $dbh) {
		exit;
	}
    

	#get max(snap_id) and min(snap_id) and snap interval
	($max_snap_id,$min_snap_id)=$dbh->selectrow_array("select max(snap_id) max_snap_id ,min(snap_id) min_snap_id from myawr.myawr_snapshot where host_id=$tid");
    ($host_name,$ip_addr,$port_num,$db_role,$version,$uptime)=$dbh->selectrow_array("select host_name,ip_addr,port,db_role,version,uptime from myawr_host where id=$tid");

print  "===================================================\n";
print  "|       Welcome to use the myawrrpt tool !   \n";
print  "|             Date: ",strftime ("%Y-%m-%d", localtime) . "\n";
print  "|\n";
print  "|      Hostname is: $host_name "  . "\n";
print  "|       Ip addr is: $ip_addr "  . "\n";
print  "|          Port is: $port_num "  . "\n";
print  "|       Db role is: $db_role "  . "\n";
print  "|Server version is: $version"  . "\n";
print  "|        Uptime is: $uptime"  . "\n";
print  "===================================================\n";		

    if(defined $max_snap_id and defined $min_snap_id  and $max_snap_id>=$min_snap_id+1){
		if ($end_snap_id>$min_snap_id and $end_snap_id<=$max_snap_id) {
			$start_snap_id=$end_snap_id-1;
		}elsif($end_snap_id==$min_snap_id){
			$old_end_snap_id=$end_snap_id;
			$start_snap_id=$end_snap_id;
			$end_snap_id=$end_snap_id+1;
		}else{
			print  "Pls check your snap id\n";
			exit;
        }

		$iscontinue=1;
		
		
    }else{
		print  "There may be just one snapshot\n";
    	
    	$dbh->disconnect();
    	exit;
    }

	$dbh->disconnect();
}



sub get_myawrrpt {
    use DBI;
    
	use DBI qw(:sql_types);

    my $vars;
    my $sql;
    my $sth;
    my $html_line;
    
	my $dbh = DBI->connect( "DBI:mysql:database=myawr;host=$lhost;port=$port","$user", "$pswd", { 'RaiseError' => 0 ,AutoCommit => 1} );
	if(not $dbh) {
		exit;
	}
    
    print  "\n";
    print "Generating the mysql report for this analysis ...";
    
	open MYAWR_REPORT , "> $rpt_file_name" or die ("Can't open $rpt_file_name for write! /n");
	print MYAWR_REPORT $myawrrpt_head; 
	
	
	$html_line=
	"
<p />
<table border=\"1\"  width=\"600\">
<tr><th>Host Name</th><th>Ip addr</th><th>Port</th><th>Db role</th><th>Version</th><th>Uptime</th></tr>
<tr><td>$host_name</td><td>$ip_addr</td><td align=\"right\"> $port_num</td><td align=\"right\"> $db_role</td><td align=\"right\"> $version</td><td align=\"right\"> $uptime</td></tr>
</table><p />
	";
	print MYAWR_REPORT $html_line;

   	$sth = $dbh->prepare("select host_id,snap_id,snap_time,UNIX_TIMESTAMP(snap_time) unix_s from myawr.myawr_snapshot where  host_id=$tid and snap_id in ($start_snap_id,$end_snap_id) order by snap_id asc");
	$sth->execute();

	my @result = $sth->fetchrow_array ;
	$start_snap_time=$result[2];
	$start_unix_s=$result[3];
	
	@result = $sth->fetchrow_array ;
	$end_snap_time=$result[2];
	$end_unix_s=$result[3];
	
	$snap_elapsed=$end_unix_s-$start_unix_s;

#print  $start_snap_id ."\n";
#print  $start_snap_time ."\n";

#print $end_snap_id ."\n";
#print  $end_snap_time ."\n";

($start_query_cache_size,$start_thread_cache_size,$start_table_definition_cache,$start_max_connections,$start_table_open_cache,$start_slow_launch_time,$start_max_heap_table_size,$start_tmp_table_size,$start_open_files_limit,$start_Max_used_connections,$start_Threads_connected,$start_Threads_cached,$start_Threads_created,$start_Threads_running,$start_Connections,$start_Questions,$start_Com_select,$start_Com_insert,$start_Com_update,$start_Com_delete,$start_Bytes_received,$start_Bytes_sent,$start_Qcache_hits,$start_Qcache_inserts,$start_Select_full_join,$start_Select_scan,$start_Slow_queries,$start_Com_commit,$start_Com_rollback,$start_Open_files,$start_Open_table_definitions,$start_Open_tables,$start_Opened_files,$start_Opened_table_definitions,$start_Opened_tables,$start_Created_tmp_disk_tables,$start_Created_tmp_files,$start_Created_tmp_tables,$start_Binlog_cache_disk_use,$start_Binlog_cache_use,$start_Aborted_clients,$start_Sort_merge_passes,$start_Sort_range,$start_Sort_rows,$start_Sort_scan,$start_Table_locks_immediate,$start_Table_locks_waited,$start_Handler_read_first,$start_Handler_read_key,$start_Handler_read_last,$start_Handler_read_next,$start_Handler_read_prev,$start_Handler_read_rnd,$start_Handler_read_rnd_next)=$dbh->selectrow_array("select query_cache_size,thread_cache_size,table_definition_cache,max_connections,table_open_cache,slow_launch_time,max_heap_table_size,tmp_table_size,open_files_limit,Max_used_connections,Threads_connected,Threads_cached,Threads_created,Threads_running,Connections,Questions,Com_select,Com_insert,Com_update,Com_delete,Bytes_received,Bytes_sent,Qcache_hits,Qcache_inserts,Select_full_join,Select_scan,Slow_queries,Com_commit,Com_rollback,Open_files,Open_table_definitions,Open_tables,Opened_files,Opened_table_definitions,Opened_tables,Created_tmp_disk_tables,Created_tmp_files,Created_tmp_tables,Binlog_cache_disk_use,Binlog_cache_use,Aborted_clients,Sort_merge_passes,Sort_range,Sort_rows,Sort_scan,Table_locks_immediate,Table_locks_waited,Handler_read_first,Handler_read_key,Handler_read_last,Handler_read_next,Handler_read_prev,Handler_read_rnd,Handler_read_rnd_next from myawr.myawr_mysql_info where host_id=$tid and snap_id=$start_snap_id and snap_time=\"$start_snap_time\"");
($start_Innodb_rows_inserted,$start_Innodb_rows_updated,$start_Innodb_rows_deleted,$start_Innodb_rows_read,$start_Innodb_buffer_pool_read_requests,$start_Innodb_buffer_pool_reads,$start_Innodb_buffer_pool_pages_data,$start_Innodb_buffer_pool_pages_free,$start_Innodb_buffer_pool_pages_dirty,$start_Innodb_buffer_pool_pages_flushed,$start_Innodb_data_reads,$start_Innodb_data_writes,$start_Innodb_data_read,$start_Innodb_data_written,$start_Innodb_os_log_fsyncs,$start_Innodb_os_log_written,$start_history_list,$start_log_bytes_written,$start_log_bytes_flushed,$start_last_checkpoint,$start_queries_inside,$start_queries_queued,$start_read_views,$start_innodb_open_files,$start_innodb_log_waits)=$dbh->selectrow_array("select Innodb_rows_inserted,Innodb_rows_updated,Innodb_rows_deleted,Innodb_rows_read,Innodb_buffer_pool_read_requests,Innodb_buffer_pool_reads,Innodb_buffer_pool_pages_data,  Innodb_buffer_pool_pages_free,  Innodb_buffer_pool_pages_dirty,  Innodb_buffer_pool_pages_flushed,  Innodb_data_reads,  Innodb_data_writes,  Innodb_data_read,  Innodb_data_written,  Innodb_os_log_fsyncs,  Innodb_os_log_written,  history_list,  log_bytes_written,  log_bytes_flushed,  last_checkpoint,  queries_inside,  queries_queued,  read_views, innodb_open_files,innodb_log_waits from myawr.myawr_innodb_info where host_id=$tid and snap_id=$start_snap_id and snap_time=\"$start_snap_time\"");
($start_key_buffer_size,$start_join_buffer_size,$start_sort_buffer_size,$start_Key_blocks_not_flushed,$start_Key_blocks_unused,$start_Key_blocks_used,$start_Key_read_requests,$start_Key_reads,$start_Key_write_requests,$start_Key_writes)=$dbh->selectrow_array("select key_buffer_size,join_buffer_size,sort_buffer_size,Key_blocks_not_flushed,Key_blocks_unused,Key_blocks_used,Key_read_requests,Key_reads,Key_write_requests,Key_writes from myawr.myawr_isam_info where host_id=$tid and snap_id=$start_snap_id and snap_time=\"$start_snap_time\"");

($end_query_cache_size,$end_thread_cache_size,$end_table_definition_cache,$end_max_connections,$end_table_open_cache,$end_slow_launch_time,$end_max_heap_table_size,$end_tmp_table_size,$end_open_files_limit,$end_Max_used_connections,$end_Threads_connected,$end_Threads_cached,$end_Threads_created,$end_Threads_running,$end_Connections,$end_Questions,$end_Com_select,$end_Com_insert,$end_Com_update,$end_Com_delete,$end_Bytes_received,$end_Bytes_sent,$end_Qcache_hits,$end_Qcache_inserts,$end_Select_full_join,$end_Select_scan,$end_Slow_queries,$end_Com_commit,$end_Com_rollback,$end_Open_files,$end_Open_table_definitions,$end_Open_tables,$end_Opened_files,$end_Opened_table_definitions,$end_Opened_tables,$end_Created_tmp_disk_tables,$end_Created_tmp_files,$end_Created_tmp_tables,$end_Binlog_cache_disk_use,$end_Binlog_cache_use,$end_Aborted_clients,$end_Sort_merge_passes,$end_Sort_range,$end_Sort_rows,$end_Sort_scan,$end_Table_locks_immediate,$end_Table_locks_waited,$end_Handler_read_first,$end_Handler_read_key,$end_Handler_read_last,$end_Handler_read_next,$end_Handler_read_prev,$end_Handler_read_rnd,$end_Handler_read_rnd_next)=$dbh->selectrow_array("select query_cache_size,thread_cache_size,table_definition_cache,max_connections,table_open_cache,slow_launch_time,max_heap_table_size,tmp_table_size,open_files_limit,Max_used_connections,Threads_connected,Threads_cached,Threads_created,Threads_running,Connections,Questions,Com_select,Com_insert,Com_update,Com_delete,Bytes_received,Bytes_sent,Qcache_hits,Qcache_inserts,Select_full_join,Select_scan,Slow_queries,Com_commit,Com_rollback,Open_files,Open_table_definitions,Open_tables,Opened_files,Opened_table_definitions,Opened_tables,Created_tmp_disk_tables,Created_tmp_files,Created_tmp_tables,Binlog_cache_disk_use,Binlog_cache_use,Aborted_clients,Sort_merge_passes,Sort_range,Sort_rows,Sort_scan,Table_locks_immediate,Table_locks_waited,Handler_read_first,Handler_read_key,Handler_read_last,Handler_read_next,Handler_read_prev,Handler_read_rnd,Handler_read_rnd_next from myawr.myawr_mysql_info where host_id=$tid and snap_id=$end_snap_id and snap_time=\"$end_snap_time\"");
($end_Innodb_rows_inserted,$end_Innodb_rows_updated,$end_Innodb_rows_deleted,$end_Innodb_rows_read,$end_Innodb_buffer_pool_read_requests,$end_Innodb_buffer_pool_reads,$end_Innodb_buffer_pool_pages_data,$end_Innodb_buffer_pool_pages_free,$end_Innodb_buffer_pool_pages_dirty,$end_Innodb_buffer_pool_pages_flushed,$end_Innodb_data_reads,$end_Innodb_data_writes,$end_Innodb_data_read,$end_Innodb_data_written,$end_Innodb_os_log_fsyncs,$end_Innodb_os_log_written,$end_history_list,$end_log_bytes_written,$end_log_bytes_flushed,$end_last_checkpoint,$end_queries_inside,$end_queries_queued,$end_read_views,$end_innodb_open_files,$end_innodb_log_waits)=$dbh->selectrow_array("select Innodb_rows_inserted,Innodb_rows_updated,Innodb_rows_deleted,Innodb_rows_read,Innodb_buffer_pool_read_requests,Innodb_buffer_pool_reads,Innodb_buffer_pool_pages_data,  Innodb_buffer_pool_pages_free,  Innodb_buffer_pool_pages_dirty,  Innodb_buffer_pool_pages_flushed,  Innodb_data_reads,  Innodb_data_writes,  Innodb_data_read,  Innodb_data_written,  Innodb_os_log_fsyncs,  Innodb_os_log_written,  history_list,  log_bytes_written,  log_bytes_flushed,  last_checkpoint,  queries_inside,  queries_queued,  read_views, innodb_open_files,innodb_log_waits from myawr.myawr_innodb_info where host_id=$tid and snap_id=$end_snap_id and snap_time=\"$end_snap_time\"");
($end_key_buffer_size,$end_join_buffer_size,$end_sort_buffer_size,$end_Key_blocks_not_flushed,$end_Key_blocks_unused,$end_Key_blocks_used,$end_Key_read_requests,$end_Key_reads,$end_Key_write_requests,$end_Key_writes)=$dbh->selectrow_array("select key_buffer_size,join_buffer_size,sort_buffer_size,Key_blocks_not_flushed,Key_blocks_unused,Key_blocks_used,Key_read_requests,Key_reads,Key_write_requests,Key_writes from myawr.myawr_isam_info where host_id=$tid and snap_id=$end_snap_id and snap_time=\"$end_snap_time\"");
	

	$html_line=
	"
<table border=\"1\" width=\"600\" >
<tr><th></th><th>Snap Id</th><th>Snap Time</th><th>Threads_connected</th><th>Threads_running</th></tr>
<tr><td>Snap:</td><td align=\"right\">$end_snap_id</td><td align=\"center\">$end_snap_time</td><td align=\"right\">$end_Threads_connected</td><td align=\"right\"> $end_Threads_running</td></tr>
</table><p />
	";
	
	
	print MYAWR_REPORT $html_line;
	
   my ($cpu_user,$cpu_system,$cpu_idle,$cpu_iowait,$load1)=$dbh->selectrow_array("select a.cpu_user,a.cpu_system,a.cpu_idle,a.cpu_iowait,b.load1 from myawr_cpu_info a,myawr_load_info b where a.host_id=b.host_id and a.snap_id=b.snap_id and a.host_id=$tid and a.snap_id=$end_snap_id and a.snap_time=\"$end_snap_time\" and b.snap_time=\"$end_snap_time\" ");

	$html_line=
	"
<table border=\"1\" width=\"600\" >
<tr><th>cpu_user</th><th>cpu_system</th><th>cpu_idle</th><th>cpu_iowait</th><th>load1</th></tr>
<tr><td>$cpu_user</td><td align=\"right\">$cpu_system</td><td align=\"center\">$cpu_idle</td><td align=\"right\">$cpu_iowait</td><td align=\"right\"> $load1</td></tr>
</table><p />
<hr />
	";

	print MYAWR_REPORT $html_line;
	
$tps=int((($end_Com_insert -$start_Com_insert)+($end_Com_update -$start_Com_update)+($end_Com_delete -$start_Com_delete))/$snap_elapsed) ;	
$sec_Com_select=int(($end_Com_select -$start_Com_select)/$snap_elapsed) ;	
$sec_Com_insert=int( ($end_Com_insert -$start_Com_insert)/$snap_elapsed ) ;	
$sec_Com_update=int(($end_Com_update -$start_Com_update)/$snap_elapsed ) ;	
$sec_Com_delete=int(($end_Com_delete -$start_Com_delete)/$snap_elapsed ) ;	
$Innodb_tps=int((($end_Innodb_rows_inserted -$start_Innodb_rows_inserted)+ ($end_Innodb_rows_updated -$start_Innodb_rows_updated)+($end_Innodb_rows_deleted -$start_Innodb_rows_deleted))/$snap_elapsed) ;

$sec_Innodb_rows_inserted=int( ($end_Innodb_rows_inserted -$start_Innodb_rows_inserted)/$snap_elapsed) ;	
$sec_Innodb_rows_updated=int(($end_Innodb_rows_updated -$start_Innodb_rows_updated)/$snap_elapsed) ;	
$sec_Innodb_rows_deleted=int(($end_Innodb_rows_deleted -$start_Innodb_rows_deleted)/$snap_elapsed ) ;	
$sec_Innodb_rows_read=int(($end_Innodb_rows_read -$start_Innodb_rows_read)/$snap_elapsed) ;	

$sec_Innodb_data_reads=int(($end_Innodb_data_reads -$start_Innodb_data_reads)/$snap_elapsed) ;	
$sec_Innodb_data_writes=int( ($end_Innodb_data_writes -$start_Innodb_data_writes)/$snap_elapsed) ;	


$sec_Innodb_data_written=int( ($end_Innodb_data_written -$start_Innodb_data_written)/$snap_elapsed/1024) ;	
$sec_Innodb_data_read=int( ($end_Innodb_data_read -$start_Innodb_data_read)/$snap_elapsed/1024) ;	
$sec_Innodb_os_log_fsyncs=int( ($end_Innodb_os_log_fsyncs -$start_Innodb_os_log_fsyncs)/$snap_elapsed ) ;	
$sec_Innodb_os_log_written=int(  ($end_Innodb_os_log_written -$start_Innodb_os_log_written)/$snap_elapsed/1024) ;

	$html_line =
	"
<p/><h3>Some Key Load Info</h3>  <p />
<table border=\"1\" width=\"500\">
<tr><th></th><th>Per Second</th></tr>
<tr><td>TPS:</td><td align=\"right\"> $tps</td></tr>
<tr><td>Com_select(s):</td><td align=\"right\"> $sec_Com_select </td></tr>
<tr><td>Com_insert(s):</td><td align=\"right\"> $sec_Com_insert</td></tr>
<tr><td>Com_update(s):</td><td align=\"right\"> $sec_Com_update</td></tr>
<tr><td>Com_delete(s):</td><td align=\"right\"> $sec_Com_delete</td></tr>
<tr><td>Innodb t_row PS:</td><td align=\"right\"> $Innodb_tps </td></tr>

<tr><td>Innodb_rows_inserted(s):</td><td align=\"right\">$sec_Innodb_rows_inserted </td></tr>
<tr><td>Innodb_rows_updated(s):</td><td align=\"right\"> $sec_Innodb_rows_updated </td></tr>
<tr><td>Innodb_rows_deleted(s):</td><td align=\"right\"> $sec_Innodb_rows_deleted</td></tr>
<tr><td>Innodb_rows_read(s):</td><td align=\"right\"> $sec_Innodb_rows_read </td></tr>

<tr><td>Innodb_data_reads(s):</td><td align=\"right\"> $sec_Innodb_data_reads </td></tr>
<tr><td>Innodb_data_writes(s):</td><td align=\"right\"> $sec_Innodb_data_writes</td></tr>

<tr><td>Innodb_data_read(kb/s):</td><td align=\"right\">$sec_Innodb_data_read </td></tr>
<tr><td>Innodb_data_written(kb/s):</td><td align=\"right\">$sec_Innodb_data_written </td></tr>

<tr><td>Innodb_os_log_fsyncs(s):</td><td align=\"right\">$sec_Innodb_os_log_fsyncs </td></tr>
<tr><td>Innodb_os_log_written(kb/s):</td><td align=\"right\">$sec_Innodb_os_log_written </td></tr>
</table><p /><hr />
	";
	print MYAWR_REPORT $html_line;	

my($key_buffer_read_hits,$key_buffer_write_hits,$Innodb_buffer_read_hits,$Query_cache_hits,$Thread_cache_hits);

if (($end_Key_read_requests-$start_Key_read_requests) >0) {
	$key_buffer_read_hits = int((1- ($end_Key_reads-$start_Key_reads)/($end_Key_read_requests-$start_Key_read_requests) ) * 10000 )/100;
}else{
	$key_buffer_read_hits = 0;
}

if(($end_Key_write_requests-$start_Key_write_requests) >0){
	$key_buffer_write_hits = int((1- ($end_Key_writes-$start_Key_writes)/($end_Key_write_requests-$start_Key_write_requests) ) * 10000)/100;
}else{
	$key_buffer_write_hits = 0
}

if(($end_Innodb_buffer_pool_read_requests - $start_Innodb_buffer_pool_read_requests) >0){
	$Innodb_buffer_read_hits = int((1 - ($end_Innodb_buffer_pool_reads - $start_Innodb_buffer_pool_reads) / ($end_Innodb_buffer_pool_read_requests - $start_Innodb_buffer_pool_read_requests)) * 10000)/100;
}else{
	$Innodb_buffer_read_hits = 0;
}

if(($end_Qcache_hits - $start_Qcache_hits + $end_Qcache_inserts - $start_Qcache_inserts )>0){
	$Query_cache_hits = int((($end_Qcache_hits - $start_Qcache_hits) / ($end_Qcache_hits - $start_Qcache_hits + $end_Qcache_inserts - $start_Qcache_inserts )) * 10000)/100;
}else{
	$Query_cache_hits =0;
}

if(($end_Connections - $start_Connections) >0){
	$Thread_cache_hits = int((1 - ($end_Threads_created-$start_Threads_created )/ ($end_Connections - $start_Connections) ) * 10000)/100;
}else{
	$Thread_cache_hits = 0;
}

	$html_line =
	"
<p /><h3>Some Key Hits</h3><p />
<table border=\"1\" width=\"600\">
<tr><th></th><th>Percentage</th></tr>
<tr><td>key_buffer_read_hits %:</td><td align=\"right\">$key_buffer_read_hits</td></tr>
<tr><td>key_buffer_write_hits %:</td><td align=\"right\">$key_buffer_write_hits</td></tr>
<tr><td>Innodb_buffer_read_hits %:</td><td align=\"right\">$Innodb_buffer_read_hits</td></tr>
<tr><td>Query_cache_hits %:</td><td align=\"right\">$Query_cache_hits</td></tr>
<tr><td>Thread_cache_hits %:</td><td align=\"right\">$Thread_cache_hits</td></tr>
</table><p /><p /><hr/>		
	";	
	
	print MYAWR_REPORT $html_line;	
	
	
    print MYAWR_REPORT "<p /><h3>Top 10 Timed Events</h3><p /><table border=\"1\" width=\"600\" > <tr><th>event_name</th><th>wait time(picsecond)</th><th>wait count</th></tr>";

		$sth = $dbh->prepare("select  b.EVENT_NAME ,b.SUM_TIMER_WAIT-a.SUM_TIMER_WAIT wait_time, b.COUNT_STAR-a.COUNT_STAR wait_count from (select * from myawr_snapshot_events_waits_summary_global_by_event_name where host_id=$tid and snap_id=$start_snap_id  and snap_time=\"$start_snap_time\") a, (select * from myawr_snapshot_events_waits_summary_global_by_event_name where host_id=$tid and snap_id=$end_snap_id and snap_time=\"$end_snap_time\") b WHERE a.EVENT_NAME=b.EVENT_NAME order by b.SUM_TIMER_WAIT-a.SUM_TIMER_WAIT desc limit 10");
		$sth->execute();
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
		  
    print MYAWR_REPORT "</table>";

    print MYAWR_REPORT "<p /><h3>Top 10 read file Events</h3><p />   <table border=\"1\" width=\"600\" > <tr><th>event_name</th><th>read bytes</th><th>read count</th></tr>";

		$sth = $dbh->prepare("select  b.EVENT_NAME ,b.SUM_NUMBER_OF_BYTES_READ-a.SUM_NUMBER_OF_BYTES_READ file_read, b.COUNT_READ-a.COUNT_READ read_count from (select * from myawr_snapshot_file_summary_by_event_name where host_id=$tid and snap_id=$start_snap_id and snap_time=\"$start_snap_time\") a, (select * from myawr_snapshot_file_summary_by_event_name where  host_id=$tid and snap_id=$end_snap_id  and snap_time=\"$end_snap_time\") b WHERE a.EVENT_NAME=b.EVENT_NAME order by b.SUM_NUMBER_OF_BYTES_READ-a.SUM_NUMBER_OF_BYTES_READ desc limit 10");
		$sth->execute();
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr>   <td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
		  
    print MYAWR_REPORT "</table>";	
			  	
    print MYAWR_REPORT "<p /><h3>Top 10 write file Events</h3><p /><table border=\"1\" width=\"600\" > <tr><th>event_name</th><th>read bytes</th><th>read count</th></tr>";

		$sth = $dbh->prepare("select  b.EVENT_NAME ,b.SUM_NUMBER_OF_BYTES_WRITE-a.SUM_NUMBER_OF_BYTES_WRITE file_write, b.COUNT_WRITE-a.COUNT_WRITE write_count from (select * from myawr_snapshot_file_summary_by_event_name where host_id=$tid and snap_id=$start_snap_id and snap_time=\"$start_snap_time\") a, (select * from myawr_snapshot_file_summary_by_event_name where  host_id=$tid and snap_id=$end_snap_id  and snap_time=\"$end_snap_time\") b WHERE a.EVENT_NAME=b.EVENT_NAME order by b.SUM_NUMBER_OF_BYTES_WRITE - a.SUM_NUMBER_OF_BYTES_WRITE desc limit 10");
		$sth->execute();
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td></tr>";  
	          print MYAWR_REPORT "\n";
		}
		  
    print MYAWR_REPORT "</table><p /><hr/><p />";	
		

 if($old_end_snap_id==$min_snap_id){
 		$sth = $dbh->prepare("select a.user,a.host,a.db,a.command,a.time,a.state,a.info from myawr_active_session a where a.snap_time=\"$start_snap_time\" and a.host_id=$tid  and a.snap_id=$start_snap_id ");
 	
 }else{
 		$sth = $dbh->prepare("select a.user,a.host,a.db,a.command,a.time,a.state,a.info from myawr_active_session a where a.snap_time=\"$end_snap_time\" and a.host_id=$tid  and a.snap_id=$end_snap_id ");
 	
 }
		$sth->execute();

	print MYAWR_REPORT "<p /><h3>Active session Info</h3><p /><table border=\"1\" > <tr><th>user</th><th>host</th><th>db</th><th>command</th><th>time</th><th>state</th><th>info</th></tr>";
				
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td><td>$result[3]</td><td>$result[4]</td><td>$result[5]</td><td>$result[6]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
    print MYAWR_REPORT "</table><p /><hr/><p />";


 if($old_end_snap_id==$min_snap_id){
 		$sth = $dbh->prepare("select a.trx_id,a.trx_state,a.trx_started,a.trx_requested_lock_id,a.trx_wait_started,a.trx_mysql_thread_id,a.trx_operation_state,a.trx_query from myawr_innodb_trx  a where a.snap_time=\"$start_snap_time\" and a.host_id=$tid  and a.snap_id=$start_snap_id ");
 	
 }else{
 		$sth = $dbh->prepare("select a.trx_id,a.trx_state,a.trx_started,a.trx_requested_lock_id,a.trx_wait_started,a.trx_mysql_thread_id,a.trx_operation_state,a.trx_query from myawr_innodb_trx  a where a.snap_time=\"$end_snap_time\" and a.host_id=$tid  and a.snap_id=$end_snap_id ");
 	
 }
		$sth->execute();

	print MYAWR_REPORT "<p /><h3>Innodb trx  Info</h3><p /><table border=\"1\" > <tr><th>trx_id</th><th>trx_state</th><th>trx_started</th><th>trx_requested_lock_id</th><th>trx_wait_started</th><th>trx_mysql_thread_id</th><th>trx_operation_state</th><th>trx_query</th></tr>";
				
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td><td>$result[3]</td><td>$result[4]</td><td>$result[5]</td><td>$result[6]</td><td>$result[7]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
    print MYAWR_REPORT "</table><p /><hr/><p />";	
    
 if($old_end_snap_id==$min_snap_id){
 		$sth = $dbh->prepare("select a.lock_id,a.lock_trx_id,a.lock_mode,a.lock_type, a.lock_table,a.lock_index,a.lock_space,a.lock_page,a.lock_rec,a.lock_data from myawr_innodb_locks a  where a.snap_time=\"$start_snap_time\" and a.host_id=$tid  and a.snap_id=$start_snap_id ");
 	
 }else{
 		$sth = $dbh->prepare("select a.lock_id,a.lock_trx_id,a.lock_mode,a.lock_type, a.lock_table,a.lock_index,a.lock_space,a.lock_page,a.lock_rec,a.lock_data from myawr_innodb_locks a  where a.snap_time=\"$end_snap_time\" and a.host_id=$tid  and a.snap_id=$end_snap_id ");
 	
 }
		$sth->execute();

	print MYAWR_REPORT "<p /><h3>Innodb Locks  Info</h3><p /><table border=\"1\" > <tr><th>lock_id</th><th>lock_trx_id</th><th>lock_mode</th><th>lock_type</th><th>lock_table</th><th>lock_index</th><th>lock_space</th><th>lock_page</th><th>lock_rec</th><th>lock_data</th></tr>";
				
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td><td>$result[3]</td><td>$result[4]</td><td>$result[5]</td><td>$result[6]</td><td>$result[7]</td><td>$result[8]</td><td>$result[9]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
    print MYAWR_REPORT "</table><p /><hr/><p />";
    
    
 if($old_end_snap_id==$min_snap_id){
 		$sth = $dbh->prepare("select a.requesting_trx_id,a.requested_lock_id,a.blocking_trx_id,a.blocking_lock_id from myawr_innodb_lock_waits a  where a.snap_time=\"$start_snap_time\" and a.host_id=$tid  and a.snap_id=$start_snap_id ");
 	
 }else{
 		$sth = $dbh->prepare("select a.requesting_trx_id,a.requested_lock_id,a.blocking_trx_id,a.blocking_lock_id from myawr_innodb_lock_waits a  where a.snap_time=\"$end_snap_time\" and a.host_id=$tid  and a.snap_id=$end_snap_id ");
 	
 }
		$sth->execute();

	print MYAWR_REPORT "<p /><h3>Innodb Locks Wait Info</h3><p /><table border=\"1\" > <tr><th>requesting_trx_id</th><th>requested_lock_id</th><th>blocking_trx_id</th><th>blocking_lock_id</th></tr>";
				
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td><td align=\"right\">$result[1]</td><td align=\"right\">$result[2]</td><td>$result[3]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
    print MYAWR_REPORT "</table><p /><hr/><p />";
    
 if($old_end_snap_id==$min_snap_id){
 		$sth = $dbh->prepare("select a.row_status from myawr_engine_innodb_status a  where a.snap_time=\"$start_snap_time\" and a.host_id=$tid  and a.snap_id=$start_snap_id  order by order_id asc");
 	
 }else{
 		$sth = $dbh->prepare("select a.row_status from myawr_engine_innodb_status a  where a.snap_time=\"$end_snap_time\" and a.host_id=$tid  and a.snap_id=$end_snap_id   order by order_id asc");
 	
 }
		$sth->execute();

	print MYAWR_REPORT "<p /><h3>Innodb  Status  Info</h3><p /><table border=\"1\" > <tr><th>innodb status</th></tr>";
				
		while( my @result = $sth->fetchrow_array )	{
			  print MYAWR_REPORT "<tr><td>$result[0]</td></tr>";  
	          print MYAWR_REPORT "\n";
		  }
    print MYAWR_REPORT "</table><p /><hr/><p />";            
    		  	
	print MYAWR_REPORT $myawrrpt_foot;
	close MYAWR_REPORT or die "can't close!";	


    print  "\n";
    print "Generate the mysql report Successfully.\n";
    
    $sth->finish;
	$dbh->disconnect();
}


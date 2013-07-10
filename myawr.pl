use strict;
use Getopt::Long;    # Usage Info URL:  http://perldoc.perl.org/Getopt/Long.html
use POSIX qw(strftime)
  ;    # Usage Info URL:  http://perldoc.perl.org/functions/localtime.html
use Socket;    # Get IP info

Getopt::Long::Configure qw(no_ignore_case);    #


( my $sript_name = $0 ) =~ s!.*/(.*)!$1! ;
my $is_running = `ps -ef | grep $sript_name | grep -v grep | wc -l`;
exit if($is_running>2) ;



my %opt;                                       # Get options info

# Options
#----->
my $interval = 1;                              # -i   : time(second) interval
my $disk     = "sda1";                         # -d   : print disk info
my $net      = "eth0";                         # -n   : print net info
my $tid;

my $port = 3306;                               # -P
my $user = "user";
my $pswd;
my $lhost;

my $tport = 3306;                              # -P
my $tuser = "user";
my $tpswd;
my $thost;

#<-----

my @sys_load;                                  # load

# Variables For :
#-----> Get SysInfo (from /proc/stat): CPU
my @sys_cpu1 = (0) x 8;
my @sys_cpu2;
my $total_1 = 0;
my $total_2;

#
my $user_diff;
my $system_diff;
my $idle_diff;
my $iowait_diff;

my $user_diff_1;
my $system_diff_1;
my $idle_diff_1;
my $iowait_diff_1;

#<----- Get SysInfo (from /proc/stat): CPU

#-----> Get SysInfo (from /proc/diskstats): IO
my @sys_io1 = (0) x 15;

#my $not_first  = 0;                                   # no print first value
my $ncpu = `grep processor /proc/cpuinfo | wc -l`;   #/* Number of processors */

# grep "HZ" -R /usr/include/*
# /usr/include/asm-x86_64/param.h:#define HZ 100
my $HZ = 100;

#<----- Get SysInfo (from /proc/diskstats): IO

#-----> Get SysInfo (from /proc/vmstat): SWAP
my %swap1 = (
	"pswpin"  => 0,
	"pswpout" => 0
);
my $swap_not_first = 0;
my %swap2;
my $swapin;
my $swapout;

#<----- Get SysInfo (from /proc/vmstat): SWAP

#-----> Get SysInfo (from /proc/net/dev): NET
my %net1 = (
	"recv" => 0,
	"send" => 0
);
my $net_not_first = 0;
my %net2;
my $diff_recv;
my $diff_send;

#<----- Get SysInfo (from /proc/net/dev): NET

#-----> Get SysInfo (from /proc/diskstats): IO
my $deltams;
my $n_ios;       #/* Number of requests */
my $n_ticks;     #/* Total service time */
my $n_kbytes;    #/* Total kbytes transferred */
my $busy;        #/* Utilization at disk       (percent) */
my $svc_t;       #/* Average disk service time */
my $wait;        #/* Average wait */
my $size;        #/* Average request size */
my $queue;       #/* Average queue */

my $rkbs;
my $wkbs;

# r/s  w/s
my $rd_ios_s;
my $wr_ios_s;

#<----- Get SysInfo (from /proc/diskstats): IO


my ( $filesystem, $totalmb, $usedmb, $freemb, $usedpct, $mountpoint );
my $snap_id;
my $snap_time;

# Get options info
&get_options();


&get_loadinfo();
&get_diskinfo();
&get_cpuinfo();
&get_swapinfo();
&get_netinfo();
&get_ioinfo();
sleep(1);
&get_cpuinfo();
&get_swapinfo();
&get_netinfo();
&get_ioinfo();


&get_osstat();

&get_mysqlstat();

&get_perfstat();

# ----------------------------------------------------------------------------------------
# 
# Func :  print usage
# ----------------------------------------------------------------------------------------
sub print_usage {

	#print BLUE(),BOLD(),<<EOF,RESET();
	print <<EOF;

==========================================================================================
Info  :
        Created(modified) By noodba (www.noodba.com) .
        References: orzdba.pl (zhuxu\@taobao.com)
Usage :
Command line options :

   -h,--help           Print Help Info. 
   -i,--interval       Time(second) Interval(default 1).  
   -d,--disk           Disk Info(can't be null).
   -n,--net            Net  Info(default eth0).
   
   -P,--port           Port number to use for local mysql connection(default 3306).
   -u,--user           user name for local mysql(default user).
   -p,--pswd           user password for local mysql(can't be null).
   -lh,--lhost          localhost(ip) for mysql where info is got(can't be null).
   
   -TP,--tport          Port number to use for  mysql where info is saved (default 3306).
   -tu,--tuser          user name for  mysql where info is saved(default user).
   -tp,--pswd           user password for mysql where info is saved(can't be null).
   -th,--thost          host(ip) for mysql where info is saved(can't be null).
   -I,--tid             db instance register id(can't be null).    
  
Sample :
   shell> perl myawr.pl -p 111111 -lh 192.168.1.111 -tp 111111 -th 192.168.1.200 -I 11
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
		'i|interval=i',    # IN  : time(second) interval
		'd|disk=s',        # IN  : print disk info
		'n|net=s',         # IN  : print info
		'P|port=i',        # IN  : port
		'u|user=s',        # IN  : user
		'p|pswd=s',        # IN  : password
		'lh|lhost=s',      # IN  : host		
		'tu|tuser=s',      # IN  : user
		'tp|tpswd=s',      # IN  : password
		'th|thost=s',      # IN  : host
		'TP|tport=i',      # IN  : port
		'I|tid=i',         # IN  : instance id
	) or print_usage();

	if ( !scalar(%opt) ) {
		&print_usage();
	}

	# Handle for options
	$opt{'h'}  and print_usage();
	$opt{'d'}  and $disk = $opt{'d'};
	$opt{'n'}  and $net = $opt{'n'};
	$opt{'P'}  and $port = $opt{'P'};
	$opt{'i'}  and $interval = $opt{'i'};
	$opt{'u'}  and $user = $opt{'u'};
	$opt{'p'}  and $pswd = $opt{'p'};
	$opt{'lh'} and $lhost = $opt{'lh'};
	$opt{'tu'} and $tuser = $opt{'tu'};
	$opt{'tp'} and $tpswd = $opt{'tp'};
	$opt{'th'} and $thost = $opt{'th'};
	$opt{'TP'} and $tport = $opt{'TP'};
	$opt{'I'}  and $tid = $opt{'I'};

	if (
		!(
			    defined $disk
			and defined $pswd
			and defined $lhost
			and defined $tpswd
			and defined $thost
			and defined $tid
		)
	  )
	{
		&print_usage();
	}
}

# ----------------------------------------------------------------------------------------
# 
# Func : get sys performance info
# ----------------------------------------------------------------------------------------
sub get_loadinfo {

	# 1. Get SysInfo (from /proc/loadavg): Load

	open PROC_LOAD, "</proc/loadavg" or die "Can't open file(/proc/loadavg)!";
	if ( defined( my $line = <PROC_LOAD> ) ) {
		chomp($line);
		@sys_load = split( /\s+/, $line );
	}
	close PROC_LOAD or die "Can't close file(/proc/loadavg)!";

	# Load END !
}

sub get_cpuinfo {

	# 2. Get SysInfo (from /proc/stat): CPU

	open PROC_CPU, "</proc/stat" or die "Can't open file(/proc/stat)!";
	if ( defined( my $line = <PROC_CPU> ) )
	{    # use "if" instead of "while" to read first line
		chomp($line);
		my @sys_cpu2 = split( /\s+/, $line );

# line format :     (http://blog.csdn.net/nineday/archive/2007/12/11/1928847.aspx)
# cpu   1-user  2-nice  3-system 4-idle   5-iowait  6-irq   7-softirq
# cpu   628808  1642    61861    24978051 22640     349     3086        0
		my $total_2 =
		  $sys_cpu2[1] +
		  $sys_cpu2[2] +
		  $sys_cpu2[3] +
		  $sys_cpu2[4] +
		  $sys_cpu2[5] +
		  $sys_cpu2[6] +
		  $sys_cpu2[7];

		$user_diff = $sys_cpu2[1] + $sys_cpu2[2] - $sys_cpu1[1] - $sys_cpu1[2];
		$system_diff =
		  $sys_cpu2[3] +
		  $sys_cpu2[6] +
		  $sys_cpu2[7] -
		  $sys_cpu1[3] -
		  $sys_cpu1[6] -
		  $sys_cpu1[7];
		$idle_diff   = $sys_cpu2[4] - $sys_cpu1[4];
		$iowait_diff = $sys_cpu2[5] - $sys_cpu1[5];

	  #printf "%3d %3d %3d %3d",$user_diff,$system_diff,$idle_diff,$iowait_diff;

		$user_diff_1 = int( $user_diff / ( $total_2 - $total_1 ) * 100 + 0.5 );
		$system_diff_1 =
		  int( $system_diff / ( $total_2 - $total_1 ) * 100 + 0.5 );
		$idle_diff_1 = int( $idle_diff / ( $total_2 - $total_1 ) * 100 + 0.5 );
		$iowait_diff_1 =
		  int( $iowait_diff / ( $total_2 - $total_1 ) * 100 + 0.5 );

		# Keep Last Status
		# print @sys_cpu1; print '<->';
		@sys_cpu1 = @sys_cpu2;
		$total_1  = $total_2;

		# print @sys_cpu2;
	}
	close PROC_CPU or die "Can't close file(/proc/stat)!";

	# Cpu END !
}

sub get_swapinfo {

	# 3. Get SysInfo (from /proc/vmstat): SWAP
	# Detail Info : http://www.linuxinsight.com/proc_vmstat.html

	open PROC_VMSTAT, "cat /proc/vmstat | grep -E \"pswpin|pswpout\" |"
	  or die "Can't open file(/proc/vmstat)!";
	while ( my $line = <PROC_VMSTAT> ) {
		chomp($line);
		my ( $key, $value ) = split( /\s+/, $line );
		$swap2{"$key"} = $value;
	}
	if ($swap_not_first) {
		$swapin = $swap2{"pswpin"} - $swap1{"pswpin"};

		$swapout = $swap2{"pswpout"} - $swap1{"pswpout"};
	}
	close PROC_VMSTAT or die "Can't close file(/proc/vmstat)!";

	# Keep Last Status
	%swap1 = %swap2;
	$swap_not_first += 1;

}

sub get_netinfo {

	# 4. Get SysInfo (from /proc/net/dev): NET
	open PROC_NET, "cat /proc/net/dev | grep \"\\b$net\\b\" | "
	  or die "Can't open file(/proc/net/dev)!";
	if ( defined( my $line = <PROC_NET> ) ) {
		chomp($line);
		my @net = split( /\s+|:/, $line );
		%net2 = (
			"recv" => $net[2],
			"send" => $net[10]
		);

		#print "$net2{recv},$net2{send},$net1{recv},$net1{send}";
		if ($net_not_first) {

			#print join('*',@net);
			$diff_recv = $net2{"recv"} - $net1{"recv"};
			$diff_send = $net2{"send"} - $net1{"send"};
		}
		close PROC_NET or die "Can't close file(/proc/net/dev)!";

		# Keep Last Status
		%net1 = %net2;
		$net_not_first += 1;
	}

}

sub get_diskinfo {

	open DISK_INFO, "df -Pm | grep / | grep  $disk |"
	  or die "Can't open file(DISK_INFO)!";
	if ( defined( my $line = <DISK_INFO> ) ) {
		chomp($line);
		$line =~ s/ +/,/g;
		$line =~ s/\%//g;
		( $filesystem, $totalmb, $usedmb, $freemb, $usedpct, $mountpoint ) = split ",", $line;

	}
	
	close DISK_INFO or die "Can't close file(DISK_INFO)!";
}

sub get_ioinfo {

	# 5. Get SysInfo (from /proc/diskstats): IO
	# Detail IO Info :
	# (1) http://www.mjmwired.net/kernel/Documentation/iostats.txt
	# (2) http://www.linuxinsight.com/iostat_utility.html
	# (3) source code --> http://www.linuxinsight.com/files/iostat-2.2.tar.gz
	$deltams =
	  1000.0 *
	  ( $user_diff + $system_diff + $idle_diff + $iowait_diff ) /
	  $ncpu /
	  $HZ;

	# Shell Command : cat /proc/diskstats  | grep "\bsda\b"
	open PROC_IO, "cat /proc/diskstats  | grep \"\\b$disk\\b\" |"
	  or die "Can't open file(/proc/diskstats)!";
	if ( defined( my $line = <PROC_IO> ) ) {
		chomp($line);

# iostat --> line format :
# 0               1        2        3     4      5        6     7        8          9      10     11
# Device:         rrqm/s   wrqm/s   r/s   w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
# sda               0.05    12.44  0.42  7.60     5.67    80.15    21.42     0.04    4.63   0.55   0.44
		my @sys_io2 = split( /\s+/, $line );

		my $rd_ios     = $sys_io2[4] - $sys_io1[4];   #/* Read I/O operations */
		my $rd_merges  = $sys_io2[5] - $sys_io1[5];   #/* Reads merged */
		my $rd_sectors = $sys_io2[6] - $sys_io1[6];   #/* Sectors read */
		my $rd_ticks =
		  $sys_io2[7] - $sys_io1[7];    #/* Time in queue + service for read */
		my $wr_ios    = $sys_io2[8] - $sys_io1[8];   #/* Write I/O operations */
		my $wr_merges = $sys_io2[9] - $sys_io1[9];   #/* Writes merged */
		my $wr_sectors = $sys_io2[10] - $sys_io1[10];    #/* Sectors written */
		my $wr_ticks =
		  $sys_io2[11] - $sys_io1[11];  #/* Time in queue + service for write */
		my $ticks =
		  $sys_io2[13] - $sys_io1[13];    #/* Time of requests in queue */
		my $aveq = $sys_io2[14] - $sys_io1[14];    #/* Average queue length */

		$n_ios    = $rd_ios + $wr_ios;
		$n_ticks  = $rd_ticks + $wr_ticks;
		$n_kbytes = ( $rd_sectors + $wr_sectors ) / 2.0;
		$queue    = $aveq / $deltams;
		$size     = $n_ios ? $n_kbytes / $n_ios : 0.0;
		$wait     = $n_ios ? $n_ticks / $n_ios : 0.0;
		$svc_t    = $n_ios ? $ticks / $n_ios : 0.0;
		$busy     = 100.0 * $ticks / $deltams;             #/* percentage! */
		if ( $busy > 100.0 ) {
			$busy = 100.0;
		}

		#
		$rkbs = ( 1000.0 * $rd_sectors / $deltams / 2 );
		$wkbs = ( 1000.0 * $wr_sectors / $deltams / 2 );

		# r/s  w/s
		$rd_ios_s = ( 1000.0 * $rd_ios / $deltams );
		$wr_ios_s = ( 1000.0 * $wr_ios / $deltams );

		# Keep Last Status
		@sys_io1 = @sys_io2;
		
	}
	close PROC_IO or die "Can't close file(/proc/diskstats)!";
}

# ----------------------------------------------------------------------------------------
# 
# Func : get mysql status
# ----------------------------------------------------------------------------------------
sub get_mysqlstat {
    use DBI;
	use DBI qw(:sql_types);
    my $mystat2;
    my $vars;
    my $sql;
    
	my $dbh = DBI->connect( "DBI:mysql:database=information_schema;host=$lhost;port=$port","$user", "$pswd", { 'RaiseError' => 0 ,AutoCommit => 1} );
	if(not $dbh) {
		return;
	}

	my $dbh_save = DBI->connect( "DBI:mysql:database=myawr;host=$thost;port=$tport","$tuser", "$tpswd", { 'RaiseError' => 0 ,AutoCommit => 1} );
	if(not $dbh_save) {
		return;
	}	
   
    # Get MySQL Status
    my $mysql="SHOW GLOBAL STATUS;";
    my $stat=$dbh->selectall_arrayref($mysql);
    foreach my $row(@$stat) {
        $mystat2->{"$row->[0]"} = $row->[1];
    }
    
    # Get MySQL variables
    $mysql='show variables where variable_name in ("query_cache_size","thread_cache_size","table_definition_cache","key_buffer_size","join_buffer_size","sort_buffer_size","max_connections","table_open_cache","slow_launch_time","log_slow_queries","max_heap_table_size","tmp_table_size","innodb_open_files","open_files_limit"); ';
    my $varb=$dbh->selectall_arrayref($mysql);
    foreach my $row(@$varb) {
        $vars->{"$row->[0]"} = $row->[1];
    }

    my ($running_thread_threshold,$times_per_hour)=$dbh_save->selectrow_array("select running_thread_threshold,times_per_hour from myawr.myawr_host where id=$tid");
    my $times_saved= $dbh_save->selectrow_array("select count(DISTINCT snap_id) cnt  from myawr_engine_innodb_status where snap_time>=DATE_ADD(now(),INTERVAL -1 HOUR) and host_id=$tid");
    my $now_running_threads=$mystat2->{"Threads_running"};
    my $order_id=1;
    
    # Func : Get Innodb Status from Command: 'Show Engine Innodb Status'  ________________start

	my $sth = $dbh->prepare("show engine innodb status");
	$sth->execute();
	my $aline =$sth->fetchrow_array();
	

	my %innodb_status;

    my @result = split( /[\r\n]+/, $aline );
    
    # http://code.google.com/p/mysql-cacti-templates/source/browse/trunk/scripts/ss_get_mysql_stats.php
	foreach (@result) {
		chomp($_);
        
        #print $_ . "\n";
		# ------------
		# TRANSACTIONS
		# ------------
		# Trx id counter 64AFBCC1B
		# Purge done for trx's n:o < 64AFBCAD4 undo n:o < 0
		# History list length 23
		if ( index( $_, "History list length" ) != -1 ) {
			my @tmp = split( /\s+/, $_ );
			$innodb_status{"history_list"} = $tmp[3];
		}

		# ---
		# LOG
		# ---
		# Log sequence number 6712509083974
		# Log flushed up to   6712508972870
		# Last checkpoint at  6709615343735
		# 0 pending log writes, 0 pending chkp writes
		# 2556962847 log i/o's done, 509.12 log i/o's/second
		elsif ( index( $_, "Log sequence number" ) != -1 ) {
			my @tmp = split( /\s+/, $_ );
			$innodb_status{"log_bytes_written"} = $tmp[3];
		}
		elsif ( index( $_, "Log flushed up to" ) != -1 ) {
			my @tmp = split( /\s+/, $_ );
			$innodb_status{"log_bytes_flushed"} = $tmp[4];
		}
		elsif ( index( $_, "Last checkpoint at" ) != -1 ) {
			my @tmp = split( /\s+/, $_ );
			$innodb_status{"last_checkpoint"} = $tmp[3];
		}

		# --------------
		# ROW OPERATIONS
		# --------------
		# 2 queries inside InnoDB, 0 queries in queue
		# 2 read views open inside InnoDB
		# Main thread process no. 7969, id 1191348544, state: sleeping
		# Number of rows inserted 287921794, updated 733493588, deleted 30775703, read 2351464150250
		# 5.10 inserts/s, 29.38 updates/s, 0.02 deletes/s, 51322.87 reads/s
		elsif ( index( $_, "queries inside InnoDB" ) != -1 ) {
			my @tmp = split( /\s+/, $_ );
			$innodb_status{"queries_inside"} = $tmp[0];
			$innodb_status{"queries_queued"} = $tmp[4];
		}
		elsif ( index( $_, "read views open inside InnoDB" ) != -1 ) {
			my @tmp = split( /\s+/, $_ );
			$innodb_status{"read_views"} = $tmp[0];
		}

		# elsif ( index($_,"") != -1 ) {
		#        my @tmp = split(/\s+/,$_);
		#        $innodb_status{""} = $tmp[3];
		# }

        if($running_thread_threshold<=$now_running_threads  and  $times_saved<$times_per_hour){
		    $sql =qq{insert into myawr.myawr_engine_innodb_status(snap_id,host_id,order_id,row_status,snap_time)  values($snap_id,$tid,$order_id, \"$_\", \"$snap_time\")};
		    $dbh_save->do($sql);
		    $order_id +=1;
        }
	}
	$innodb_status{"unflushed_log"} =
	$innodb_status{"log_bytes_written"} - $innodb_status{"log_bytes_flushed"};
	$innodb_status{"uncheckpointed_bytes"} =
	$innodb_status{"log_bytes_written"} - $innodb_status{"last_checkpoint"};

    # Func : Get Innodb Status from Command: 'Show Engine Innodb Status'  ________________end

    if($running_thread_threshold<=$now_running_threads and  $times_saved<$times_per_hour){

		my $sql2 = qq{ insert into myawr_active_session(snap_id,host_id,USER,HOST,DB,COMMAND,TIME,STATE,INFO,snap_time) values ($snap_id,$tid, ?,?,?, ?, ? ,?,?,?) };
		my $sth2 = $dbh_save->prepare( $sql2 );
		
		$sth = $dbh->prepare("select USER,HOST,DB,COMMAND,TIME,STATE,INFO from information_schema.PROCESSLIST where COMMAND<>'Sleep'");
		$sth->execute();
		while( my @result2 = $sth->fetchrow_array )	{
  			    $sth2->bind_param( 1, $result2[0], SQL_VARCHAR );
			    $sth2->bind_param( 2, $result2[1], SQL_VARCHAR);
			    $sth2->bind_param( 3, $result2[2], SQL_VARCHAR );
			    $sth2->bind_param( 4, $result2[3], SQL_VARCHAR );
			    $sth2->bind_param( 5, $result2[4], SQL_INTEGER );
			    $sth2->bind_param( 6, $result2[5], SQL_VARCHAR );
			    $sth2->bind_param( 7, $result2[6] );			    
			    $sth2->bind_param( 8, $snap_time, SQL_DATE );    
			    $sth2->execute();    
		  }
		
		$sql2 = qq{ insert into myawr_innodb_trx(snap_id,host_id,trx_id,trx_state,trx_started,trx_requested_lock_id,trx_wait_started,trx_weight,trx_mysql_thread_id,trx_query,trx_operation_state,trx_tables_in_use,trx_tables_locked,trx_lock_structs,trx_lock_memory_bytes,trx_rows_locked,trx_rows_modified,trx_concurrency_tickets,trx_isolation_level,trx_unique_checks,trx_foreign_key_checks,trx_last_foreign_key_error,trx_adaptive_hash_latched,trx_adaptive_hash_timeout,snap_time) values ($snap_id,$tid,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)};  
		$sth2 = $dbh_save->prepare( $sql2 );
		
		$sth = $dbh->prepare("select trx_id,trx_state,trx_started,trx_requested_lock_id,trx_wait_started,trx_weight,trx_mysql_thread_id,trx_query,trx_operation_state,trx_tables_in_use,trx_tables_locked,trx_lock_structs,trx_lock_memory_bytes,trx_rows_locked,trx_rows_modified,trx_concurrency_tickets,trx_isolation_level,trx_unique_checks,trx_foreign_key_checks,trx_last_foreign_key_error,trx_adaptive_hash_latched,trx_adaptive_hash_timeout from information_schema.INNODB_TRX");		
		$sth->execute();
		while( my @result2 = $sth->fetchrow_array )	{
    			$sth2->bind_param( 1, $result2[0], SQL_VARCHAR );
			    $sth2->bind_param( 2, $result2[1], SQL_VARCHAR);
			    $sth2->bind_param( 3, $result2[2], SQL_DATE );
			    $sth2->bind_param( 4, $result2[3], SQL_VARCHAR );
			    $sth2->bind_param( 5, $result2[4], SQL_DATE );

			    $sth2->bind_param( 6, $result2[5], SQL_INTEGER );
			    $sth2->bind_param( 7, $result2[6], SQL_INTEGER );
  			    $sth2->bind_param( 8, $result2[7], SQL_VARCHAR );
			    $sth2->bind_param( 9, $result2[8], SQL_VARCHAR);
			    $sth2->bind_param( 10,$result2[9], SQL_INTEGER );

			    $sth2->bind_param( 11,$result2[10], SQL_INTEGER );
			    $sth2->bind_param( 12, $result2[11], SQL_INTEGER );
			    $sth2->bind_param( 13, $result2[12], SQL_INTEGER );
			    $sth2->bind_param( 14, $result2[13], SQL_INTEGER );			    
  			    $sth2->bind_param( 15, $result2[14], SQL_INTEGER );
			    $sth2->bind_param( 16, $result2[15], SQL_INTEGER);

			    $sth2->bind_param( 17, $result2[16], SQL_VARCHAR );
			    $sth2->bind_param( 18, $result2[17], SQL_INTEGER );
			    $sth2->bind_param( 19, $result2[18], SQL_INTEGER );
			    $sth2->bind_param( 20, $result2[19], SQL_VARCHAR );
			    $sth2->bind_param( 21, $result2[20], SQL_INTEGER );    
			    $sth2->bind_param( 22, $result2[21], SQL_INTEGER );			    
			    $sth2->bind_param( 23, $snap_time, SQL_DATE );    
			    $sth2->execute();    
		  }
		  
		$sql2 = qq{ insert into myawr_innodb_locks(snap_id,host_id,lock_id,lock_trx_id,lock_mode,lock_type,lock_table,lock_index,lock_space,lock_page,lock_rec,lock_data,snap_time) values ($snap_id,$tid,?,?,?,?,?,?,?,?,?,?,?)};  
		$sth2 = $dbh_save->prepare( $sql2 );
		
		$sth = $dbh->prepare("select lock_id,lock_trx_id,lock_mode,lock_type,lock_table,lock_index,lock_space,lock_page,lock_rec,lock_data from information_schema.INNODB_LOCKS");		  		  
		$sth->execute();
		while( my @result2 = $sth->fetchrow_array )	{
      		   $sth2->bind_param( 1, $result2[0], SQL_VARCHAR );
			   $sth2->bind_param( 2, $result2[1], SQL_VARCHAR);
			   $sth2->bind_param( 3, $result2[2], SQL_VARCHAR );
			   $sth2->bind_param( 4, $result2[3], SQL_VARCHAR );
			   $sth2->bind_param( 5, $result2[4], SQL_VARCHAR );

			   $sth2->bind_param( 6, $result2[5], SQL_VARCHAR );
			   $sth2->bind_param( 7, $result2[6], SQL_INTEGER );
  			   $sth2->bind_param( 8, $result2[7], SQL_INTEGER );
			   $sth2->bind_param( 9, $result2[8], SQL_INTEGER);
			   $sth2->bind_param( 10,$result2[9], SQL_VARCHAR );		    
			   $sth2->bind_param( 11, $snap_time, SQL_DATE );    
			   $sth2->execute();    
		  }
		  
		$sql2 = qq{ insert into myawr_innodb_lock_waits(snap_id,host_id,requesting_trx_id,requested_lock_id,blocking_trx_id,blocking_lock_id,snap_time) values ($snap_id,$tid,?,?,?,?,?)};  
		$sth2 = $dbh_save->prepare( $sql2 );
		
		$sth = $dbh->prepare("select requesting_trx_id,requested_lock_id,blocking_trx_id,blocking_lock_id from information_schema.INNODB_LOCK_WAITS");		  		  
		$sth->execute();
		while( my @result2 = $sth->fetchrow_array )	{
      		   $sth2->bind_param( 1, $result2[0], SQL_VARCHAR );
			   $sth2->bind_param( 2, $result2[1], SQL_VARCHAR);
			   $sth2->bind_param( 3, $result2[2], SQL_VARCHAR );
			   $sth2->bind_param( 4, $result2[3], SQL_VARCHAR );
			   $sth2->bind_param( 5, $snap_time, SQL_DATE );    
			   $sth2->execute();    
		  }
		  
		  $sth2->finish;		      
    }


	$sql =
	qq{insert into myawr.myawr_mysql_info(snap_id,host_id,query_cache_size,thread_cache_size,table_definition_cache,max_connections,table_open_cache,slow_launch_time,max_heap_table_size,tmp_table_size,open_files_limit,Max_used_connections,Threads_connected,Threads_cached,Threads_created,Threads_running,Connections,Questions,Com_select,Com_insert,Com_update,Com_delete,Bytes_received,Bytes_sent,Qcache_hits,Qcache_inserts,Select_full_join,Select_scan,Slow_queries,Com_commit,Com_rollback,Open_files,Open_table_definitions,Open_tables,Opened_files,Opened_table_definitions,Opened_tables,Created_tmp_disk_tables,Created_tmp_files,Created_tmp_tables,Binlog_cache_disk_use,Binlog_cache_use,Aborted_clients,Sort_merge_passes,Sort_range,Sort_rows,Sort_scan,Table_locks_immediate,Table_locks_waited,Handler_read_first,Handler_read_key,Handler_read_last,Handler_read_next,Handler_read_prev,Handler_read_rnd,Handler_read_rnd_next,snap_time) values($snap_id,$tid,$vars->{"query_cache_size"},$vars->{"thread_cache_size"},$vars->{"table_definition_cache"},$vars->{"max_connections"},$vars->{"table_open_cache"},$vars->{"slow_launch_time"},$vars->{"max_heap_table_size"},$vars->{"tmp_table_size"},$vars->{"open_files_limit"},$mystat2->{"Max_used_connections"},$mystat2->{"Threads_connected"},$mystat2->{"Threads_cached"},$mystat2->{"Threads_created"},$mystat2->{"Threads_running"},$mystat2->{"Connections"},$mystat2->{"Questions"},$mystat2->{"Com_select"},$mystat2->{"Com_insert"},$mystat2->{"Com_update"},$mystat2->{"Com_delete"},$mystat2->{"Bytes_received"},$mystat2->{"Bytes_sent"},$mystat2->{"Qcache_hits"},$mystat2->{"Qcache_inserts"},$mystat2->{"Select_full_join"},$mystat2->{"Select_scan"},$mystat2->{"Slow_queries"},$mystat2->{"Com_commit"},$mystat2->{"Com_rollback"},$mystat2->{"Open_files"},$mystat2->{"Open_table_definitions"},$mystat2->{"Open_tables"},$mystat2->{"Opened_files"},$mystat2->{"Opened_table_definitions"},$mystat2->{"Opened_tables"},$mystat2->{"Created_tmp_disk_tables"},$mystat2->{"Created_tmp_files"},$mystat2->{"Created_tmp_tables"},$mystat2->{"Binlog_cache_disk_use"},$mystat2->{"Binlog_cache_use"},$mystat2->{"Aborted_clients"},$mystat2->{"Sort_merge_passes"},$mystat2->{"Sort_range"},$mystat2->{"Sort_rows"},$mystat2->{"Sort_scan"},$mystat2->{"Table_locks_immediate"},$mystat2->{"Table_locks_waited"},$mystat2->{"Handler_read_first"},$mystat2->{"Handler_read_key"},$mystat2->{"Handler_read_last"},$mystat2->{"Handler_read_next"},$mystat2->{"Handler_read_prev"},$mystat2->{"Handler_read_rnd"},$mystat2->{"Handler_read_rnd_next"}, \"$snap_time\")};

	#print $sql;

	$dbh_save->do($sql);

	$sql =
	qq{insert into myawr.myawr_innodb_info(snap_id,host_id,Innodb_rows_inserted,Innodb_rows_updated,Innodb_rows_deleted,Innodb_rows_read,Innodb_buffer_pool_read_requests,Innodb_buffer_pool_reads,Innodb_buffer_pool_pages_data,  Innodb_buffer_pool_pages_free,  Innodb_buffer_pool_pages_dirty,  Innodb_buffer_pool_pages_flushed,  Innodb_data_reads,  Innodb_data_writes,  Innodb_data_read,  Innodb_data_written,  Innodb_os_log_fsyncs,  Innodb_os_log_written,  history_list,  log_bytes_written,  log_bytes_flushed,  last_checkpoint,  queries_inside,  queries_queued,  read_views, innodb_open_files,innodb_log_waits,snap_time)  values($snap_id,$tid,$mystat2->{"Innodb_rows_inserted"},$mystat2->{"Innodb_rows_updated"},$mystat2->{"Innodb_rows_deleted"},$mystat2->{"Innodb_rows_read"},$mystat2->{"Innodb_buffer_pool_read_requests"},$mystat2->{"Innodb_buffer_pool_reads"},$mystat2->{"Innodb_buffer_pool_pages_data"},$mystat2->{"Innodb_buffer_pool_pages_free"},$mystat2->{"Innodb_buffer_pool_pages_dirty"},$mystat2->{"Innodb_buffer_pool_pages_flushed"},$mystat2->{"Innodb_data_reads"},$mystat2->{"Innodb_data_writes"},$mystat2->{"Innodb_data_read"},$mystat2->{"Innodb_data_written"},$mystat2->{"Innodb_os_log_fsyncs"},$mystat2->{"Innodb_os_log_written"},$innodb_status{"history_list"},$innodb_status{"log_bytes_written"},$innodb_status{"log_bytes_flushed"},$innodb_status{"last_checkpoint"},$innodb_status{"queries_inside"},$innodb_status{"queries_queued"},$innodb_status{"read_views"},$vars->{"innodb_open_files"},$mystat2->{"Innodb_log_waits"}, \"$snap_time\")};
 
   	#print $sql;
	$dbh_save->do($sql);
	
    $sql =
	qq{insert into myawr.myawr_isam_info(snap_id,host_id,key_buffer_size,join_buffer_size,sort_buffer_size,Key_blocks_not_flushed,Key_blocks_unused,Key_blocks_used,Key_read_requests,Key_reads,Key_write_requests,Key_writes,snap_time)  values($snap_id,$tid,$vars->{"key_buffer_size"},$vars->{"join_buffer_size"},$vars->{"sort_buffer_size"},$mystat2->{"Key_blocks_not_flushed"},$mystat2->{"Key_blocks_unused"},$mystat2->{"Key_blocks_used"},$mystat2->{"Key_read_requests"},$mystat2->{"Key_reads"},$mystat2->{"Key_write_requests"},$mystat2->{"Key_writes"}, \"$snap_time\")};
    $dbh_save->do($sql);
    
    my($sec,$min,$hour,$day,$mon,$year) = gmtime($mystat2->{"Uptime"});
    $year = $year-70;
    
    my $varuptime=$year .'y ' .$mon .'m ' .$day .'d ' . $hour . 'h ' . $min . 'mi ' . $sec .'s';
    $sql =
	qq{update myawr.myawr_host set uptime="$varuptime",check_time=now() where id=$tid};
    $dbh_save->do($sql);
    
    $sth->finish;
	$dbh->disconnect();
	$dbh_save->disconnect();

}

# ----------------------------------------------------------------------------------------
# 
# Func : get mysql status
# ----------------------------------------------------------------------------------------
sub get_osstat {
    use DBI;
    
	use DBI qw(:sql_types);
    my $mystat2;
    my $vars;
    my $sql;

	my $dbh_save = DBI->connect( "DBI:mysql:database=myawr;host=$thost;port=$tport","$tuser", "$tpswd", { 'RaiseError' => 0 ,AutoCommit => 1} );
	if(not $dbh_save) {
		return;
	}	
    
    $snap_time =`date +"%Y-%m-%d %H:%M:%S"`;
    
 	my $sth = $dbh_save->prepare("SELECT max(snap_id) from myawr.myawr_snapshot where host_id=$tid and snap_id is not null");
	$sth->execute();
	my $old_snap_id=$sth->fetchrow_array();    
    
    if($old_snap_id eq 'NULL'){
    	$snap_id=1;
    }else{
    	$snap_id=$old_snap_id+1;
    }
    
    $sql =qq{insert into myawr.myawr_snapshot(host_id,snap_time,snap_id) values($tid, \"$snap_time\",$snap_id)};
    $dbh_save->do($sql);

    $sql =qq{insert into myawr.myawr_load_info(snap_id,host_id,load1,load5,load15,snap_time) values($snap_id,$tid, $sys_load[0],$sys_load[1],$sys_load[2], \"$snap_time\")};
    $dbh_save->do($sql);

	$sql =qq{insert into myawr.myawr_cpu_info(snap_id,host_id,cpu_user,cpu_system,cpu_idle,cpu_iowait,snap_time) values($snap_id,$tid, $user_diff_1,$system_diff_1,$idle_diff_1,$iowait_diff_1, \"$snap_time\")};
	$dbh_save->do($sql);

	$sql =qq{insert into myawr.myawr_io_info(snap_id,host_id,rd_ios_s,wr_ios_s,rkbs,wkbs,queue,wait,svc_t,busy,snap_time) values($snap_id,$tid, $rd_ios_s,$wr_ios_s ,$rkbs,$wkbs,$queue,$wait,$svc_t,$busy, \"$snap_time\")};
	$dbh_save->do($sql); 

	$sql =
	qq{insert into myawr.myawr_swap_net_disk_info(snap_id,host_id,swap_in,swap_out,net_recv,net_send,file_system,total_mb,used_mb,used_pct,mount_point,snap_time) values($snap_id,$tid, $swapin,$swapout,$diff_recv,$diff_send,\"$filesystem\", $totalmb, $usedmb,  $usedpct, \"$mountpoint\" , \"$snap_time\")};
	$dbh_save->do($sql);
	
    $sth->finish;
	$dbh_save->disconnect();
}



# ----------------------------------------------------------------------------------------
# 
# Func : get performance info
# ----------------------------------------------------------------------------------------
sub get_perfstat {
	use DBI;
	use DBI qw(:sql_types);

	my $dbh = DBI->connect( "DBI:mysql:database=information_schema;host=$lhost;port=$port","$user", "$pswd", { 'RaiseError' => 0 } );
	if(not $dbh) {
		return;
	}

	my $sth = $dbh->prepare("select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='PERFORMANCE_SCHEMA'");
	$sth->execute();
	my $perfon=$sth->fetchrow_array();
    
    if ($perfon eq 'ON'){

		my $dbh_save = DBI->connect( "DBI:mysql:database=myawr;host=$thost;port=$tport","$tuser", "$tpswd", { 'RaiseError' => 0 ,AutoCommit => 0} );
		if(not $dbh_save) {
			return;
		}


		my $sql2 = qq{ insert into myawr_snapshot_events_waits_summary_global_by_event_name(snap_id,host_id,EVENT_NAME,COUNT_STAR,SUM_TIMER_WAIT,MIN_TIMER_WAIT,AVG_TIMER_WAIT,MAX_TIMER_WAIT,snap_time) values ($snap_id,$tid, ?,?,?, ?, ? ,?,?) };
		my $sth2 = $dbh_save->prepare( $sql2 );
		
		$sth = $dbh->prepare("select * from performance_schema.events_waits_summary_global_by_event_name");
		$sth->execute();
		while( my @result2 = $sth->fetchrow_array )	{
			    $sth2->bind_param( 1, $result2[0], SQL_VARCHAR );
			    $sth2->bind_param( 2, $result2[1], SQL_INTEGER);
			    $sth2->bind_param( 3, $result2[2], SQL_INTEGER );
			    $sth2->bind_param( 4, $result2[3], SQL_INTEGER );
			    $sth2->bind_param( 5, $result2[4], SQL_INTEGER );
			    $sth2->bind_param( 6, $result2[5], SQL_INTEGER );
			    $sth2->bind_param( 7, $snap_time, SQL_DATE );			    
			    $sth2->execute();
			    $dbh_save->commit();
	    
		  }

		$sql2 = qq{ insert into myawr_snapshot_file_summary_by_event_name(snap_id,host_id,EVENT_NAME,COUNT_READ,COUNT_WRITE,SUM_NUMBER_OF_BYTES_READ,SUM_NUMBER_OF_BYTES_WRITE,snap_time) values ($snap_id,$tid, ?,?,?, ?, ? ,?) };
		$sth2 = $dbh_save->prepare( $sql2 );
				  
		$sth = $dbh->prepare("select * from performance_schema.file_summary_by_event_name");
		$sth->execute();
		while( my @result2 = $sth->fetchrow_array )	{
			    $sth2->bind_param( 1, $result2[0], SQL_VARCHAR );
			    $sth2->bind_param( 2, $result2[1], SQL_INTEGER);
			    $sth2->bind_param( 3, $result2[2], SQL_INTEGER );
			    $sth2->bind_param( 4, $result2[3], SQL_INTEGER );
			    $sth2->bind_param( 5, $result2[4], SQL_INTEGER );
			    $sth2->bind_param( 6, $snap_time, SQL_DATE );		    
			    $sth2->execute();
			    $dbh_save->commit();
	    
		  }		  
		  
		$sth2->finish;
		#disconnect
		$dbh_save->disconnect(); 
		  	
    }
 
    $sth->finish;
		#disconnect
	$dbh->disconnect(); 
}


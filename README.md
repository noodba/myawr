<h2>1.What is myawr</h2>

<pre>
Myawr is a tool for collecting and analyzing performance data for MySQL database (including os info ,mysql status info and Slow Query Log  all of details). 
The idea comes from Oracle awr. Myawr periodic collect data and save to the database as snapshots.
Myawr was designed as CS architecture.Myawr depends on (but not necessary) performance schema of MySQL database.

Myawr consists of three parts:
myawr.pl--------a perl script for collecting mysql performance data
myawrrpt.pl-----a perl script for analyzing mysql performance data
myawrsrpt.pl-----a perl script for analyzing mysql peak time data

Myawr relies on the Percona Toolkit to do the slow query log collection.
Specifically you can run pt-query-digest. To parse your slow logs and insert them into your server database for reporting and analyzing. 

Thanks to orzdba.pl (zhuxu@taobao.com).
<br/>
<br/>
Here is myawr architecture:
<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr_archit1.png"><img src="http://www.noodba.com/wp-content/uploads/2013/05/myawr_archit1.png" alt="myawr_archit1" width="857" height="492" class="alignnone size-full wp-image-376" /></a>

<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr_archit2.png"><img src="http://www.noodba.com/wp-content/uploads/2013/05/myawr_archit2.png" alt="myawr_archit2" width="771" height="549" class="alignnone size-full wp-image-377" /></a>

</pre>


<h2>2.Myawr Data Model</h2>
<pre>
myawr db include tables list:
mysql> show tables;
+----------------------------------------------------------+
| Tables_in_myawr                                          |
+----------------------------------------------------------+
| myawr_active_session                                     |
| myawr_cpu_info                                           |
| myawr_engine_innodb_status                               |
| myawr_host                                               |
| myawr_innodb_info                                        |
| myawr_innodb_lock_waits                                  |
| myawr_innodb_locks                                       |
| myawr_innodb_trx                                         |
| myawr_io_info                                            |
| myawr_isam_info                                          |
| myawr_load_info                                          |
| myawr_mysql_info                                         |
| myawr_query_review                                       |
| myawr_query_review_history                               |
| myawr_snapshot                                           |
| myawr_snapshot_events_waits_summary_global_by_event_name |
| myawr_snapshot_file_summary_by_event_name                |
| myawr_swap_net_disk_info                                 |
+----------------------------------------------------------+
18 rows in set (0.00 sec)

some key tables:
myawr_host-- mysql instance config table
myawr_snapshot -- snapshot table,exec myawr.pl a time as a shapshot
myawr_query_review_history -- The table in which to store historical values for review trend analysis about slow log.
 
myawr data model:
myawr_snapshot.host_id    reference myawr_host.id;
myawr_query_review_history.hostid_max reference myawr_host.id;
myawr_innodb_info.(host_id,snap_id) reference myawr_snapshot.(host_id,snap_id);
<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr1.png"><img class="alignnone size-full wp-image-330" alt="myawr1" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr1.png" width="1264" height="1596" /></a>
</pre> 

<h2>3. Quickstart</h2>
<pre>
If you are interesting to use this tool, here's what you need:

 1. A MySQL database to store snapshot data and slow log analysis data .
 2. pt-query-digest  by percona
 3. A MySQL server(version 5.5) with perl-DBD-mysql
 4. slow query logs named like slow_20130521.log,you can switch slow logs every day.

3.1 install db(where you store shapshot data,perl-DBD-MySQL is required)
Connect to the MySQL database where store the performance data and issue the following command in myawr.sql:
grant all on myawr.* to 'myuser'@'localhost' identified by "111111";
grant all on myawr.* to 'myuser'@'%' identified by "111111";
then create tables.

3.2 initialize myawr_host(where you store shapshot data)
Insert a config record about your mysql instacne,just like:
INSERT INTO `myawr_host`(id,host_name,ip_addr,port,db_role,version, running_thread_threshold,times_per_hour) VALUES (6, 'db2.11', '192.168.2.11', 3306, 'master', '5.5.27',10000,0);

Running_thread_threshold and times_per_hour control whether collect peak time information or not.
Running_thread_threshold is a trigger for status Threads_running.
Times_per_hour control the times of collection in lasted a hour.
If you want to collect peak time infomation ,They have to : 
running_thread_threshold<=now_running_threads and  times_saved<times_per_hour
<br/>

3.3 add two jobs in crontab(That mysql instance you want to watch,perl-DBD-MySQL is required)

grant all on *.* to 'superuser'@'localhost' identified by "111111";

* * * * * perl /data/mysql/sh/myawr.pl -u user -p 111111 -lh 192.168.2.11 -P 3306  -tu user -tp 111111 -TP 3306 -th 192.168.1.92 -n eth0 -d sdb1 -I 6 >> /data/mysql/sh/myawr_pl.log 2>&1
#
15 14 * * * /data/mysql/sh/pt-query-digest --user=user --password=111111 --review h=192.168.1.92,D=myawr,t=myawr_query_review --review-history h=192.168.1.92,D=myawr,t=myawr_query_review_history --no-report --limit=100\% --filter="\$event->{add_column} = length(\$event->{arg}) and \$event->{hostid}=6"  /data/mysql/sh/slow_`date -d "-1 day" +"\%Y\%m\%d"`.log >> /data/mysql/sh/pt-query_run.log 2>&1

 myawr.pl  Parameters:
   -h,--help           Print Help Info. 
   -i,--interval       Time(second) Interval(default 1).  
   -d,--disk           Disk Info(can't be null,default sda1).
   -n,--net            Net  Info(default eth0).
   -P,--port           Port number to use for local mysql connection(default 3306).
   -u,--user           user name for local mysql(default user).
   -p,--pswd           user password for local mysql(can't be null).
   -lh,--lhost         localhost(ip) for mysql where info is got(can't be null).
   -TP,--tport         Port number to use formysql where info is saved (default 3306)
   -tu,--tuser         user name for  mysql where info is saved(default user).
   -tp,--pswd          user password for mysql where info is saved(can't be null).
   -th,--thost         host(ip) for mysql where info is saved(can't be null).
   -I,--tid            db instance register id(can't be null,Reference myawr_host.id)

pt-query-digest  Parameters:
--user   	user name for  mysql where info is saved
--password		user password for mysql where info is saved
--review		Store a sample of each class of query in this DSN
      h			host(ip) for mysql where info is saved
      D			database
      t			table name
--review-history	The table in which to store historical values for review trend analysis.
      h			host(ip) for mysql where info is saved
      D			database
      t			table name
$event->{hostid}=6	db instance register id(Reference myawr_host.id)

The pt-query-digest only support mechanism for switching a slow log file every day just now, named like slow_20130521.log(slow_date -d "-1 day" +"%Y%m%d".log)
</pre>

<h2>4. Dependencies</h2>
<pre>
perl-DBD-mysql
you can install it two way:
yum install perl-DBD-MySQL
or install manually like :
mkdir /tmp/mysqldbd-install 
  cp /usr/lib64/mysql/*.a  /tmp/mysqldbd-install
  perl Makefile.PL --libs="-L/tmp/mysqldbd-install -lmysqlclient" 
  make 
  make test 
  make install 
</pre>

<h2>5. Mysql WorkLoad Report</h2>
<pre>
We can use myawrrpt.pl to generate mysql workload report.You can execute the script on MySQL database machine  where store the performance data,but perl-DBD-MySQL is required.We also can execute the script in any linux machine with perl-DBD-MySQL installed.

You can execute it for help Info:
perl myawrrpt.pl -h

Info  :
        Created By noodba (www.noodba.com).
                References: Oracle awr
Usage :
Command line options :

   -h,--help        Print Help Info. 
  
   -P,--port        Port number to use for local mysql connection(default 3306).
   -u,--user        user name for local mysql(default user).
   -p,--pswd       user password for local mysql(can't be null).
   -lh,--lhost       localhost(ip) for mysql where info is got(can't be null).

     -I,--tid         db instance register id(can't be null,Ref myawr_host.id)
  
  
Sample :
   shell> perl myawrrpt.pl -p 111111 -lh 192.168.1.111 -I 11
============================================================================

Let use to generate mysql (db2.11,instance id = 6) workload report:
perl myawrrpt.pl -u user -p 111111 -P 3306 -lh 192.168.1.92 -I 6
===================================================
|       Welcome to use the myawrrpt tool !   
|             Date: 2013-05-22
|
|      Hostname is: db2.11 
|       Ip addr is: 192.168.2.11 
|          Port is: 3306 
|       Db role is: master 
|Server version is: 5.5.27
|        Uptime is: 0y 2m 2d 7h 55mi 33s
|
|   Min snap_id is: 1 
| Min snap_time is: 2013-05-21 14:12:02 
|   Max snap_id is: 1147 
| Max snap_time is: 2013-05-22 09:29:02 
| snap interval is: 60s
===================================================

Listing the last 2 days Snapshots
---------------------------------
snap_id:      19      snap_time : 2013-05-21 14:30:02 
snap_id:      38      snap_time : 2013-05-21 14:49:02 
snap_id:      57      snap_time : 2013-05-21 15:08:02 
snap_id:      76      snap_time : 2013-05-21 15:27:02 
snap_id:      95      snap_time : 2013-05-21 15:46:02 

.....................................................

snap_id:    1102      snap_time : 2013-05-22 08:44:02 
snap_id:    1121      snap_time : 2013-05-22 09:03:02 
snap_id:    1140      snap_time : 2013-05-22 09:22:02 
snap_id:    1147      snap_time : 2013-05-22 09:29:02 

Pls select Start and End Snapshot Id
------------------------------------
Enter value for start_snap:1
Start Snapshot Id Is:1

Enter value for end_snap:589
End  Snapshot Id Is:589

Set the Report Name
-------------------

Enter value for report_name:myawr.html

Using the report name :myawr.html

Generating the mysql report for this analysis ...
Generate the mysql report Successfully.

[mysql@test2 myawr]$ ls -al
total 976
drwxrwxr-x  2 mysql mysql   4096 May 22 09:30 .
drwx------ 19 mysql mysql   4096 May 13 10:42 ..
-rw-rw-r--  1 mysql mysql  73074 May 22 09:30 myawr.html
-rw-rw-r--  1 mysql mysql  53621 May 11 16:23 myawrrpt.pl

Mysql WorkLoad Report 

Ok,let me show some pictures which come from my test db report:
</pre>

<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr2.png"><img class="alignnone size-full wp-image-335" alt="myawr2" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr2.png" width="616" height="243" /></a>  <a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr3.png"><img class="alignnone size-full wp-image-336" alt="myawr3" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr3.png" width="600" height="716" /></a><br />
<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr4.png"><img class="alignnone size-full wp-image-337" alt="myawr4" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr4.png" width="815" height="390" /></a></p>
<p>For detail report ,pls click <a href="http://www.noodba.com/myawr.html">myawr.html</a></p>


<h2>6. Mysql Snapshot Report</h2>
<pre>
We can use myawrsrpt.pl to generate mysql snapshot report. You can execute the script on MySQL database machine  where store the performance data,but perl-DBD-MySQL is required.We also can execute the script in any linux machine with perl-DBD-MySQL installed.

You can execute it for help Info:
[root@oel58 myawr2.0]# perl myawrsrpt.pl

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

Let use to generate mysql (db2.11,instance id = 6) snapshot report:

[root@oel58 myawr2.0]# perl myawrsrpt.pl  -p 123456 -lh 192.168.137.4 -u qwsh -P 3306 -I 6 -s 27
===================================================
|       Welcome to use the myawrrpt tool !   
|             Date: 2013-06-18
|
|      Hostname is: db2.11 
|       Ip addr is: 192.168.2.11 
|          Port is: 3306 
|       Db role is: master 
|Server version is: 5.5.27
|        Uptime is: 0y 0m 1d 1h 10mi 12s
===================================================

Generating the mysql report for this analysis ...
Generate the mysql report Successfully.
</pre> 
 
For detail report ,pls click  <a href="http://www.noodba.com/myawr_snapshot.html">myawr_snapshot.html</a></p>


<h2>7. Contact me</h2>
<pre>
Any questions,pls contact me freely.

EMAIL: qiuwsh@gmail.com
Q Q : 570182914
Phone: (+86)13817963180
</pre>

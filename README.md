  <h2> <strong>1.What is myawr</strong></h2>
<p>Myawr is a tool for collecting and analyzing performance data for MySQL database (including os info ,mysql status info and Slow Query Log  all of details). The idea comes from Oracle awr. Myawr periodic collect data and save to the database as snapshots. Myawr was designed as CS architecture.Myawr depends on performance schema of MySQL database. Myawr consists of two parts:</p>
<p><b>myawr.pl</b><b>&#8212;&#8212;&#8211;a perl script for collecting mysql performance data<br />
</b><b>myawrrpt.pl&#8212;&#8211;a perl script for analyzing mysql performance data</b></p>
<p>Myawr relies on the <a href="http://www.percona.com/software/percona-toolkit/">Percona Toolkit</a> to do the slow query log collection. Specifically you can run <a href="http://www.percona.com/doc/percona-toolkit/2.0/pt-query-digest.html">pt-query-digest</a>. To parse your slow logs and insert them into your server database for reporting and analyzing.</p>
<p>Thanks to orzdba.pl (<a href="mailto:zhuxu@taobao.com">zhuxu@taobao.com</a>).</p>
<p>&nbsp;</p>
<h2> <strong>2.Myawr Data Model</strong></h2>
<p>myawr db include tables list:<br />
mysql&gt; show tables;<br />
+&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-+<br />
| Tables_in_myawr                                             |<br />
+&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-+<br />
| myawr_cpu_info                                               |<br />
| myawr_host                                                      |<br />
| myawr_innodb_info                                          |<br />
| myawr_io_info                                                  |<br />
| myawr_isam_info                                             |<br />
| myawr_load_info                                              |<br />
| myawr_mysql_info                                           |<br />
| myawr_query_review                                       |<br />
| myawr_query_review_history                          |<br />
| myawr_snapshot                                             |<br />
| myawr_snapshot_events_waits_summary_by_instance |<br />
| myawr_snapshot_events_waits_summary_global_by_event_name |<br />
| myawr_snapshot_file_summary_by_event_name |<br />
| myawr_snapshot_file_summary_by_instance |<br />
| myawr_swap_net_disk_info                             |<br />
+&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-+<br />
15 rows in set (0.01 sec)</p>
<p>some key tables:<br />
myawr_host&#8211; mysql instance config table<br />
myawr_snapshot &#8212; snapshot table,exec myawr.pl a time as a shapshot<br />
myawr_query_review_history &#8212; The table in which to store historical values for review trend analysis about slow log.</p>
<p>myawr data model:<br />
myawr_snapshot.host_id reference myawr_host.id;<br />
myawr_query_review_history.hostid_max reference myawr_host.id;<br />
myawr_innodb_info.(host_id,snap_id) reference myawr_snapshot.(host_id,snap_id);<br />
<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr1.png"><img class="alignnone size-full wp-image-330" alt="myawr1" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr1.png" width="1264" height="1596" /></a></p>
<h2> <strong>3. Quickstart<br />
</strong></h2>
<p>If you are interesting to use this tool, here&#8217;s what you need:</p>
<p>1. A MySQL database to store snapshot data and slow log analysis data .<br />
2. pt-query-digest by percona<br />
3. A MySQL server with perl-DBD-mysql<br />
4. slow query logs named like slow_20130521.log,you can switch slow logs every day.</p>
<p><strong>3.1 install db</strong><br />
Connect to the MySQL database where store the performance data and issue the following command in myawr.sql:</p>
<p>CREATE DATABASE `myawr` DEFAULT CHARACTER SET utf8;<br />
grant all on myawr.* to &#8216;user&#8217;@'%&#8217; identified by &#8220;111111&#8243;;</p>
<p>then create tables in db myawr.</p>
<p><strong>3.2 initialize myawr_host</strong></p>
<p>Insert a config record about your mysql instacne,just like:<br />
INSERT INTO `myawr_host`(id,host_name,ip_addr,port,db_role,version) VALUES (6, &#8216;db2.11&#8242;, &#8217;192.168.2.11&#8242;, 3306, &#8216;master&#8217;, &#8217;5.5.27&#8242;);<br />
<strong>3.3 add two jobs in crontab</strong></p>
<p>* * * * * perl /data/mysql/sh/myawr.pl -u user -p 111111 -lh 192.168.2.11 -P 3306 -tu user -tp 111111 -TP 3306 -th 192.168.1.92 -n eth0 -d sdb1 -I 6 &gt;&gt; /data/mysql/sh/myawr_pl.log 2&gt;&amp;1<br />
#<br />
15 14 * * * /data/mysql/sh/pt-query-digest &#8211;user=user &#8211;password=111111 &#8211;review h=192.168.1.92,D=myawr,t=myawr_query_review &#8211;review-history h=192.168.1.92,D=myawr,t=myawr_query_review_history &#8211;no-report &#8211;limit=100\% &#8211;filter=&#8221;\$event-&gt;{add_column} = length(\$event-&gt;{arg}) and \$event-&gt;{hostid}=6&#8243; /data/mysql/sh/slow_`date -d &#8220;-1 day&#8221; +&#8221;\%Y\%m\%d&#8221;`.log &gt;&gt; /data/mysql/sh/pt-query_run.log 2&gt;&amp;1</p>
<p>myawr.pl Parameters:<br />
-h,&#8211;help Print Help Info.<br />
-i,&#8211;interval Time(second) Interval(default 1).<br />
-d,&#8211;disk Disk Info(can&#8217;t be null,default sda1).<br />
-n,&#8211;net Net Info(default eth0).<br />
-P,&#8211;port Port number to use for local mysql connection(default 3306).<br />
-u,&#8211;user user name for local mysql(default user).<br />
-p,&#8211;pswd user password for local mysql(can&#8217;t be null).<br />
-lh,&#8211;lhost localhost(ip) for mysql where info is got(can&#8217;t be null).<br />
-TP,&#8211;tport Port number to use formysql where info is saved (default 3306)<br />
-tu,&#8211;tuser user name for mysql where info is saved(default user).<br />
-tp,&#8211;pswd user password for mysql where info is saved(can&#8217;t be null).<br />
-th,&#8211;thost host(ip) for mysql where info is saved(can&#8217;t be null).<br />
-I,&#8211;tid db instance register id(can&#8217;t be null,Reference myawr_host.id)</p>
<p>pt-query-digest Parameters:<br />
&#8211;user user name for mysql where info is saved<br />
&#8211;password user password for mysql where info is saved<br />
&#8211;review Store a sample of each class of query in this DSN<br />
h host(ip) for mysql where info is saved<br />
D database<br />
t table name<br />
&#8211;review-history The table in which to store historical values for review trend analysis.<br />
h host(ip) for mysql where info is saved<br />
D database<br />
t table name<br />
$event-&gt;{hostid}=6 db instance register id(Reference myawr_host.id)</p>
<p>The pt-query-digest only support mechanism for switching a slow log file every day just now, named like slow_20130521.log(slow_date -d &#8220;-1 day&#8221; +&#8221;%Y%m%d&#8221;.log)</p>
<h2> <strong>4. Dependencies</strong></h2>
<p>perl-DBD-mysql<br />
you can install it two way:<br />
yum install perl-DBD-MySQL<br />
or install manually like :<br />
mkdir /tmp/mysqldbd-install<br />
cp /usr/lib64/mysql/*.a /tmp/mysqldbd-install<br />
perl Makefile.PL &#8211;libs=&#8221;-L/tmp/mysqldbd-install -lmysqlclient&#8221;<br />
make<br />
make test<br />
make install</p>
<h2> <strong>5. Mysql WorkLoad Report</strong></h2>
<p>We can use myawrrpt.pl to generate mysql workload report.You can execute the script on MySQL database machine where store the performance data,but perl-DBD-MySQL is required.We also can execute the script in any linux machine with perl-DBD-MySQL installed.</p>
<p>You can execute it for help Info:<br />
perl myawrrpt.pl -h</p>
<p>Info :<br />
Created By noodba (www.noodba.com).<br />
References: Oracle awr<br />
Usage :<br />
Command line options :</p>
<p>-h,&#8211;help Print Help Info.</p>
<p>-P,&#8211;port Port number to use for local mysql connection(default 3306).<br />
-u,&#8211;user user name for local mysql(default user).<br />
-p,&#8211;pswd user password for local mysql(can&#8217;t be null).<br />
-lh,&#8211;lhost localhost(ip) for mysql where info is got(can&#8217;t be null).</p>
<p>-I,&#8211;tid db instance register id(can&#8217;t be null,Ref myawr_host.id)</p>
<p>Sample :<br />
shell&gt; perl myawrrpt.pl -p 111111 -lh 192.168.1.111 -I 11<br />
============================================================================</p>
<p>Let use to generate mysql (db2.11,instance id = 6) workload report:<br />
perl myawrrpt.pl -u user -p 111111 -P 3306 -lh 192.168.1.92 -I 6<br />
===================================================<br />
| Welcome to use the myawrrpt tool !<br />
| Date: 2013-05-22<br />
|<br />
| Hostname is: db2.11<br />
| Ip addr is: 192.168.2.11<br />
| Port is: 3306<br />
| Db role is: master<br />
|Server version is: 5.5.27<br />
| Uptime is: 0y 2m 2d 7h 55mi 33s<br />
|<br />
| Min snap_id is: 1<br />
| Min snap_time is: 2013-05-21 14:12:02<br />
| Max snap_id is: 1147<br />
| Max snap_time is: 2013-05-22 09:29:02<br />
| snap interval is: 60s<br />
===================================================</p>
<p>Listing the last 2 days Snapshots<br />
&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;<br />
snap_id: 19 snap_time : 2013-05-21 14:30:02<br />
snap_id: 38 snap_time : 2013-05-21 14:49:02<br />
snap_id: 57 snap_time : 2013-05-21 15:08:02<br />
snap_id: 76 snap_time : 2013-05-21 15:27:02<br />
snap_id: 95 snap_time : 2013-05-21 15:46:02</p>
<p>&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;&#8230;..</p>
<p>snap_id: 1102 snap_time : 2013-05-22 08:44:02<br />
snap_id: 1121 snap_time : 2013-05-22 09:03:02<br />
snap_id: 1140 snap_time : 2013-05-22 09:22:02<br />
snap_id: 1147 snap_time : 2013-05-22 09:29:02</p>
<p>Pls select Start and End Snapshot Id<br />
&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;<br />
Enter value for start_snap:1<br />
Start Snapshot Id Is:1</p>
<p>Enter value for end_snap:589<br />
End Snapshot Id Is:589</p>
<p>Set the Report Name<br />
&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-</p>
<p>Enter value for report_name:myawr.html</p>
<p>Using the report name :myawr.html</p>
<p>Generating the mysql report for this analysis &#8230;<br />
Generate the mysql report Successfully.</p>
<p>[mysql@test2 myawr]$ ls -al<br />
total 976<br />
drwxrwxr-x 2 mysql mysql 4096 May 22 09:30 .<br />
drwx&#8212;&#8212; 19 mysql mysql 4096 May 13 10:42 ..<br />
-rw-rw-r&#8211; 1 mysql mysql 73074 May 22 09:30 myawr.html<br />
-rw-rw-r&#8211; 1 mysql mysql 53621 May 11 16:23 myawrrpt.pl</p>
<p>Mysql WorkLoad Report<br />
Let me show some pictures which come from my test db report:<br />
<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr2.png"><img class="alignnone size-full wp-image-335" alt="myawr2" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr2.png" width="616" height="243" /></a>  <a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr3.png"><img class="alignnone size-full wp-image-336" alt="myawr3" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr3.png" width="600" height="716" /></a><br />
<a href="http://www.noodba.com/wp-content/uploads/2013/05/myawr4.png"><img class="alignnone size-full wp-image-337" alt="myawr4" src="http://www.noodba.com/wp-content/uploads/2013/05/myawr4.png" width="815" height="390" /></a></p>
<p>For detail report ,pls click <a href="http://www.noodba.com/myawr.html">myawr.html</a></p>
<h2>6. Contact me</h2>
<p>Any questions,pls contact me freely. </p>
<p>EMAIL: qiuwsh@gmail.com<br />
Q Q : 570182914<br />
Phone: (+86)13817963180</p>
<p>&nbsp;</p>

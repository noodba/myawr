1.What is myawr
Myawr is a tool for collecting and analyzing performance data for MySQL database (including os info ,mysql status info and Slow Query Log  all of details). The idea comes from Oracle awr. Myawr periodic collect data and save to the database as snapshots. Myawr was designed as CS architecture.Myawr depends on performance schema of MySQL database. Myawr consists of two parts:

myawr.pl--------a perl script for collecting mysql performance data
myawrrpt.pl-----a perl script for analyzing mysql performance data
Myawr relies on the Percona Toolkit to do the slow query log collection. Specifically you can run pt-query-digest. To parse your slow logs and insert them into your server database for reporting and analyzing. 
Thanks to orzdba.pl (zhuxu@taobao.com).


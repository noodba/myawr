<h2>1.What is myawr</h2>
Myawr is a tool for collecting and analyzing performance data for MySQL database (including os info ,mysql status info and Slow Query Log  all of details). The idea comes from Oracle awr. Myawr periodic collect data and save to the database as snapshots. Myawr was designed as CS architecture.Myawr depends on performance schema of MySQL database. Myawr consists of two parts:

<b>myawr.pl</b><b>--------a perl script for collecting mysql performance data
</b><b>myawrrpt.pl-----a perl script for analyzing mysql performance data</b>

Myawr relies on the <a href="http://www.percona.com/software/percona-toolkit/">Percona Toolkit</a> to do the slow query log collection. Specifically you can run <a href="http://www.percona.com/doc/percona-toolkit/2.0/pt-query-digest.html">pt-query-digest</a>. To parse your slow logs and insert them into your server database for reporting and analyzing.

Thanks to orzdba.pl (<a href="mailto:zhuxu@taobao.com">zhuxu@taobao.com</a>).

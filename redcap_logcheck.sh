#!/bin/bash
# Alf 20230423 - look for possible redcap exploits in log_view table
#              - based on rob.taylor post https://redcap.vanderbilt.edu/community/post.php?id=203813
#              - this script database credentials from ~/.my.cnf
# Alf 20230425 - tail sql output, use host & db vars, add run duration output

HOST="127.0.0.1"
DB="redcapdb"

START=`date +%s`

echo -n "redcap_log_view rows: "
mysql -h $HOST -D $DB <<QUERY | tail -1
SELECT count(ts) from redcap_log_view;
QUERY

echo ""
echo -n "From "
mysql -h $HOST -D $DB <<QUERY | tail -1
SELECT min(ts) from redcap_log_view;
QUERY

echo -n "  To "
mysql -h $HOST -D $DB <<QUERY | tail -1
SELECT max(ts) from redcap_log_view;
QUERY

echo ""
echo -n "PDF export exploit matches: "
mysql -h $HOST -D $DB <<QUERY | tail -1
SELECT count(*) from redcap_log_view
WHERE full_url like '%/surveys/index.php?s=%'
AND full_url like '%&__passthru=index.php%'
AND full_url like '%&route=PDFController:index%'
AND full_url like '%&id=%';
QUERY

echo ""
echo -n "Remote Code Execution exploit matches: "
mysql -h $HOST -D $DB <<QUERY | tail -1
SELECT count(*) from redcap_log_view
WHERE full_url like '%/surveys/index.php?s=%'
AND full_url like '%&__passthru=index.php%'
AND full_url like '%&route=DataImportController:index%';
QUERY

END=`date +%s`
DUR=$(($END-$START))

echo
echo "(This check took $DUR seconds to run)"

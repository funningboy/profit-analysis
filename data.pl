
#==================================================
#author: sean chen mail: funningboy@gmail.com
#publish 2010/10/27
#License: BSD
#==================================================

use PROFIT::profit;
use strict;

my %data = (
	"START_TIME"        => '2010/09/01',	#開始時間
	"END_TIME"          => '2010/10/18',    #結束時間
	"CAPITAL"           => '500000',        #成本
	"LEAVE_PROFIT_LOST" => '10.0',          #出場停損 10%
	"LEAVE_PROFIT_MAKE" => '7.0',           #出場獲利 7%
	"KEEP_PROFIT_LOST"  => '5.0',           #持有時確保 損失 達 -5%,如超過則回補
        "KEEP_PROFIT_MAKE"  => '3.0',           #持有時確保 獲利 達  3%,如操過則加碼   
	"KEEP_PROFIT_LOST_T"=> '1',             #最多回補次數 3 次
	"KEEP_PROFIT_MAKE_T"=> '1',             #最多加碼次數 3 次
	"KEEP_PROFIT_LENGTH"=> '3',             #每5 天 check 損失/獲利
	"PRICE_UP_LIMIT"    => '40',            #股價 < 100 的才會進場 check
	"PRICE_DN_LIMIT"    => '10',            #股價 > 10  的才會進場 check
);

my $prt = PROFIT::profit->new(%data);
   $prt->get_input_set();
   $prt->set_history_path("./daily/");
   $prt->set_profit_info("Sharkv2_2010_09_10_c3.csv");
   $prt->get_profit_run();
   $prt->get_profit_report("rep.csv");

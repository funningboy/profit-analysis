#!/usr/bin/perl

package PROFIT::profit;

use FINANCE::HISTORY_INFO;
use FINANCE::UTIL;
use Data::Dumper;
use Switch;
use strict;
use Class::Struct;

$PROFIT::profit::START_TIME;
$PROFIT::profit::END_TIME;
$PROFIT::profit::CAPITAL;
$PROFIT::profit::LEAVE_PROFIT_MAKE;
$PROFIT::profit::LEAVE_PROFIT_LOST;
$PROFIT::profit::KEEP_PROFIT_LOST;
$PROFIT::profit::KEEP_PROFIT_MAKE;
$PROFIT::profit::KEEP_PROFIT_LENGTH;
$PROFIT::profit::KEEP_PROFIT_LOST_T;
$PROFIT::profit::KEEP_PROFIT_MAKE_T;
$PROFIT::profit::PRICE_UP_LIMIT;
$PROFIT::profit::PRICE_DN_LIMIT;

$PROFIT::profit::HISTOTY_PATH;

struct ENTRY => [ 
        ET_TIME => '$',
        LE_TIME => '$',
        ET_PRIC => '$',
        LE_PRIC => '$',
	ET_TICK => '$',
	LE_TICK => '$',
        PROFIT  => '$',
 ];


# input part
%PROFIT::profit::INPUTList;
%PROFIT::profit::DATAList;

%PROFIT::profit::ENTRYList;

sub get_help{
    my ($case,@in) = (@_); 

    switch($case){
      case "get_input_info"  { printf ("please check \"START_TIME\", \"END_TIME\", \"CAPITIAL\" had already define in your hash table...\n"); }
      case "get_file_info"   { printf ("please check the file path had already exist @ $in[0]...\n");                                         }
      case "get_entry_info"  { printf ("please check the file format had \"Entry stock ID\", \"Entry time\" at least...\n");                  }
      case "get_id_info"     { printf ("please check the stock ID is ok, ex 2330.TW @ $in[0] ...\n");                                         }
      case "get_time_info"   { printf ("please check the time is ok, ex 2010/01/01  @ $in[0]...\n");                                          }
      case "get_history_info"{ printf ("please check the history path is ok @ $in[0]...\n");                                                  }
      case "get_outrag_info" { printf ("please chech the time range match @ history data bg = $in[0], ed = $in[2], mi = $in[1]...\n");        }
   }

die;
}

sub check_input{
    my (%hs) = (@_);
    
    if( !defined($hs{"START_TIME"} )|| 
        !defined($hs{"END_TIME"}   )||
        !defined($hs{"CAPITAL"}    )     ){ get_help("get_input_info"); }

$PROFIT::profit::START_TIME        =   $hs{"START_TIME"};
$PROFIT::profit::END_TIME          =   $hs{"END_TIME"}; 
$PROFIT::profit::CAPITAL           =   $hs{"CAPITAL"};
$PROFIT::profit::LEAVE_PROFIT_LOST = ( defined($hs{"LEAVE_PROFIT_LOST"} ))? $hs{"LEAVE_PROFIT_LOST"}/100 : 0.1;
$PROFIT::profit::LEAVE_PROFIT_MAKE = ( defined($hs{"LEAVE_PROFIT_MAKE"} ))? $hs{"LEAVE_PROFIT_MAKE"}/100 : 0.07;
$PROFIT::profit::KEEP_PROFIT_LOST  = ( defined($hs{"KEEP_PROFIT_LOST"}  ))? $hs{"KEEP_PROFIT_LOST"}/100  : 0.05;
$PROFIT::profit::KEEP_PROFIT_MAKE  = ( defined($hs{"KEEP_PROFIT_MAKE"}  ))? $hs{"KEEP_PROFIT_MAKE"}/100  : 0.03;
$PROFIT::profit::KEEP_PROFIT_LOST_T= ( defined($hs{"KEEP_PROFIT_LOST_T"}))? $hs{"KEEP_PROFIT_LOST_T"}    : 3;
$PROFIT::profit::KEEP_PROFIT_MAKE_T= ( defined($hs{"KEEP_PROFIT_MAKE_T"}))? $hs{"KEEP_PROFIT_MAKE_T"}    : 3;
$PROFIT::profit::KEEP_PROFIT_LENGTH= ( defined($hs{"KEEP_PROFIT_LENGTH"}))? $hs{"KEEP_PROFIT_LENGTH"}    : 5;
$PROFIT::profit::PRICE_UP_LIMIT    = ( defined($hs{"PRICE_UP_LIMIT"}    ))? $hs{"PRICE_UP_LIMIT"}        : -1;
$PROFIT::profit::PRICE_DN_LIMIT    = ( defined($hs{"PRICE_DN_LIMIT"}    ))? $hs{"PRICE_DN_LIMIT"}        : -1;

}

sub get_input_set{
   my ($self) = (@_);

print "START_TIME        :: ".$PROFIT::profit::START_TIME."\n";        
print "END_TIME          :: ".$PROFIT::profit::END_TIME."\n";          
print "CAPITAL           :: ".$PROFIT::profit::CAPITAL."\n";           
print "LEAVE_PROFIT_LOST :: ".$PROFIT::profit::LEAVE_PROFIT_LOST."\n"; 
print "LEAVE_PROFIT_MAKE :: ".$PROFIT::profit::LEAVE_PROFIT_MAKE."\n"; 
print "KEEP_PROFIT_LOST  :: ".$PROFIT::profit::KEEP_PROFIT_LOST."\n";  
print "KEEP_PROFIT_MAKE  :: ".$PROFIT::profit::KEEP_PROFIT_MAKE."\n";  
print "KEEP_PROFIT_LOST_T:: ".$PROFIT::profit::KEEP_PROFIT_LOST_T."\n";
print "KEEP_PROFIT_MAKE_T:: ".$PROFIT::profit::KEEP_PROFIT_MAKE_T."\n";
print "KEEP_PROFIT_LENGTH:: ".$PROFIT::profit::KEEP_PROFIT_LENGTH."\n";
print "PRICE_UP_LIMIT    :: ".$PROFIT::profit::PRICE_UP_LIMIT."\n";    
print "PRICE_DN_LIMIT    :: ".$PROFIT::profit::PRICE_DN_LIMIT."\n";    
print "\n";
print "\n";
}


sub check_history_data{
my ($id) = (@_);
my $file = $PROFIT::profit::HISTOTY_PATH.$id.".csv";
if( !-e $file ){ get_help("get_history_info",$file); }

# read history info && set 
my $info   = FINANCE::HISTORY_INFO->new();
my $hslist = $info->get_file_info($file);
   if( $hslist ==-1 ){ get_help("get_history_info",$file); }
  
    $PROFIT::profit::DATAList{$id} = $hslist;
}

sub check_file_format{
    my ($file) = (@_);
 
    open (ifile,"<$file") or die "open $file error\n";

    my @arr;

    while(<ifile>){
      chomp;
      
      @arr = split("\,",$_); 

      if($#arr < 1                 ){ get_help("get_entry_info"); }
   elsif($#arr== 1 || $#arr == 5   ){ 
          if($arr[0] !~ /[0-9\.TW]/){ get_help("get_id_info",$arr[0]);   }
	  if($arr[1] !~ /[0-9\/]/  ){ get_help("get_time_info",$arr[1]); }

          my $et = ENTRY->new();
             $et->ET_TIME(  $arr[1]);
             $et->LE_TIME( ($#arr ==5 )? $arr[2] : -1 );
             $et->ET_PRIC( ($#arr ==5 )? $arr[3] : -1 );
             $et->LE_PRIC( ($#arr ==5 )? $arr[4] : -1 );
             $et->PROFIT(  ($#arr ==5 )? $arr[5] : -1 );
             $et->ET_TICK(-1);
             $et->LE_TICK(-1);
 
             check_history_data($arr[0]);         

           push( @{$PROFIT::profit::INPUTList{$arr[0]}}, $et ); 
             
       } 
   }

close(ifile);
#printf Dumper(\%PROFIT::profit::INPUTList);
#printf Dumper(\%PROFIT::profit::DATAList);
#die
}

sub new {
my ($self,%hs) = (@_);

   %PROFIT::profit::INPUTList =();
   %PROFIT::profit::DATAList  =();
   %PROFIT::profit::ENTRYList =();

    check_input(%hs);
#    $self = NETRY->new();
return bless {};
} 

sub set_history_path{
my ($self,$path) = (@_);
    $PROFIT::profit::HISTOTY_PATH = $path;
}

sub set_profit_info{
my ($self,$file) = (@_);
 
  if( !-e $file) { get_help("get_file_info",$file); }
  check_file_format($file); 

} 

sub set_make_entry_list{
  my ($id,$inx,$pric,$i) = (@_);
  my $entry = ENTRY->new (
                          ET_TIME => $inx,
                          LE_TIME => -1,
                          ET_PRIC => $pric,
                          LE_PRIC => 0,
                          ET_TICK => 1,
                          LE_TICK => 0,
                          PROFIT  => 0,
                         );

     $PROFIT::profit::ENTRYList{$id}{$i} = $entry;
} 


sub check_entry_list{
  my ($id,$inx,$pric) = (@_);

  my ($tcot,$tpric,$avg_pric) =0;
  my $entry = ENTRY->new();

  foreach my $i ( sort {$a<=>$b} keys %{$PROFIT::profit::ENTRYList{$id}} ){
         $entry = $PROFIT::profit::ENTRYList{$id}{$i};
 
      if( $entry->LE_TIME == -1 ){
         $tpric += $entry->ET_PRIC * $entry->ET_TICK;
         $entry->PROFIT( ($pric - $entry->ET_PRIC) * $entry->ET_TICK);
         $tcot++;
      }
  }
  
  $avg_pric = ($tcot!=0)? ($tpric / $tcot) : 0;

    if( $pric > $avg_pric * (1 + $PROFIT::profit::LEAVE_PROFIT_MAKE)){  return ("LEAVE_MAKE",$tpric,$avg_pric);  }
 elsif( $pric < $avg_pric * (1 - $PROFIT::profit::LEAVE_PROFIT_LOST)){  return ("LEAVE_LOST",$tpric,$avg_pric);  }
 elsif( $pric > $avg_pric * (1 + $PROFIT::profit::KEEP_PROFIT_MAKE) ){  return ("KEEP_MAKE",$tpric,$avg_pric);   }
 elsif( $pric < $avg_pric * (1 - $PROFIT::profit::KEEP_PROFIT_LOST) ){  return ("KEEP_LOST",$tpric,$avg_pric);   }
 else{                                                                  return ("NOP",$tpric,$avg_pric);         }  

}

sub set_keep_make_entry_list{
  my ($id,$inx,$pric,$i,$tpric,$avg_pric) = (@_);

  my ($tick,$tavg_pric) =(1,$avg_pric);

  while( $pric > $tavg_pric * (1 + $PROFIT::profit::KEEP_PROFIT_MAKE) ){
         $tavg_pric = ($tick * $pric + $avg_pric )/($tick +1 );
         $tick++;
  } 

  my $entry = ENTRY->new(
                          ET_TIME => $inx,
                          LE_TIME => -1,
                          ET_PRIC => $pric,
                          LE_PRIC => 0,
                          ET_TICK => $tick--,
                          LE_TICK => 0,
                          PROFIT  => 0,
                         );

     $PROFIT::profit::ENTRYList{$id}{$i} = $entry;
}

sub set_keep_lost_entry_list{
  my ($id,$inx,$pric,$i,$tpric,$avg_pric) = (@_);

  my ($tick,$tavg_pric) =(1,$avg_pric);

  while( $pric < $tavg_pric * (1 - $PROFIT::profit::KEEP_PROFIT_LOST) ){
         $tavg_pric = ($tick * $pric + $avg_pric )/($tick +1 );
         $tick++;
  } 

  my $entry = ENTRY->new(
                          ET_TIME => $inx,
                          LE_TIME => -1,
                          ET_PRIC => $pric,
                          LE_PRIC => 0,
                          ET_TICK => $tick--,
                          LE_TICK => 0,
                          PROFIT  => 0,
                         );

     $PROFIT::profit::ENTRYList{$id}{$i} = $entry;
}

sub set_leave_make_entry_list{
  my ($id,$inx,$pric,$i,$tpric,$avg_pric) = (@_);

  my $entry = ENTRY->new();
 
  foreach my $j ( sort {$a<=>$b} keys %{$PROFIT::profit::ENTRYList{$id}}){
      $entry = $PROFIT::profit::ENTRYList{$id}{$j};
  
      if( $entry->LE_TIME == -1){     
          $entry->LE_TIME($inx);
          $entry->LE_PRIC($pric);
          $entry->LE_TICK($entry->ET_TICK);
          $PROFIT::profit::ENTRYList{$id}{$j} = $entry;
      }
 }
}

sub set_leave_lost_entry_list{
  my ($id,$inx,$pric,$i,$tpric,$avg_pric) = (@_);

  my $entry = ENTRY->new();
 
  foreach my $j ( sort {$a<=>$b} keys %{$PROFIT::profit::ENTRYList{$id}}){
      $entry = $PROFIT::profit::ENTRYList{$id}{$j};

     if(  $entry->LE_TIME == -1){     
          $entry->LE_TIME($inx);
          $entry->LE_PRIC($pric);
          $entry->LE_TICK($entry->ET_TICK);
          $PROFIT::profit::ENTRYList{$id}{$j} = $entry;
      }
   }
}


sub call {
  my ($st,$id,$time) = (@_);
  printf $id." ".$st." @ ".$time."\n";
}

sub get_profit_run{
my ($self) = (@_);

 foreach my $id (keys %PROFIT::profit::INPUTList) {
        my ($cot,$make_t,$lost_t) =0;

    foreach my $lt (@{$PROFIT::profit::INPUTList{$id}}){
        my $hslist= $PROFIT::profit::DATAList{$id};
        my $util  = FINANCE::UTIL->new($hslist);
        my $bg_inx= $util->get_inx_by_time($PROFIT::profit::START_TIME);
        my $ed_inx= $util->get_inx_by_time($PROFIT::profit::END_TIME);
        my $tt_inx= $util->get_inx_by_time($lt->ET_TIME);

        # check inx 
        if( $tt_inx < $bg_inx || $tt_inx > $ed_inx ){ get_help("get_outrag_info",($bg_inx,$tt_inx,$ed_inx)); }  

        # check UP/DN define or not
        if( ( $PROFIT::profit::PRICE_UP_LIMIT != -1 && $util->get_hg_pric_by_inx($tt_inx) > $PROFIT::profit::PRICE_UP_LIMIT )||
            ( $PROFIT::profit::PRICE_DN_LIMIT != -1 && $util->get_lw_pric_by_inx($tt_inx) < $PROFIT::profit::PRICE_DN_LIMIT ) ){ next; }
         
        #Entry point @ nxt bar by tomorrow open price
        call("entrty market",$id,$util->get_time_by_inx($tt_inx+1));
        set_make_entry_list($id,
                            $util->get_time_by_inx($tt_inx+1),
                            $util->get_op_pric_by_inx($tt_inx+1),
                            $cot); $cot++;                 

        #check constrains @ MAKE_PROFIT_LEAVE,LOSE_PROFIT_LEAVE,KEEP_PROFIT;
        for(my $i= $tt_inx+2; $i<=$ed_inx; $i+=$PROFIT::profit::KEEP_PROFIT_LENGTH){
            my @rst = check_entry_list($id,
                                       $util->get_time_by_inx($i),
                                       ($util->get_lw_pric_by_inx($i)+$util->get_cl_pric_by_inx($i))>>1);
              # print Dumper(\@rst); 
 
             if($rst[0] eq "KEEP_MAKE" && $make_t < $PROFIT::profit::KEEP_PROFIT_MAKE_T){ 
                call("entrty KEEP MAKE market",$id,$util->get_time_by_inx($i));
                set_keep_make_entry_list($id,
                                         $util->get_time_by_inx($i),
                                        ($util->get_lw_pric_by_inx($i)+$util->get_cl_pric_by_inx($i))>>1,
                                         $cot,
                                         $rst[1],
                                         $rst[2]); $make_t++; $cot++;

        } elsif($rst[0] eq "KEEP_LOST" && $lost_t < $PROFIT::profit::KEEP_PROFIT_LOST_T){ 
                call("entrty KEEP LOST market",$id,$util->get_time_by_inx($i));
                set_keep_lost_entry_list($id,
                                         $util->get_time_by_inx($i),
                                        ($util->get_lw_pric_by_inx($i)+$util->get_cl_pric_by_inx($i))>>1,
                                         $cot,
                                         $rst[1],
                                         $rst[2]); $lost_t++; $cot++;

        } elsif($rst[0] eq "LEAVE_MAKE"){ 
                call("leave MAKE market",$id,$util->get_time_by_inx($i));
                set_leave_make_entry_list($id,
                                          $util->get_time_by_inx($i),
                                          $util->get_cl_pric_by_inx($i),
                                          $cot,
                                          $rst[1],
                                          $rst[2]); 
        } elsif($rst[0] eq "LEAVE_LOST"){ 
               call("leave LOST market",$id,$util->get_time_by_inx($i));
               set_leave_lost_entry_list($id,
                                         $util->get_time_by_inx($i),
                                         $util->get_cl_pric_by_inx($i),
                                         $cot,
                                         $rst[1],
                                         $rst[2]); }


        } 
                 
       }
 
#printf Dumper(\%PROFIT::profit::ENTRYList);
#die;

     }
}

sub get_profit_report{
my ($self,$file) = (@_);

#printf Dumper(\%PROFIT::profit::ENTRYList);

open (ofile,">$file") or die printf("open report file error\n"); 

my $entry = ENTRY->new();

my %make_hs =();
my %lost_hs =();

my ($tprf,$tcap) = (0,$PROFIT::profit::CAPITAL);

 printf ofile "Total lists\n";
 printf ofile "stock_id,trade_times,entry_time,leave_time,entry_price,leave_price,entry_ticket,leave_ticket,profits,capitals\n";

 foreach my $id ( sort keys %PROFIT::profit::ENTRYList){
   foreach my $i ( sort {$a<=>$b} keys %{$PROFIT::profit::ENTRYList{$id}} ){
       $entry = $PROFIT::profit::ENTRYList{$id}{$i};
       $tcap  = $tcap - 1000*($entry->ET_PRIC * $entry->ET_TICK + $entry->LE_PRIC * $entry->LE_TICK);

       $tprf  += $entry->PROFIT;
 
       printf ofile $id.",".
                    $i.",".
                    $entry->ET_TIME.",".
                    $entry->LE_TIME.",".
                    $entry->ET_PRIC.",".
                    $entry->LE_PRIC.",". 
	            $entry->ET_TICK.",". 
	            $entry->LE_TICK.",". 
                    $entry->PROFIT.",".
                    $tcap."\n";  

      if($entry->PROFIT >0 ){ $make_hs{$entry->PROFIT}{$id} = $entry; }
      else{                   $lost_hs{$entry->PROFIT}{$id} = $entry; } 

    }
  }

 printf ofile "\n";

 printf ofile "Reports\n";
 printf ofile "Cur profits,".(1000*$tprf)."\n";
 printf ofile "MAX capital,".($PROFIT::profit::CAPITAL-$tcap)."\n";

 printf ofile "\n";

 printf ofile "MAKE profit list\n";
 printf ofile "stock_id,entry_time,leave_time,entry_price,leave_price,entry_ticket,leave_ticket,profits\n";

 foreach my $mk ( reverse sort {$a<=>$b} keys %make_hs ){
    foreach my $id (keys %{$make_hs{$mk}} ){
        $entry = $make_hs{$mk}{$id};
 
      printf ofile $id.",".
                    $entry->ET_TIME.",".
                    $entry->LE_TIME.",".
                    $entry->ET_PRIC.",".
                    $entry->LE_PRIC.",". 
	            $entry->ET_TICK.",". 
	            $entry->LE_TICK.",". 
                    $entry->PROFIT."\n";
    }
  }

 printf ofile "\n";

 printf ofile "LOST profit list\n"; 
 printf ofile "stock_id,entry_time,leave_time,entry_price,leave_price,entry_ticket,leave_ticket,profits\n";

foreach my $mk ( sort {$a<=>$b} keys %lost_hs ){
    foreach my $id (keys %{$lost_hs{$mk}} ){
        $entry = $lost_hs{$mk}{$id};
 
      printf ofile $id.",".
                    $entry->ET_TIME.",".
                    $entry->LE_TIME.",".
                    $entry->ET_PRIC.",".
                    $entry->LE_PRIC.",". 
	            $entry->ET_TICK.",". 
	            $entry->LE_TICK.",". 
                    $entry->PROFIT."\n";
    }
  }

close(ofile);

}

1;

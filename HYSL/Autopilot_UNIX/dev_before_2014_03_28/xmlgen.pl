# Author : Yuki Hashimoto
# Date   : 02/15/2012
# Purpose: Generate GTLF-formatted XML files from regression test results

use File::Copy;

%testdesc=('agapmain' => 'Application_manipulation',
	       'agbgmain' => 'Agent_Bugs',
	       'aglgmain' => 'Networking',
	       'agsymain' => 'Security',
	       'apbgmain' => 'API_Bugs',
	       'apgdmain' => 'Grid_API',
	       'apgemain' => 'General_API',
	       'Apotmain' => 'Outline_API',
	       'dcbgmain' => 'Distributed_cube_Bugs',
	       'dcmpmain' => 'Mixed_partitions',
	       'dcosmain' => 'Outline_synchronization',
		   'dcrpmain' => 'Replicated_partitions',
	       'dctpmain' => 'Transparent_partitions',
	       'ddbgmain' => 'Data_Definition_Bugs',
	       'ddldmain' => 'Data_loader',
	       'Ddximain' => 'Export,_Import',
	   	   'dmbgmain' => 'Data_manipulation_Bugs',
	       'dmccmain' => 'Calculator',
	       'dmdcmain' => 'Dynamic_calculator',
	       'dmglmain' => 'Fusion_GL',
	       'dmpcmain' => 'Parallel_Calc',
	       'dmudmain' => 'CDM/UDF_(UDM/UDF)',
	       'dresmain' => 'Miscellaneous_Bugs',
	       'dxbgmain' => 'Data_Extraction_Bugs',
	       'dxmdmain' => 'MDX',
	       'dxrrmain' => 'Report_writer',
	       'dxssmain' => 'Spreadsheet_extractor',
	       'maxlmain' => 'Maxl_Tests',
	       'msscmain' => 'EssCmd',
	       'sdatmain' => 'Attributes',
	       'sdbgmain' => 'Scheme_definition_Bugs',
	       'sddbmain' => 'Dimension_build',
	       'sdremain' => 'Scheme_manipulation',
	       'sdsvmain' => 'Substitution_variables',
	       'smalmain' => 'Allocation_manager',
	       'smbgmain' => 'Storage_manager_Bugs',
	       'smbumain' => 'Backup',
	       'smixmain' => 'Index_manager',
	       'smlrmain' => 'LRO',
	       'smtxmain' => 'Transaction_manager');

if ( $#ARGV < 1 ){
  print "\nSynpsis: perl xmlgen.pl <release_build> <output dir>\n\n";
  exit 0;
}

if (exists $ENV{"AUTOPILOT"}){
  $res_dir=$ENV{"AUTOPILOT"}."/res";
  $classpath=$ENV{"AUTOPILOT"}."/tools/gtlf/gtlfutils-core.jar";
}else{
  print "\nType the AUTOPILOT path: ";
  $autopilot=<STDIN>;
  chomp($autopilot);
  $res_dir=$autopilot."/res";
  $classpath=$autopilot."/tools/gtlf/gtlfutils-core.jar";
}
$res_dir=~s{\\}{/}g;
$classpath=~s{\\}{/}g;

my $ver=$ARGV[0];
my $xml_destdir=$ARGV[1];
$xml_destdir=~s{\\}{/}g;

if(exists $ENV{"TMP"}){
  $tmp_dir=$ENV{"TMP"};
}elsif(exists $ENV{"TEMP"}){
  $tmp_dir=$ENV{"TEMP"};
}else{
  print "\nType a temp directory: ";
  chomp($tmp_dir);
}
$tmp_dir=~s{\\}{/}g;

print "\ntmp_dir    : $tmp_dir\n";
print "res_dir    : $res_dir\n";
print "classpath  : $classpath\n";
print "xml_destdir: $xml_destdir\n\n";

my %primary_config = ( linux => 'LINUX', linuxamd64 => 'LINUX64', aix => 'AIX', aix64 => 'AIX64',
	                   solaris => 'SOLARIS', solaris64 => 'SolarisSparc64', 'solaris.x64' => 'SOLARISX64',
	                   hpux => 'HPUX', hpux64 => 'HPUX64', win32 => 'WINDOWS', winamd64 => 'WINDOWS64' );

opendir(DIR, $res_dir);
@files=grep !/^\.\.?$/, readdir(DIR);
closedir(DIR);

foreach $file (@files){
  if (index($file, $ver) > 5 && substr($file, -2, 2) =~ "gz" ){
    $firstUS=index($file, "_");
    $platform=substr($file, 0, $firstUS);
    $secondUS=index($file, "_", $firstUS+1);
    $release=substr($file, $firstUS+1, $secondUS-$firstUS-1);
    $thirdUS=index($file, "_", $secondUS+1);
    $build=substr($file, $secondUS+1, $thirdUS-$secondUS-1);
    $name=substr($file, $thirdUS+1, length($file)-8-$thirdUS);
    if(index($name, "i18n") != 0 && $name !~ "xprobmain"){
      print "Processing $file\n";
#      print "platform: $platform\n";
#      print "release : $release\n";
#      print "build   : $build\n";
#      print "name    : $name\n";
      
      unlink($tmp_dir."/".$file);
      copy ($res_dir."/".$file, $tmp_dir."/".$file);
      `gunzip -f $tmp_dir/$file`;
      $tar_file=substr($file, 0, length($file)-3);
      print $tar_file."\n";
      `tar xf $tmp_dir/$tar_file -C $tmp_dir`;
      $work_dir=$tmp_dir."/work_".$name;
      
      $xml_filename=$release."_".$build."_".$platform."_".$name."_gtlf.xml";
      $xml_srcdir=$work_dir;
      if(exists $testdesc{$name}){
      	$name_tmp=$testdesc{$name}."_".$name;
      }else{
      	$name_tmp=$name;
      }
      $xml_testunit="AUTO_EssbaseServer-".$name_tmp."LRG";
      $xml_release="EssTools".$release;
      $xml_product="EssbaseTools";
      $xml_runid="essbase_test_".$xml_filename;
      $xml_runkey=$xml_runid."_reg";
      $xml_primary_config=$primary_config{$platform};

      unless(-d $xml_destdir){
      	mkdir $xml_destdir or die;
      }
      
      $java_option="-Dgtlf.toptestfile=unknown -Dgtlf.testruntype=unknown -Dgtlf.string=4 -Dgtlf.env.NativeIO=true -Dgtlf.env.Primary_Config=$xml_primary_config -Dgtlf.branch=main -srcdir $xml_srcdir -destdir $xml_destdir -filename $xml_filename -testunit $xml_testunit -Dgtlf.product=$xml_product -Dgtlf.release=$xml_release -Dgtlf.load=1 -Dgtlf.runid=$xml_runid -Dgtlf.env.RunKey=$xml_runkey -Dgtlf.execaccount=Administrator";
      `java -Xms512m -Xmx512m -classpath $classpath org.testlogic.toolkit.gtlf.converters.file.Main $java_option`;
      unlink($tmp_dir."/".$tar_file);
      `rm -rf $work_dir`;
    }
  }
}

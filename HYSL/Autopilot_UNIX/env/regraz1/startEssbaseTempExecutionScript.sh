# test
export HYPERION_HOME=/vol1/regraz1/Hyperion 
export ARBORPATH=/vol1/regraz1/Hyperion/AnalyticServices 
export ESSLANG=English_UnitedStates.Latin1@Binary 
export LD_LIBRARY_PATH=$HYPERION_HOME/common/ODBC/Merant/5.2/lib:$ARBORPATH/bin:$LD_LIBRARY_PATH 
export PATH=$ARBORPATH/bin:$PATH 
export ODBCINI=$HYPERION_HOME/common/ODBC/Merant/5.2/odbc.ini 
export ESS_JVM_OPTION1=-Xusealtsigs 
export ESS_CSS_JVM_OPTION1=-Xusealtsigs 
export AIXTHREAD_SCOPE=S
$ARBORPATH/bin/ESSBASE 

; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
; This script is for release 1.6.7 of MAS on Windows.

[Setup]
AppName=Market Analysis System
AppVerName=Market Analysis System 1.6.7
AppPublisher=Jim Cochrane
AppPublisherURL=http://eiffel-mas.sf.net
AppSupportURL=http://eiffel-mas.sf.net
AppUpdatesURL=http://eiffel-mas.sf.net
DefaultDirName=C:\Program Files\mas1.6.7
DefaultGroupName=Market Analysis System
OutputBaseFilename=setup-mas1.6.7
AlwaysCreateUninstallIcon=yes
; uncomment the following line if you want your installation to run on NT 3.51 too.
; MinVersion=4,3.51

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Files]
Source: "bin\simple_cat.exe"; DestDir: "{app}\bin"; CopyMode: alwaysoverwrite
Source: "bin\macl"; DestDir: "{app}\bin\scripts"; CopyMode: alwaysoverwrite
Source: "bin\maclj"; DestDir: "{app}\bin\scripts"; CopyMode: alwaysoverwrite
Source: "bin\magc"; DestDir: "{app}\bin\scripts"; CopyMode: alwaysoverwrite
Source: "lib\binaries\mas.exe_no_assert_v1.6.7"; DestDir: "{app}\bin\mas.exe"; CopyMode: alwaysoverwrite
Source: "bin\runmacl.bat"; DestDir: "{app}\bin"; CopyMode: alwaysoverwrite
Source: "bin\runmas.bat"; DestDir: "{app}\bin"; CopyMode: alwaysoverwrite
Source: "bin\runmasf.bat"; DestDir: "{app}\bin"; CopyMode: alwaysoverwrite
Source: "bin\runmasgui.bat"; DestDir: "{app}\bin"; CopyMode: alwaysoverwrite
Source: "bin\fake_mailer.bat"; DestDir: "{app}\bin"; CopyMode: alwaysoverwrite
Source: "bin\init.bat"; DestDir: "{app}\lib\install"; CopyMode: alwaysoverwrite
Source: "doc\README.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\INTRODUCTION.ps"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\INTRODUCTION.html"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\creating_market_analyzers.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\environment.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\feature_list.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\GUI_introduction.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "README_WINDOWS.txt"; DestDir: "{app}"; CopyMode: alwaysoverwrite; DestName: README.txt; Flags: isreadme
Source: "doc\market_analysis.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\masystem_introduction.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\other_market_analyzer_examples.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "doc\creating_indicators.txt"; DestDir: "{app}\doc"; CopyMode: alwaysoverwrite
Source: "lib\data\stock_splits"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\mas_httprc"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\symbols"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\mas_dbrc"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\generators_persist"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\indicators_persist"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\mas_external_retrieve.pl"; DestDir: "{app}\lib"; CopyMode: alwaysoverwrite
Source: "lib\config\accumulation_distribution"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\editind"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\ema_of_slope_of_ema"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\ema_of_slope_of_ema_close_to_0"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\ema_of_volume"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\force_index"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\indicators"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\macd_diffsig_crossover"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\macd_diffsigx_and_stoch_35"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\macd_of_volume"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\market_analyzers"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\midpoint"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\obv"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_ema_of_adx"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_ema_of_volume"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_macd_signal_close_to_0"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_macd_signal_trend"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_macd_signal_trend_analyzers"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_macd_sl"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_macd_sl_cross0"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_slope_of_macd_sl"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\slope_of_slope_of_macd_sl_cross0"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\smsl_ssmsl_trend"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\smsl_ssmsl_trend_analyzers"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\stoch_pctD_cross"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\test_indicators"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\triangular_ma"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\true_range"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\volume_gt_1million"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\volume_spike"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\wma_of_midpoint"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\config\wma_of_midpoint2"; DestDir: "{app}\lib\config"; CopyMode: alwaysoverwrite
Source: "lib\classes\common\NetworkProtocol.class"; DestDir: "{app}\lib\classes\common"; CopyMode: alwaysoverwrite
Source: "lib\classes\common\DataInspector.class"; DestDir: "{app}\lib\classes\common"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\TimeDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\BarDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\BasicDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\CandleDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\DataSet.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\DateDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\DoublePair.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\Drawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\FileFormatException.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\Gin.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\Graph.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\IndicatorDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\InteractiveGraph.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\LineDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\LoadMessage.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\LowerGraph.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\MainGraph.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\Markers.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\MarkerVertex.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\MarketDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\PriceDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\Range.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\RefSpec.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\RotateTextFilter.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\RTextLine.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\SpecialFunction.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\TemporalDrawer.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\TextLine.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\TextState.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\graph\Axis.class"; DestDir: "{app}\lib\classes\graph"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\WindowSettings.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\Chart.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\ChartSettings.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\CompressedConnection.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\Connection.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\DataSetBuilder.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\DialogSelection$1.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\DialogSelection$2.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\DialogSelection$3.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\DialogSelection.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\IndicatorColors$1.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\IndicatorColors$2.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\IndicatorColors.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\IndicatorListener.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\IndicatorSelection.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_Dialog$1.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_Dialog.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$1.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$2.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$3.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$4.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$5.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$6.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$7.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$8.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar$9.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_MenuBar.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MA_ScrollPane.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MarketSelection$1.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MarketSelection.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\MAS_Options.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\OptionFlags.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\Parser.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\SessionState.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\mas_gui\Chart$1.class"; DestDir: "{app}\lib\classes\mas_gui"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\Utilities.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\Configuration.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\ErrorBox$1.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\ErrorBox$2.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\ErrorBox$3.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\ErrorBox.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\FileReaderUtilities.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\GUI_Utilities.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\IndicatorGroup.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\IndicatorGroups.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\IntPair.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\support\Configuration$DateSetting.class"; DestDir: "{app}\lib\classes\support"; CopyMode: alwaysoverwrite
Source: "lib\classes\MA_Client.class"; DestDir: "{app}\lib\classes"; CopyMode: alwaysoverwrite
Source: "lib\classes\CL_Client.class"; DestDir: "{app}\lib\classes"; CopyMode: alwaysoverwrite
Source: "lib\.ma_clientrc"; DestDir: "{app}\lib\classes"; CopyMode: alwaysoverwrite
Source: "lib\data\tradables\*.txt"; DestDir: "{app}\lib\data"; CopyMode: alwaysoverwrite
Source: "lib\data\tradables\*.CSF"; DestDir: "{app}\lib\data"; CopyMode: alwaysoverwrite
Source: "lib\data\tradables\*.5-minute"; DestDir: "{app}\lib\data"; CopyMode: alwaysoverwrite
Source: "lib\data\symbols.mas"; DestDir: "{app}\lib\data"; CopyMode: alwaysoverwrite
Source: "lib\python\constants.py"; DestDir: "{app}\lib\python"; CopyMode: alwaysoverwrite
Source: "lib\python\ma_connection.py"; DestDir: "{app}\lib\python"; CopyMode: alwaysoverwrite
Source: "lib\python\ma_protocol.py"; DestDir: "{app}\lib\python"; CopyMode: alwaysoverwrite
Source: "lib\python\CommandProcessor.py"; DestDir: "{app}\lib\python"; CopyMode: alwaysoverwrite

[Icons]
Name: "{group}\MAS Server (web)"; Filename: "{app}\bin\runmas.bat"
Name: "{group}\MAS Server (files)"; Filename: "{app}\bin\runmasf.bat"
Name: "{group}\MAS Charts"; Filename: "{app}\bin\runmasgui.bat"
Name: "{group}\MAS Command-Line"; Filename: "{app}\bin\runmacl.bat"
Name: "{userdesktop}\MAS Server (web)"; Filename: "{app}\bin\runmas.bat"; MinVersion: 4,4; Tasks: desktopicon
Name: "{userdesktop}\MAS Server (files)"; Filename: "{app}\bin\runmasf.bat"; MinVersion: 4,4; Tasks: desktopicon
Name: "{userdesktop}\MAS Charts"; Filename: "{app}\bin\runmasgui.bat"; MinVersion: 4,4; Tasks: desktopicon
Name: "{userdesktop}\MAS Command-Line"; Filename: "{app}\bin\runmacl.bat"; MinVersion: 4,4; Tasks: desktopicon

[Messages]
FinishedLabel=Setup has finished installing [name] on your computer. The application may be launched by selecting the installed icons.%n%nNote: The [name] environment settings may not take effect right away.  If the [name] fails to run at first on your system, this may be the cause.  This can be fixed on Windows 95, 98, and Me systems by rebooting and on Windows NT, 2000, and XP systems by doing either of the following:%n%nLog out and then log back in or%n%nRight-click on "My Computer", select "Properties", Select the "Environment" settings, and left-click on the "OK" button.

[Run]
Filename: "{app}\lib\install\init.bat"; Parameters: "{app}"; Flags: shellexec
; Filename: "{app}\bin\runmas.bat"; Description: "Launch Market Analysis System"; Flags: nowait postinstall skipifsilent

[Registry]
;!!!With MCT, these env. settings are probably no longer needed - check!!!
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "MAS_DIRECTORY"; ValueData: "{app}\lib"
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "PATH"; ValueData: "{app}\bin"

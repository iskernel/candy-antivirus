#!/usr/bin/perl

use warnings;
use strict;
use v5.14;

use File::Copy;
use Test::More;

use IsKernel::CandyAntivirus::Configuration;

use constant DEFAULT_VIRUS_SIGNATURES_PATH => "../../TestFiles/test_xvirsig.cfg";
use constant DEFAULT_QUARANTINE_PATH => "../../TestFiles/TestQuarantine/";
use constant DEFAULT_WORKING_DIRECTORY_PATH => "../../TestFiles/";
use constant DEFAULT_PATH_TO_LOG => "../../TestFiles/test_log";
use constant DEFAULT_PATH_TO_QUARANTINE_LOG => "../../TestFiles/test_qlog";
use constant DEFAULT_EXTENSIONS => "all";
use constant DEFAULT_VIRUS_DETECTED_OPTION => "AskUser";
use constant DEFAULT_LINK_TO_WWW_DATABASE => "http://www.nlnetlabs.nl/downloads/antivirus/antivirus/virussignatures.strings";

use constant DEFAULT_NEW_VALUE => "default_new_value";

copy("../../TestFiles/default_test_config.cfg","../../TestFiles/test_config.cfg") or die "Copy failed: $!";

my $configuration = IsKernel::CandyAntivirus::Configuration->new("../../TestFiles/test_config.cfg");

ok($configuration->get_default_working_directory_path() eq DEFAULT_WORKING_DIRECTORY_PATH, 
   "Configuration_GetDefaultWorkingDirectory_InitialConfiguration_IsRead");

ok($configuration->get_extensions_option() eq DEFAULT_EXTENSIONS, 
   "Configuration_GetExtensionOption_InitialConfiguration_IsRead");

ok($configuration->get_path_to_log() eq DEFAULT_PATH_TO_LOG, 
   "Configuration_GetPathToLog_InitialConfiguration_IsRead");

ok($configuration->get_path_to_quarantine_log() eq DEFAULT_PATH_TO_QUARANTINE_LOG, 
   "Configuration_GetDefaultPathToQuarantineLog_InitialConfiguration_IsRead");

ok($configuration->get_path_to_www_database() eq DEFAULT_LINK_TO_WWW_DATABASE,
   "Configuration_GetPathToWwwDatabase_InitialConfiguration_IsRead");

ok($configuration->get_quarantine_path() eq DEFAULT_QUARANTINE_PATH,
   "Configuraton_GetQuarantinePath_InitialConfiguration_IsRead");

ok($configuration->get_virus_detected_option() eq DEFAULT_VIRUS_DETECTED_OPTION,
   "Configuration_GetVirusDetectedOption_InitialConfiguration_IsRead");

#
$configuration->set_default_working_drectory(DEFAULT_NEW_VALUE);
ok($configuration->get_default_working_directory_path() eq DEFAULT_NEW_VALUE, 
   "Configuration_SetDefaultWorkingDirectory_NewConfiguration_IsSet");

$configuration->set_extension_option(DEFAULT_NEW_VALUE);
ok($configuration->get_extensions_option() eq DEFAULT_NEW_VALUE, 
   "Configuration_SetExtensionOption_NewConfiguration_IsSet");

$configuration->set_path_to_log(DEFAULT_NEW_VALUE);
ok($configuration->get_path_to_log() eq DEFAULT_NEW_VALUE, 
   "Configuration_SetPathToLog_NewConfiguration_IsSet");

$configuration->set_path_to_quarantine_log(DEFAULT_NEW_VALUE);
ok($configuration->get_path_to_quarantine_log() eq DEFAULT_NEW_VALUE, 
   "Configuration_SetPathToQuarantineLog_NewConfiguration_IsSet");

$configuration->set_path_to_www_database(DEFAULT_NEW_VALUE);
ok($configuration->get_path_to_www_database() eq DEFAULT_NEW_VALUE,
   "Configuration_SetPathToWwwDatabase_NewConfiguration_IsSet");

$configuration->set_quarantine_path(DEFAULT_NEW_VALUE);
ok($configuration->get_quarantine_path() eq DEFAULT_NEW_VALUE,
   "Configuraton_SetQuarantinePath_InitialConfiguration_IsSet");

$configuration->set_virus_detected_option(DEFAULT_NEW_VALUE);
ok($configuration->get_virus_detected_option() eq DEFAULT_NEW_VALUE,
   "Configuration_SetVirusDetectedOption_NewConfiguration_IsSet");

$configuration->set_virus_database_path(DEFAULT_NEW_VALUE);
ok($configuration->get_virus_database_path() eq DEFAULT_NEW_VALUE,
   "Configuration_SetVirusDatabasePath_NewConfiguration_IsSet");

$configuration->save_settings();
$configuration->load();
my $condition = (($configuration->get_default_working_directory_path() eq DEFAULT_NEW_VALUE) 
				  && ($configuration->get_extensions_option() eq DEFAULT_NEW_VALUE)
				  && ($configuration->get_path_to_log() eq DEFAULT_NEW_VALUE)
				  && ($configuration->get_path_to_quarantine_log() eq DEFAULT_NEW_VALUE)
				  && ($configuration->get_path_to_www_database() eq DEFAULT_NEW_VALUE)
				  && ($configuration->get_quarantine_path() eq DEFAULT_NEW_VALUE)
				  && ($configuration->get_virus_detected_option() eq DEFAULT_NEW_VALUE)
				  && ($configuration->get_virus_database_path() eq DEFAULT_NEW_VALUE));
ok($condition == 1, "Configuration_SaveSettings_NewConfiguration_WasSaved");

done_testing();
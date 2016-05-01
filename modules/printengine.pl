#!/usr/bin/perl
#print engine to be called by SLAcer.js and other printer services orstandalone from command line
#Copyright 2016 Robert Koeppl, Fablab Leoben robert.koeppl@fablab-leoben.at
#http://www.fablab-leoben.at
#http://www.github.com/fablab-leoben
#released under the MIT License
#this piece of software is provided with absolutely no warranty
#use at your own risk
#configuration is stored in printengine.cfg, do not use hardcoded configuration in ths perl script, that is bad practice.
use warnings;
use strict;
use Getopt::Std;
use Getopt::Long;
use feature qw(say);
use Config::Simple;
my $cfg = new Config::Simple('printengine.cfg');
$cfg->read('printengine.cfg');
#asign config values from config file to values in script
my $log_file = $cfg->param("log_file");
my $logging_enabled=$cfg->param("logging_enabled");
my $controllerboard=$cfg->param("controllerboard");
my $steps_per_mm=$cfg->param("steps_per_mm");
my $projector_type=$cfg->param("projector_type");
my $projector_usb_device=$cfg->param("projector_usb_device");
my $endstop_Z_max=$cfg->param("endstop_Z_max");
my $endstop_Z_max_type=$cfg->param("endstop_Z_max_type");
my $endstop_Z_min=$cfg->param("endstop_Z_min");
my $endstop_Z_min_type=$cfg->param("endstop_Z_min_type");
my $wiper=$cfg->param("wiper");
my $door_contact=$cfg->param("door_contact");
my $X_pixels=$cfg->param("X_pixels");
my $Y_pixels=$cfg->param("Y_pixels");
my $Z_Autocal=$cfg->param("Z-Z_Autocal");
my $testrun_capable=$cfg->param("testrun_capable");
my $testrun_color=$cfg->param("testrun_color");
my $prodrun_color=$cfg->param("prodrun_color");
my $vat_heatable=$cfg->param("vat_heatable");
my $vat_target_temperature=$cfg->param("vat_target_temperature");
my $check_vat_presence=$cfg->param("check_vat_presence");
my $virtual_terminal=$cfg->param("virtual_terminal");
my $display_software=$cfg->param("display_software");
my $display_device=$cfg->param("display_device");
my $pin_zmin=$cfg->param("pin_zmin");
my $pin_zmax=$cfg->param("pin_zmax");
my $pin_door=$cfg->param("pin_door");
my $pin_step_Z=$cfg->param("pin_step_Z");
my $pin_enable_Z=$cfg->param("pin_enable_Z");
my $pin_direction_Z=$cfg->param("pin_direction_Z");
my $pin_trigger_pre=$cfg->param("pin_trigger_pre");
my $pin_trigger_post=$cfg->param("pin_trigger_post");
my $pin_enable_wiper=$cfg->param("pin_enable_wiper");
my $pin_dir_wiper=$cfg->param("pin_dir_wiper");
my $pin_step_wiper=$cfg->param("pin_step_wiper");
my $pin_vat_heater=$cfg->param("pin_vat_heater");
my $pin_vat_temperature=$cfg->param("pin_vat_temperature");
my $pin_vat_presence=$cfg->param("pin_vat_presence");


#activate logging to logfile
if ($logging_enabled eq "TRUE") 
{
open my $log_fh, ">", $log_file;
}

#basic sanity checks to determine whether or not the configuration is complete and makes at least some sense
if ($controllerboard eq "BBB")  #if the Board is set to be a Beagle Bone Black, we need to check if it actually is one
{
say "Beagle Bone Black selected, checking board type! - check command still missing";
}
else {
say "unknows printer type $controllerboard , please review your configuration, get in touch with developers or fork the code on Github and contribute the code to use the new printer"
;
die "unknown board in configuration!\n";
}

if ($display_software eq "fbi")  #ckeck for configured Software to send Pictures to the projector
{
open(whichfile,"which $display_software |") || die "Failed: $!\n"; #find path to the binary
while ( <whichfile> )
{
my $display_software_path=$!;
}
}
else { #if the configured Display software matches none of the supported packages, die
say "unknows display software $display_software , please review your configuration, get in touch with developers or fork the code on Github and contribute the code to use the new printer"
;
die "unknown display software in configuration!\n";
}

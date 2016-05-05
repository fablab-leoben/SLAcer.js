#!/usr/bin/perl
#print engine to be called by SLAcer.js and other printer services orstandalone from command line
#Copyright 2016 Robert Koeppl, Fablab Leoben robert.koeppl@fablab-leoben.at
#http://www.fablab-leoben.at
#http://www.github.com/fablab-leoben
#released under the MIT License
#this piece of software is provided with absolutely no warranty
#use at your own risk
#configuration is stored in printengine.cfg, do not use hardcoded configuration in ths perl script, that is bad practice.
#definition of libraries and modules to include
use warnings;
use strict;
use Getopt::Std;
use Getopt::Long;
use feature qw(say);
use Config::Simple;
use File::Which;
use Sys::Mmap;
use Graphics::Framebuffer;
use Time::HiRes;
use Sort::Key::Natural qw( natsort );
#import configuration from configuration file
our $cfg = new Config::Simple();
$cfg->read("printengine.cfg");

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
my $Z_speed=$cfg->param("Z_speed");
my $Z_max_speed=$cfg->param("Z_max_speed");
my $Z_Autocal=$cfg->param("Z_Autocal");
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
my $pin_wiper_max=$cfg->param("pin_wiper_max");
my $pin_wiper_min=$cfg->param("pin_wiper_min");
my $pin_vat_heater=$cfg->param("pin_vat_heater");
my $pin_vat_temperature=$cfg->param("pin_vat_temperature");
my $pin_vat_presence=$cfg->param("pin_vat_presence");

#asign additional variables
#
#
#
#activate logging to logfile
if ($logging_enabled eq "TRUE") 
{
unless (defined $log_file and length $log_file){
die "logging enabled but no logfile defined\n";}
open my $log_fh, ">", $log_file;
}
#basic sanity checks to determine whether or not the configuration is complete and makes at least some sense
#check if the parameters and pins needed for the features enabled are configured
unless (defined $steps_per_mm and length $steps_per_mm){
die "No steps per mm for Z Axis defined\n";}
unless (defined $controllerboard and length $controllerboard){
die "No controllerboard defined\n";}
unless (defined $projector_type and length $projector_type){
die "No projector type defined\n";}
unless (defined $display_device and length $display_device){
die "No display device defined\n";}
unless (defined $X_pixels and length $X_pixels){
die "No pixels in X direction defined\n";}
unless (defined $Y_pixels and length $Y_pixels){
die "No pixels in Y direction defined\n";}
unless (defined $Z_speed and length $Z_speed){
die "No Z speed defined\n";}
unless (defined $Z_max_speed and length $Z_max_speed){
die "No Z max speed defined\n";}
unless (defined $prodrun_color and length $prodrun_color){
die "No production run color defined\n";}
if ($check_vat_presence eq "TRUE")  
{
unless (defined $pin_vat_presence and length $pin_vat_presence )
{
die "Vat presence pin definition missing\n";}
}
if ($door_contact eq "TRUE")  
{
unless (defined $pin_door and length $pin_door )
{
die "door pin not defined\n";}
}
if ($testrun_capable eq "TRUE")  
{
unless (defined $testrun_color and length $testrun_color )
{
die "Z max endstops definition incomplete\n";}
}
if ($endstop_Z_max eq "TRUE")  
{
unless (defined $endstop_Z_max_type and length $endstop_Z_max_type and 
defined $pin_zmax and length $pin_zmax )
{
die "Z max endstops definition incomplete\n";}
}
if ($endstop_Z_min eq "TRUE")  
{
unless (defined $endstop_Z_min_type and length $endstop_Z_min_type and 
defined $pin_zmin and length $pin_zmin )
{
die "Z min endstops definition incomplete\n";}
}
if ($Z_Autocal eq "TRUE")  
{
unless ($endstop_Z_max eq "TRUE" and $endstop_Z_min eq "TRUE" and 
defined $endstop_Z_max_type and length $endstop_Z_max_type and 
defined $pin_zmax and length $pin_zmax and
defined $endstop_Z_min_type and length $endstop_Z_min_type and 
defined $pin_zmin and length $pin_zmin)
{
die "Z endstops definition incomplete for autotune of Z axis Length\n";}
}
if ($wiper eq "TRUE")  
{
unless (defined $pin_enable_wiper and length $pin_enable_wiper and 
defined $pin_step_wiper and length $pin_step_wiper and
defined $pin_dir_wiper and length $pin_dir_wiper and 
defined $pin_zmin and length $pin_zmin and
defined $pin_wiper_max and length $pin_wiper_max and
defined $pin_wiper_min and length $pin_wiper_min
)
{
die "pin definition incomplete for wiper usage\n";}
}
if ($vat_heatable eq "TRUE")  
{
unless (defined $vat_target_temperature and length $vat_target_temperature and 
defined $pin_vat_heater and length $pin_vat_heater and
defined $pin_vat_temperature and length $pin_vat_temperature)
{
die "Vat temperature or heater parameters are configured incompletely\n";}
}

if ($controllerboard eq "BBB")  #if the Board is set to be a Beagle Bone Black, we need to check if it actually is one
{
say "Beagle Bone Black selected, checking board type! - check command still missing";
unless (defined $pin_trigger_post and length $pin_trigger_post and defined $pin_trigger_pre and length $pin_trigger_pre){
die "trigger pin definition incomplete\n";}
}
else {
say "unknown controller type $controllerboard , please review your configuration, get in touch with developers or fork the code on Github and contribute the code to use the new printer"
;
die "unknown board in configuration!\n";
}
if ($projector_type eq "Lightcrafter4500")  
{
unless (defined $projector_usb_device and length $projector_usb_device){
die "No projector USB device defined\n";}
}
else {
say "unknown projector type $projector_type , please review your configuration, get in touch with developers or fork the code on Github and contribute the code to use the new printer"
;
die "unknown projector in configuration!\n";
}

if ($display_software eq "fbi")  #ckeck for configured Software to send Pictures to the projector
{
my $display_software_path= which "fbi";
unless (defined $display_software_path and length $display_software_path){
die "configured display software not found\n";}
unless (defined $display_device and length $display_device){
die "display devicde not configured\n";}
unless (defined $virtual_terminal and length $virtual_terminal){
die "virtual terminal not configured\n";}
}
elsif ($display_software eq "builtin")
{
unless (defined $display_device and length $display_device){
die "display device not configured\n";}
}

else { #if the configured Display software matches none of the supported packages, die
say "unknows display software $display_software , please review your configuration, get in touch with developers or fork the code on Github and contribute the code to use the new printer"
;
die "unknown display software in configuration!\n";
}
#read filelist from testfolder
    my $dir = '/tmp/tst';

    opendir(DIR, $dir) or die $!;

    my @pics 
        = grep { 
            m/\.png$/             # png files only
	    && -f "$dir/$_"   # and is a file
	} readdir(DIR);
    closedir(DIR);
    #sort array
    my @pics_sorted=natsort @pics;
    print @pics_sorted;
#builtin framebuffer access

 my $fb = Graphics::Framebuffer->new( FB_DEVICE=>$display_device, SPLASH=>0 );
$fb->clear_screen('OFF');
 $fb->blit_write(
 $fb->load_image(
         {   'center'     => $fb->{'CENTER_XY'},
             'file'       => "$dir/$pics_sorted[0]" # Usually needs full path
         }
     )
 ); 
$fb->clear_screen('ON');
 

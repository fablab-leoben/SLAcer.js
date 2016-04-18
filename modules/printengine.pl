#!/usr/bin/perl
#print engine to be called by SLAcer.js and other printer services orstandalone from command line
#Copyright 2016 Robert Koeppl, Fablab Leoben robert.koeppl@fablab-leoben.at
#http://www.fablab-leoben.at
#http://www.github.com/fablab-leoben
#released under the MIT License
#this piece of software is provided with absolutely no warranty
#use at your own risk
#configuration is stored in printengine.cfg, do not use hardcoded configuration in ths per script, that is bad practice.
use warning;
use strict;
use Getopt::Std;
use Getopt::Long;
use feature qw(say);

#include configuration and settings from printengine.cfg
use printengine.cfg
#checked for used controller board type according to configuration.
#activate logging to logfile
if $logging_enabled eq "TRUE" then
{
open my $log_fh, ">", $log_file;
}

if $controllerboard eq "BBB" then 
{

}
else {
say "unknows printer type $controllerboard , please review your configuration, get in touch with developers or fork the code on Github and contribute the code to use the new printer"
;
die "unknown board in configuration!\n";
}
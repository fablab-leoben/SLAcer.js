#!/usr/bin/perl
use Device::SerialPort;
use Time::HiRes qw/sleep/;
use Slurp;
 
#Slup each file into a command list
my @command_list;
for my $file ( @ARGV ){
    push @command_list, split('\n',slurp $file);
}
 
#If your board autoresets when talked to ( like a Sanguino ), you can uncomment the line bellow to get the machine to home position before sending the actual gcode
#send_commands('G21','G91','G1 X-150 Y-150','G1 X-150 Y-150','G1 X-150 Y-150','G1 X-150 Y-150');
 
send_commands(@command_list);
 
sub send_commands{
    my @command_list = @_;
 
    #Open port
    my $port = Device::SerialPort->new("/dev/ttyACM0");
 
    # 19200, 81N on the USB ftdi driver
    $port->baudrate(115200);
    $port->databits(8);
    $port->parity("none");
    $port->stopbits(1);
 
    while (1) {
        # Poll to see if any data is coming in
        if ( my $char = $port->lookfor() ) {
            $char =~ s/\r//;
            print "$char\n";
            if( $char =~ m/^(ok|start)$/){
                #Send next command
                my $next_command = shift @command_list;
                print "$next_command\n";
                $port->write("$next_command\n");
            }else{
                print "unknown: $char\n";
            }
        }
        sleep 0.01;
        unless(@command_list){last; }
    }
}


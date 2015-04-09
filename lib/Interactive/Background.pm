package Interactive::Background;

use warnings;
use strict;

use Exporter qw/import/;

our @EXPORT = qw/stop/;


sub stop (;$)
{
   if ($_[0]) {
      my $newline = 0;
      $newline = 1
         if $_[0] =~ /\n\z/;

      my $msg = "Stopping for $_[0]";
      unless ($newline) {
         $msg .= " at " . join(":", (caller)[1,2]) . "\n"
      }
      print $msg
   } else {
      print "Stopped at " . join(":", (caller)[1,2]) . "\n"
   }
   kill 'STOP', $$
}


1;

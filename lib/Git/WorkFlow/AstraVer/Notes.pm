package Git::WorkFlow::AstraVer::Notes;

use warnings;
use strict;

use Carp;

sub _validate_ok
{
   $_[0] =~ m/\A\s*+((?<label>[a-fA-F0-9]{7,40}|code_change|partial|not_proven)\s*;\s*)*(?&label);?\s*\Z/
}

sub _summarize_tags
{
   my %plus = map {$_ => undef} @{$_->[0]};
   my @plus;
   my @minus;

   foreach(@{$_->[1]}) {
      if (exists $plus{$_}) {
         delete $plus{$_}
      } else {
         push @minus, $_
      }
   }

   @plus = keys %plus;

   [[@plus], [@minus]]
}

sub _parse_tags
{
   my $s = $_[0];
   $s = s/\s++//g; 

   my @plus;
   my @minus;

   foreach(split /;/, $s) {
      next
         if $_ =~ m/^[a-fA-F0-9]{7,40}$/;
      if ($_ =~ s/\A-//) {
         push @minus, $_
      } else {
         push @plus, $_
      }
   }

   [[@plus], [@minus]]
}

sub new
{
   my ($self, $git) = @_;

   my %notes;
   foreach ($git->run('notes')) {
      my @tmp = split ' ';
      $notes{$tmp[1]}{obj} = $tmp[0]
   }
   foreach (keys %notes) {
      $notes{$_}{content} = $r->run('cat-file' => '-p' => $notes{$_}{obj});
      croak "Improper format of notes." 
         unless _validate_ok $notes{$_}{content};
   }
   foreach (keys %notes) {
      if ($notes{$_}{content} =~ m/[a-fA-F0-9]{7,40}/p) {
         $notes{$_}{attach} = ${^MATCH}
      }
   }

   bless \%notes, __PACKAGE__
}

sub refs
{
   keys $_[0]
}

1;

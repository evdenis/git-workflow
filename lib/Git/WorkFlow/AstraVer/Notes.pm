package Git::WorkFlow::AstraVer::Notes;

use warnings;
use strict;

use Carp;
use Git::Repository::Command;

sub _note_content
{
   $_[0]->run('cat-file' => '-p' => $_[1])
}

sub _validate
{
   my $ok = 1;
   my $note = $_[1];

   $note =~ s/\s++//g;

   foreach my $t (split /;/, $note) {
      if ($t =~ m/\A[a-fA-F0-9]{7,40}\z/) {
         my $c = Git::Repository::Command->new($_[0], 'rev-parse' => '--quiet' => '--verify' => $t, {fatal => [-128, -129]});
         $c->final_output();

         if ($c->exit()) {
            print "$t FAIL!\n";
            $ok = 0;
            last
         }

         next
      }

      if (index($t, '-') == 0) {
         $t = substr $t, 1
      }

      unless ($t eq 'code_change' || $t eq 'partial' || $t eq 'not_proven' || $t eq 'moved_to_devel' || $t eq 'moved_to_spec') {
         $ok = 0;
         last
      }
   }

   $ok
}

sub __summarize_tags
{
   my %plus = map {$_ => undef} @{$_[0]->[0]};
   my @plus;
   my @minus;

   foreach(@{$_[0]->[1]}) {
      if (exists $plus{$_}) {
         delete $plus{$_}
      } else {
         push @minus, $_
      }
   }

   @plus = keys %plus;
   my %hash;
   @minus = grep {!$hash{$_}++} @minus; #uniq minus

   [[@plus], [@minus]]
}

sub _summarize_tags
{
   my ($v1, $v2) = @_;
   my @plus  = @{ $v1->[0] };
   my @minus = @{ $v1->[1] };

   push @plus, @{ $v2->[0] };
   push @minus, @{ $v2->[1] };

   __summarize_tags [\@plus, \@minus]
}

sub summarize_tags
{
   my ($self, $ref1, $ref2) = @_;

   croak "Wrong refs"
      unless exists $self->{$ref1} && exists $self->{$ref2};
   croak "Refs are identical"
      if $ref1 eq $ref2;

   $self->{$ref1}{tags} =
      _summarize_tags $self->{$ref1}{tags}, $self->{$ref2}{tags};
}

sub _tags_to_string
{
   join('; ', @{$_[0]->[0]}, @{$_[0]->[1]})
}

sub _parse_tags
{
   my $s = $_[0];
   $s =~ s/\s++//g;

   my @plus;
   my @minus;

   foreach(split /;/, $s) {
      next
         if $_ =~ m/\A[a-fA-F0-9]{7,40}\z/;
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
      $notes{$_}{content} = $git->run('cat-file' => '-p' => $notes{$_}{obj});
      croak "Improper format of notes." 
         unless _validate $git, $notes{$_}{content};
   }
   foreach (keys %notes) {
      if ($notes{$_}{content} =~ m/[a-fA-F0-9]{7,40}/p) {
         $notes{$_}{attach} = $git->run('rev-parse' => '--verify' => '--quiet' => ${^MATCH})
      }
      $notes{$_}{tags} = _parse_tags $notes{$_}{content};
   }

=branch
   foreach (keys %notes) {
      my $lbranch = ($r->run('branch' => '--contains' => $_) =~ s/\A\*?\h++//r);
      my $rbranch;

      $rbranch = ($r->run('branch' => '-r' => '--contains' => $_) =~ s/\A\h++//r)
         unless $lbranch;

      $notes{$_}{branch} = $lbranch || $rbranch;
   }
=cut

   bless \%notes, __PACKAGE__
}

sub iterator
{
   my @keys = keys %{$_[0]};
   return sub {
      return shift @keys
   };
}

sub delete
{
   delete $_[0]->{$_[1]}
}

sub exists
{
   exists $_[0]->{$_[1]}
}

sub get
{
   $_[0]->{$_[1]}
}

sub empty
{
   %{$_[0]} ? 0 : 1
}

1;

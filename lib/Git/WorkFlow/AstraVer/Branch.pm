package Git::WorkFlow::AstraVer::Branch;

use warnings;
use strict;

use Exporter qw/import/;
use Carp;

our @EXPORT = qw/list_branches_sorted/;
our @EXPORT_OK = qw/list_branches list_branches_sorted parse_branch_version parse_branches_versions version_sort check_branch_empty branch_contains/;

sub parse_branch_version
{
   croak "Invalid argument: (null)."
      unless $_[0];

   my $dash = index($_[0], '-');
   croak "Invalid argument: dash between number and name required."
      if $dash == -1;

   my $version = substr($_[0], $dash + 1);
   my $point = index($version, '.');
   croak "Invalid argument: point between major and minor version required."
      if $point == -1;

   my $major   = substr($version, 0, $point);
   my $minor   = substr($version, $point + 1);
   $major = 0 unless $major;
   $minor = 0 unless $minor;

   [$major, $minor]
}

sub parse_branches_versions
{
   map { parse_branch_version $_ } @_
}

sub version_sort
{
   my @v = parse_branches_versions($a, $b);

   $v[0][0] <=> $v[1][0]
             ||
   $v[0][1] <=> $v[1][1]
}

my $branch_re = qr/^\*?\h++|\h++$/;

sub list_branches
{
   my ($repo, $match) = @_;

   map {s/$branch_re//rg}
      $repo->run('branch' => '--list' => $match)
}

sub list_branches_sorted
{
   sort version_sort list_branches(@_)
}

sub check_branch_empty
{
   my ($r, $parent, $branch) = @_;

   my $sha = $r->run('merge-base' => '--fork-point' => $parent => $branch);
   if ($sha) {
      my @commits = $r->run('rev-list' => "$sha..$branch");
      return @commits ? 0 : 1;
   } else {
      croak "$branch is not a fork of $parent"
   }
}

sub branch_contains
{
   map {s/$branch_re//rg}
      $_[0]->run(branch => '--contains' => $_[1])
}


1;

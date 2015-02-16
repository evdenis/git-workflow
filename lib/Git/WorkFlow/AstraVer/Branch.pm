package Git::WorkFlow::AstraVer::Branch;

use warnings;
use strict;

use Exporter qw/import/;

our @EXPORT = qw/list_branches_sorted/;
our @EXPORT_OK = qw/list_branches list_branches_sorted parse_branch_version parse_branches_versions version_sort/;

sub parse_branch_version
{
   my $version = substr($_[0], index($_[0], '-') + 1);
   my $point = index($version, '.');
   if ($point == -1) {
      return [0, 0]
   }
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

sub list_branches
{
   my ($repo, $match) = @_;
   
   map {s/^\*?\h++|\h++$//rg}
      $repo->run('branch' => '--list' => $match)
}

sub list_branches_sorted
{
   sort version_sort list_branches(@_)
}


1;

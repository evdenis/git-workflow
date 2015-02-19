package Git::WorkFlow::AstraVer::Repo;

use warnings;
use strict;

use Exporter qw/import/;

use Git::Repository::Command;

our @EXPORT_OK = qw/check_changes_exist/;


sub check_changes_exist
{
   $_[0]->run(qw/update-index -q --refresh/);

   my $cmd = Git::Repository::Command->new( $_[0], qw/diff-index --quiet HEAD --/);
   $cmd->close();

   $cmd->exit();
}

1;

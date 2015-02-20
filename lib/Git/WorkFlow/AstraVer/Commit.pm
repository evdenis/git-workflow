package Git::WorkFlow::AstraVer::Commit;

use warnings;
use strict;

use Exporter qw/import/;

our @EXPORT_OK = qw/commit_info/;

sub commit_info
{
   $_[0]->run('log' => '-n1' => '--oneline' => $_[1])
}

1;

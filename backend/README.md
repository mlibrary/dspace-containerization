```
Will need these Env variable:

/deepblue/bin/stats/find_crawlers

my $gDbDevName     = $ENV{'DB_NAME'};
my $gDbUser     = $ENV{'DB_USER'};
my $gDbPassword     = $ENV{'DB_PASSWORD'};

my $dbhP = DBI->connect("dbi:Pg:dbname=$gDbName", "$gDbUser", "$gDbPassword");

======
These are the perl libraries they use:

use Encode;
use utf8;
use DBI;
use File::Path;
use Getopt::Std;
use Error qw(:try);
use LWP::Simple;
use LWP::UserAgent;

==========
Also Needs:
nslookup
my $command = "/usr/bin/nslookup -timeout=5  $ip";

And Need:
vi
xemacs

======
There are also some directories that need to change.

in prep-logs =>

my $gLogDir = qq{/l1/dspace/repository/prod/log/};
my $gScriptDir = qq{/deepblue/bin/stats};

in remove_ips ==>

my $gTempLogFile = qq{/l1/dspace/repository/prod/log/temp_log_file};
```

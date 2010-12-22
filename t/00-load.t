#!perl -T

use Test::More tests => 3;

BEGIN {
    use_ok( 'AI::GA::Base' ) || print "Bail out!
";
    use_ok( 'AI::GA::Genome::Base' ) || print "Bail out!
";
    use_ok( 'AI::GA::Genome::Sample' ) || print "Bail out!
";
}

diag( "Testing AI::GA::Base $AI::GA::Base::VERSION, Perl $], $^X" );

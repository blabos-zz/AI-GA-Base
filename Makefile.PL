use inc::Module::Install;

name     'AI-GA-Base';
all_from 'lib/AI/GA/Base.pm';
author   q{Blabos de Blebe <blabos@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;


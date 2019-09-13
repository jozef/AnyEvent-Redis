use strict;
use Test::More;
use t::Redis;

test_redis {
    my $r = shift;

    ok($r->set('key' => 'value0')->recv, 'set key in db index 0');
    is($r->get('key')->recv, 'value0', 'key stored in db index 0');

    my $r1 = AnyEvent::Redis->new(
        host    => $r->{host},
        port    => $r->{port},
        dbindex => 1
    );
    is($r1->get('key')->recv, undef, 'key not present in db index 1');
    ok($r1->set('key' => 'value1')->recv, 'set key in db index 1');
    $r1->cleanup();
    is($r1->get('key')->recv, 'value1', 'still present in db index 1 after reconnect');

    ok($r1->select(0)->recv, 'switch to index 0 on initial index 1 connection');
    is($r1->get('key')->recv, 'value0', 'verify key stored in db index 0');
    $r1->cleanup();
    is($r1->get('key')->recv, 'value0', 'verify key stored in db index 0 again after reconnect');

};

done_testing;

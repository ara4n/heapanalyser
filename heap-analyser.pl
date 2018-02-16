#!/usr/bin/perl

use strict;
use warnings;

my @node_types = ("hidden","array","string","object","code","closure","regexp","number","native","synthetic","concatenated_string","sliced_string");

# "type","name","id","self_size","edge_count","trace_node_id"

# "nodes":[9,1,1,0,5,0
# ,9,2,3,0,17,0
# ,9,3,5,0,2452,0

my @edge_types = ("context","element","property","internal","hidden","shortcut","weak");

# "type","name_or_index","to_node"

# "edges":[1,1,6
# ,5,4021,9546

# "strings":["<dummy>",
# "",

my $state = 0;

my $size = {};
my $count = {};
my $names = {};
my $strings = [];
my $total_size = 0;

while(<>) {
    if (/^"nodes":\[/) {
        $state = 1;
        s/^"nodes":\[//;
    }
    if (/^\],/) {
        $state = 0;
    }

    if (/^"strings":\[/) {
        $state = 3;
        s/^"strings":\[//;
    }

    if ($state == 1) {
        s/^,//;
        my @fields = split(/,/);
        
        $count->{$fields[0]}++;
        $size->{$fields[0]} += $fields[3];
        $total_size += $fields[3];

        $names->{$fields[0]}->{$fields[1]}->{count}++;
        $names->{$fields[0]}->{$fields[1]}->{size} += $fields[3];
    }
    elsif ($state == 3) {
        if (/^"(.*)"(,|\]})$/) {
            push @$strings, $1;
        }
        else {
            warn "couldn't parse $_";
        }
    }
}

print "type\tcount\ttotal_size\tname\n";
print "----\t-----\t----------\t----\n";
foreach my $type (sort {$names->{$b} <=> $names->{$a}} keys %$names) {
    foreach my $name (sort {$names->{$type}->{$b}->{count} <=> $names->{$type}->{$a}->{count}} keys %{$names->{$type}}) {
        print($node_types[$type]."\t".
              $names->{$type}->{$name}->{count}."\t".
              $names->{$type}->{$name}->{size}."\t".
              substr($strings->[$name], 0, 64)."\n");
    }
}

# foreach (sort {$size->{$b} <=> $size->{$a}} keys %$size) {
#     print($_."\t".$node_types[$_]."\t".$size->{$_}."\t".$count->{$_}."\n");
# }
# print "total_size: $total_size\n";
#!/usr/bin/perl -w
use strict;

my %seen;
my $count = 0;

open FILE, "<Myc_16.ranked.taxonomy" or die "Cannot open ranked taxonomy: $!\n";
<FILE>;
while (<FILE>){
	chomp $_;
	my @vals = split(/\t/, $_);
	next if (defined $seen{$vals[0]});
	if ($vals[4] eq 9606){
		$count++;
		$seen{$vals[0]} = 1;
	}
}
close FILE;

print "Myc_16 BLAST human content = $count\n";


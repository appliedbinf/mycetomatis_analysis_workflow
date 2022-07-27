#!/usr/bin/perl -w
use strict;


open FILE, "<Myc_16.unfiltered.krona.tsv" or die "Cannot open unfiltered Myc_16: $!\n";
my $unfiltTotal = 0;
while (<FILE>){
	chomp $_;
	next if ($_ =~ m/Madurella mycetomatis$/);
	my ($count, @vars) = split(/\t/, $_);
	$unfiltTotal += $count;
}
close FILE;


open FILE, "<Myc_16.filtered.krona.tsv" or die "Cannot open filtered Myc_16: $!\n";
my $filtTotal = 0;
while (<FILE>){
	chomp $_;
	next if ($_ =~ m/Madurella mycetomatis$/);
	my ($count, @vars) = split(/\t/, $_);
	$filtTotal += $count;
}
close FILE;

print "Myc_16 unfiltered other organisms = $unfiltTotal\n";
print "Myc_16 filtered other organisms = $filtTotal\n";


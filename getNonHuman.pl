#!/usr/bin/perl -w
#
# Author: Emily Norris, Lavanya Rishishwar
# Creation Date  : Jan 5, 2020
# Modified/Updated for Myc_16 runs	:	April 25, 2020
#
#############################################################
use strict;
use Getopt::Long;

#############################################################
my $usage = "Retrieve Non-human reads based on kraken output.\nUsage instructions:\n$0 -in <input kraken output file name> [-out <output FASTQ files. Default:nonHum-[inputFileName]>] [-help <FLAG. Prints the help>]\n";

my $in  = ""; # Input file name
my $out = ""; # Output File
my $help = 0; # Print help

# Get the arguments
my $args  = GetOptions ("in=s"    	=> \$in,
						"help"		=> \$help,
                        "out=s"     => \$out);

#############################################################

if($help > 0){
	print STDERR $usage;
	exit 0;
}

die "Please specify input file name!\n$usage\n" if ($in eq "");
die "Input file doesn't exist!\n$usage\n" if (! -e $in);

$out = $in;
$out =~ s/.output.gz//;
my $r1 = "../rawReads/".$out.".R1.fastq.gz";
my $r2 = "../rawReads/".$out.".R2.fastq.gz";
$out = "nonHum-$out";

#############################################################

my %reads;

open FILE, "gunzip -c $in |" or die "ERROR: Cannot read input file $in: $!\n";
while (<FILE>){
	chomp $_;
	my @line = split(/\t/,$_);
	if ($line[2] !~ /Homo sapiens.*/){
		$reads{$line[1]} = 1;
	}
}
close FILE;

open R1IN, "gunzip -c $r1 |" or die "ERROR: Cannot read input file $r1: $!\n";
open R1OUT, ">$out.R1.fa" or die "ERROR: Cannot create output file $out.R1.fa: $!\n";
while(<R1IN>){
	chomp $_;
	my($part1, $part2) = split(/\s+/,$_);
	$part1 =~ s/@//;
	$part2 =~ s/:.*//;
	my $seq = <R1IN>;
	print R1OUT ">$part1-$part2\n$seq" if (exists $reads{$part1});
	<R1IN>;
	<R1IN>;
}
close R1OUT;
close R1IN;

open R2IN, "gunzip -c $r2 |" or die "ERROR: Cannot read input file $r2: $!\n";
open R2OUT, ">$out.R2.fa" or die "ERROR: Cannot create output file $out.R2.fa: $!\n";
while(<R2IN>){
	chomp $_;
	my($part1, $part2) = split(/\s+/,$_);
	$part1 =~ s/@//;
	$part2 =~ s/:.*//;
	my $seq = <R2IN>;
	print R2OUT ">$part1-$part2\n$seq" if (exists $reads{$part1});
	<R2IN>;
	<R2IN>;
}
close R2OUT;
close R2IN;

#!/usr/bin/perl -w
use strict;


my @isolates;
my %info;


while (<DATA>){
	chomp $_;
	push (@isolates, $_);
}

foreach my $isolate (@isolates){

	my $last = "";
	my $mycetomatis = 0;
	my $other = 0;
	my $unclassified = 0;
	my $totalReads = 0;
	
	my %myc;


	open FILE, "<$isolate.fungaldb.blastOut" or die "Cannot open $isolate.fungaldb.blastOut: $!\n";
	
	print STDERR "Working on $isolate... ";

	while (<FILE>){
		
		chomp $_;
		
		my ($query, $subject, undef, undef, undef, $pident, $qcovs, undef) = split(/\t/,$_);		
		
		if ($query eq $last){
			next;
		}
		else {
			$totalReads++;
			
			# Check if match meets minimum confidence (percent identity >= 75% and query coverage >= 75%)
			if ($pident < 75 || $qcovs < 75){
				$unclassified++;
			}
			
			# Check if scientific name is M mycetomatis
			elsif ($subject =~ m/(^GAD)||(^WOG)||(^LCT)|(^Madurella_mycetomatis)/){
				$mycetomatis++;
				$myc{$query} = 1;
			}
								
			# Otherwise, mark as other
			else {
				$other++;
			}
			
		}
		
		
		
		$last = $query;
	}

	close FILE;
	
	$info{$isolate} = "$totalReads\t$mycetomatis\t$other\t$unclassified";
	
	print STDERR "done\n";
	
	my $readsInFiltered = 0;
	
	open READS, "<$isolate-filter.fa" or die "Cannot open $isolate FASTA file: $!\n";
	open UNC, ">$isolate-notMycetomatis.fa" or die "Cannot open $isolate-notMycetomatis.fa: $!\n";
	while(<READS>){
		chomp $_;
		if ($_ =~ m/^>/){
			$readsInFiltered++;
			chomp $_;
			$_ =~ s/>//;
			if (exists $myc{$_}){
				next;
			}
			else{
				my $seq = <READS>;
				print UNC ">".$_."\n".$seq;
			}
		}
	}
	close READS;
	close UNC;
	
	$info{$isolate} = "$totalReads\t$mycetomatis\t$other\t$unclassified\t$readsInFiltered";
	
}



print STDERR "Writing results to file... ";

open OUT, ">allIsolates.fungaldb.formatted" or die "Cannot open allIsolates.fungaldb.formatted: $!\n";

print OUT "Isolate\tTotal reads with BLAST hits\tM. mycetomatis reads\tOther organism reads\tUnclassified reads\tTotal reads in filter.fa\n";

foreach my $isolate (@isolates){
	print OUT $isolate."\t".$info{$isolate}."\n";
}

close OUT;

print STDERR "done\n";


__DATA__
Myc_16

#!/usr/bin/perl -w
use strict;


print STDERR "Calculating unique taxids\n";

my @taxidsToLook = `cat *.taxid | cut -f5 | uniq | sort | uniq`;
my %taxids;
my %map;

my $speciesCutoff = 95;
my $genusCutoff   = 90;
my $familyCutoff  = 85;
my $orderCutoff   = 75;


foreach my $taxid (@taxidsToLook){
	next if($taxid =~ m/Taxid/ || $taxid =~ m/\./);
	
	chomp $taxid;
	$taxids{$taxid} = 1;
}


## Taxid\t|\tScientific name\t|\tSpecies (may be blank)\t|\tGenus\t|\tFamily\t|\tOrder\t|\tClass\t|\tPhylum\t|\tKingdom\t|\tSuperkingdom\t|\n
print STDERR "Retrieving taxid to taxonomy mapping\n";

open TAXONOMY, "</storage/home/hhive1/enorris6/scratch/mdb/blast/analysis2/taxdump/rankedlineage.dmp" or die "Cannot open rankedlineage.dmp: $!\n";
while (<TAXONOMY>){
	chomp $_;
	$_ .= "\t";
	
	my ($taxid, $name, $species, @taxonomy) = split(/\t\|\t/, $_, -1);
	

	if(defined $taxids{$taxid}){
	
		# if ($species ne ""){
			# print STDERR "Species not blank for taxid $taxid\n";
			# exit;
		# }
		
		pop(@taxonomy);
		
		$map{$taxid}{"Full"} = join(";", reverse(@taxonomy), $name);
		$map{$taxid}{"Superkingdom"} = pop(@taxonomy);
		$map{$taxid}{"Kingdom"} = pop(@taxonomy);
		$map{$taxid}{"Phylum"} = pop(@taxonomy);
		$map{$taxid}{"Class"} = pop(@taxonomy);
		$map{$taxid}{"Order"} = pop(@taxonomy);
		$map{$taxid}{"Family"} = pop(@taxonomy);
		$map{$taxid}{"Genus"} = pop(@taxonomy);
		$map{$taxid}{"Species"} = $name;
		
		delete $taxids{$taxid};
	}
	
	last if (scalar keys %taxids == 0);
}
close TAXONOMY;


my @isolates;

while (<DATA>){
	chomp $_;
	push(@isolates, $_);
}

my $filteredFiles = "";
my $unfilteredFiles = "";

foreach my $isolate (@isolates){
	print STDERR "Getting taxonomy for $isolate\n";
	
	open TAXIDS, "<$isolate.taxid" or die "Cannot open $isolate taxids: $!\n";
	open OUT, ">$isolate.ranked.taxonomy" or die "Cannot open $isolate.ranked.taxonomy:$!\n";
	
	my $header = <TAXIDS>;
	chomp $header;
	print OUT $header."\tTaxonomy\n";
	
	my %aggregate;
	my %aggregate_unfilt;
	
	while (<TAXIDS>){
		chomp $_;
		my (@pieces) = split(/\t/,$_);
		
		if (defined $map{$pieces[4]}{"Full"}){
			my $taxid = $pieces[4];
			my $filtered_linage = ".";
			my $original_lineage = $map{$pieces[4]}{"Full"};
			
			if ($pieces[2] >= $speciesCutoff and $pieces[3] >= $speciesCutoff){
				$filtered_linage = $original_lineage;
			} elsif ($pieces[2] >= $genusCutoff and $pieces[3] >= $genusCutoff){
				$filtered_linage = join(";", $map{$taxid}{"Superkingdom"}, $map{$taxid}{"Kingdom"}, $map{$taxid}{"Phylum"}, $map{$taxid}{"Class"}, $map{$taxid}{"Order"}, $map{$taxid}{"Family"}, $map{$taxid}{"Genus"});
			} elsif ($pieces[2] >= $familyCutoff and $pieces[3] >= $familyCutoff){
				$filtered_linage = join(";", $map{$taxid}{"Superkingdom"}, $map{$taxid}{"Kingdom"}, $map{$taxid}{"Phylum"}, $map{$taxid}{"Class"}, $map{$taxid}{"Order"}, $map{$taxid}{"Family"});
			} elsif ($pieces[2] >= $orderCutoff and $pieces[3] >= $orderCutoff){
				$filtered_linage = join(";", $map{$taxid}{"Superkingdom"}, $map{$taxid}{"Kingdom"}, $map{$taxid}{"Phylum"}, $map{$taxid}{"Class"}, $map{$taxid}{"Order"});
			} else {
				$original_lineage = $filtered_linage;
			}
			
			print OUT join("\t", @pieces, $original_lineage, $filtered_linage)."\n";
			
			if($original_lineage eq "."){
				$aggregate{"Unclassified"}++;
				$aggregate_unfilt{"Unclassified"}++;
			} else {
				$aggregate{$filtered_linage}++;
				$aggregate_unfilt{$original_lineage}++;
			}
		}
		else {
			print OUT join("\t", @pieces, ".")."\n";
		}
		
	}	
	
	close TAXIDS;
	close OUT;
	
	
	open KRONA, ">$isolate.filtered.krona.tsv" or die "Cannot open $isolate.filtered.krona.tsv:$!\n";
	foreach my $key (keys %aggregate){
	next if($key eq "." || $key eq "Unclassified" || $key =~ m/Primates/);
		my $lineage = $key;
		$lineage =~ s/;/\t/g;
		$lineage =~ s/\t\t+/\t/g;
		$lineage =~ s/\t$//g;
		print KRONA $aggregate{$key}."\t".$lineage."\n";
	}
	close KRONA;
	
	open KRONA, ">$isolate.unfiltered.krona.tsv" or die "Cannot open $isolate.unfiltered.krona.tsv:$!\n";
	foreach my $key (keys %aggregate_unfilt){
	next if($key eq "." || $key eq "Unclassified" || $key =~ m/Primates/);
		my $lineage = $key;
		$lineage =~ s/;/\t/g;
		$lineage =~ s/\t\t+/\t/g;
		$lineage =~ s/\t$//g;
		print KRONA $aggregate_unfilt{$key}."\t".$lineage."\n";
	}
	close KRONA;
	
	print STDERR "Executing krona text import\n";
	`ktImportText -o filtered.$isolate.krona.html $isolate.filtered.krona.tsv`;
	`ktImportText -o unfiltered.$isolate.krona.html $isolate.unfiltered.krona.tsv`;
	
	$filteredFiles .= "rankedTaxonomy/$isolate.filtered.krona.tsv,$isolate-filtered ";
	$unfilteredFiles .= "rankedTaxonomy/$isolate.unfiltered.krona.tsv,$isolate-unfiltered ";
}

#`ktImportText -o rankedTaxonomy/filtered.krona.html $filteredFiles`;
#`ktImportText -o rankedTaxonomy/unfiltered.krona.html $unfilteredFiles`;


__DATA__
Myc_16
#!/usr/bin/perl 
# #####################################################################
# Convert LEO.org output
# V2.0 - 200606102036 - Imdat Solak
# V3.0 - 200612261748 - Imdat Solak - Added Turkish Support
# Copyright (c) 2006 Imdat Solak - All Rights Reserved.
# #####################################################################
$language = $ARGV[0];
$infile = $ARGV[1];
$outfile = $ARGV[2];
if (`/usr/bin/file $infile` =~ /gzip/) {
	system("/usr/bin/gzcat $infile > " . $infile . ".in");
	open (INFILE, $infile . ".in");
} else {
	open (INFILE, $infile);
}

if ($language eq "tr") {
	&ConvertMyDictionary();
} else {
	&ConvertLEO();
}
close (INFILE);
chmod(0666, $infile);
chmod(0666, $infile . ".in");
chmod(0666, $outfile);

# SUBROUTINES

sub ConvertMyDictionary
{
	my $found = 0;
	my $exit = 0;
	my $linecount = 0;
	my $inrow;
	my $aline;
	my $resultline;
	my $content;
	my $turkish = 0;
	my $german = 0;
	my $germanfirst = 0;

	open (OUTFILE, ">$outfile");
	while (($exit == 0) && ($inrow = <INFILE>)) {
		chomp($inrow);
		if ($inrow =~ /Direkte Treffer/i) {
			if ($found == 0) {
				$found = 1;
			} else {
				$found = 0;
				$exit = 1;
			}
		} elsif ($exit == 0 && $found == 1) {
			my $left = "";
			my $right = "";
			my $entryfound = 0;
			my $localread = $inrow;
			do {
				chomp($localread);
				if ($localread =~ /Deutsch/i) {
					if ($turkish == 0) {
						$germanfirst = 1;
						$german = 1;
					}
				} elsif ($localread =~ /kisch/i) {
					if ($german == 0) {
						$germanfirst = 0;
						$turkish = 1;
					}
				}
				$localread =~ s/\r//g;
				if ($localread =~ /class=\"result\"/i) {
					$localread =~ s/<[^>]*>//g;
					$localread =~ s/\t//g;
					$localread =~ s/^[ \t]*//g;
					if ($left eq "") {
						$left = $localread;
					} else {
						$right = $localread;
						$entryfound = 1;
					}
				} elsif ($localread =~ /<tr>/i) {
					$left = "";
					$right = "";
					$entryfound = 0;
				}
			} while (($entryfound == 0) && ($localread = <INFILE>));
			if ($entryfound == 1) {
				if ($germanfirst == 1) {
					print OUTFILE $right . "\t" . $left . "\n";
				} else {
					print OUTFILE $left . "\t" . $right . "\n";
				}
			} else {
				$exit = 1;
			}
		}
	}
	close (OUTFILE);
}

sub ConvertLEO
{
	my $found = 0;
	my $linecount = 0;
	my $inrow;
	my $aline;
	my $resultline;
	my $content;
	my $left = "";
	my $right = "";
	my $lang = "";
	my $entry;

	open (OUTFILE, ">$outfile");
	while ($line = <INFILE>) {
		chomp($line);
		# $line =~ s/<\/entry/\r<\/entry/g;
		$line =~ s/<td data-dz-attr=\"relink\"/\r<td data-dz-attr=\"relink\"/g;
		@lines = split("\r", $line);
		foreach $aline (@lines) {
			$aline =~ s/<\/table.*//g;
			if ($aline =~ /<td data-dz-attr=\"relink\" lang=/i) {
				$entry = $aline;
				$entry =~ s/<[^>]*>//g;
				$lang = $aline;
				$lang =~ s/.*lang=\"(..)\".*/\1/g;
				if ($lang eq "de") {
					$right = $entry;
				} else {
					$left = $entry;
				}
				if ($left ne "" && $right ne "") {
					$left =~ s/AE/ (AE)/g;
					$left =~ s/BE/ (BE)/g;
					$left =~ s/\&.160;/ /g;
					$right =~ s/\&.160;/ /g;
					$left =~ s/[Pp]l\./(pl.)/g;
					$right =~ s/[Pp]l\./(pl.)/g;
					print OUTFILE $left . "\t" . $right . "\n";
					$left = "";
					$right = "";
					$linecount++;
				}
			}
		}
	}
	close (OUTFILE);
}

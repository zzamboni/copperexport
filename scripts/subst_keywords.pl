#!/usr/bin/perl

use POSIX qw(strftime);

$IN=$ARGV[0];
$OUT=$ARGV[1];

open F, "<Info.plist"
	or die "Error opening Info.plist: $!\n";
while (defined($line=<F>)) {
  $line =~ /<key>(.+)<\/key>/ && do {
    $k=$1;
    $_=<F>;
    /<string>(.+)<\/string>/ && do { $keywords{$k}=$1 };
  }
}
close F;
$keywords{'date'}=strftime('%D', localtime());
$keywords{'version'}=$keywords{'CFBundleVersion'};

if ($IN) {
    open IN, "<$IN" or die "Error opening '$IN': $!\n";
}
else {
    *IN=\*STDIN;
}
if ($OUT) {
    open OUT, ">$OUT" or die "Error opening '$OUT': $!\n";
}
else {
    *OUT=\*STDOUT;
}

while (defined($line=<IN>)) {
  foreach $k (keys %keywords) {
    $line=~s/\[\[$k\]\]/$keywords{$k}/g;
  }
  print OUT $line;
}
close IN;
close OUT;

#!/usr/bin/perl -w

$count = 8000;
#$count = 4000;
#$count = 2000;
#$count = 1000;
#$count = 500;
$min_images_per_directory = 5;
$max_images_per_directory = -1;
#$min_images_per_directory = 0;
#$max_images_per_directory = 20;

$count = $ARGV[0] if scalar @ARGV == 1;

use List::Util 'shuffle';

@gals = split(/[\r\n]+/, `find . -type d -follow`);
@gals = shuffle(@gals);
$lst = "";
$setlst = "";
foreach $g (@gals) {
	next if -e "$g/BLOCKED";	# Skip blocked galleries

    if (not opendir(D, $g)) {
        print STDERR "Can't open $g for reading: $!\n";
        next;
    }
    @thisf = grep { /^.*\.jpg$/i && -f "$g/$_" } readdir(D);
    sort @thisf;
    closedir D;

    s/^/$g\// for @thisf;
    s/ /\\ /g for @thisf;
#    foreach $f (@thisf) { print "$f\n"; }
	next if scalar @thisf < $min_images_per_directory;
	next if (scalar @thisf > $max_images_per_directory && $max_images_per_directory > 0);

    print "$g\n";
    open(O, "| xargs eog");
#    open(O, "| xargs gqview");
    print O join("\n", @thisf);
    close O;

#    print `ps ax | grep eog | grep xargs | wc -l`;
    while (`ps ax | grep eog | grep xargs | wc -l` > 1) {
#        print `ps ax | grep eog | grep xargs | wc -l`;
        sleep 1;
    }

	$lst = $lst . join("\n", @thisf) . "\n";
    $setlst = $setlst . $g . "\n";

	@allf = split(/\S+/, $lst);
	last if scalar @allf > $count;
}

#open(O, "| xargs xv");
#open(O, "| xargs kview");

#open(O, "| xargs gqview");
#print O $lst;
#print $setlst;
#close O;

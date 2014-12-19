#!/usr/bin/perl -w
# Spencer Clegg
# Matt Huff
# spencermclegg@gmail.com
# ocarinahuff@msn.com
# DEC 2014
use String::Util "trim";
use List::MoreUtils "minmax";
# --- Usage --- #
if (@ARGV == 0 && -t STDIN && -t STDERR) { 
    print STDERR "$0: USAGE: perl hmetis2poly_v2.pl [CNF FILE] [HMETIS FILE] [OUTPUT FILENAME]\n";
    exit;
}
# declare all variables to use.
my ($i, @input_file_lines, @hmetis_file_lines, @linesplit, @vars, @clauses, @polys, %ideals, $CNF_filename, $HMETIS_filename, $output_filename);

$CNF_filename = $ARGV[0];
$HMETIS_filename = $ARGV[1];
$output_filename = $ARGV[2];

# open input cnf file
open INPUT_FILE, $CNF_filename;
# copy lines to array
@input_file_lines = <INPUT_FILE>;
# close input cnf file
close INPUT_FILE;

# open input hmetis partition file
open INPUT_FILE, $HMETIS_filename;
# copy lines to array
@hmetis_file_lines = <INPUT_FILE>;
# close input hmetis partition file
close INPUT_FILE;
# clean up lines in hmetis file
for(@hmetis_file_lines) {
    $_ = trim($_);
}
# get min and max partition numbers.
($min, $max) = minmax @hmetis_file_lines;
# create ideal vars hash, partition start at zero is not guaranteed.
for($min..$max) {
    $ideals{"I$_"} = "ideal I$_ = ";
}

# delete all comment lines.
while($input_file_lines[0] =~ m/^c/) {
    shift(@input_file_lines);
}

# create all clause vars and variable vars from p cnf line.
@linesplit = split(' ', $input_file_lines[0]);
@vars = (1..$linesplit[2]);
for(1..$linesplit[3]) {
    @clauses = (@clauses, "c$_");
    @polys = (@polys, "p$_");
}
for(@vars) {
    $_ = "v$_";
}

# open output file to write to.
open OUTPUT_FILE, ">$output_filename" or die $!;
# create ring line, print to output file.
print OUTPUT_FILE "ring r = 0,(", join(", ", @clauses, @vars), "),lp;\n\n";
# delete p cnf line.
shift(@input_file_lines);
# print polynomials to output file.
for($i = 0; $i < scalar @input_file_lines; $i++) {
    @linesplit = split(' ', $input_file_lines[$i]);
    pop(@linesplit);
    print OUTPUT_FILE "poly $polys[$i] = $clauses[$i]";
    for(@linesplit) {
	print OUTPUT_FILE " + $vars[abs(trim($_)) - 1]";
    }
    print OUTPUT_FILE ";\n";
}
$i = 0;
for(@hmetis_file_lines) {
    $ideals{"I$_"} = join($ideals{"I$_"}eq"ideal I$_ = "?"":", ", $ideals{"I$_"}, $polys[$i++]);
}
# remove empty ideals.
for(keys %ideals) {
    if($ideals{$_} eq "ideal $_ = ") {
	delete $ideals{$_};
    }
}
for(values %ideals) {
    print OUTPUT_FILE $_, ";\n";
}

print OUTPUT_FILE "list parts = ", join(", ", keys %ideals), ";\n";
close OUTPUT_FILE;
print "Done.\nSee $output_filename for results.";


#!/usr/bin/perl

use TagIndex;
use TagReader;

my $index = new TagIndex();

my $scan_dir = "/home/kyle/Music";
my @queue = ();

unshift (@queue, $scan_dir);

while ($#queue + 1) {
    my $file = shift (@queue);
    print "$file: ";
    if (-e $file)   {
        if (-d $file)   {
            print "directory \n";
            opendir DIR, $file;
            my @contents = readdir (DIR);
            closedir DIR;

            foreach my $obj (@contents) {
                if (not $obj eq '.' and not $obj eq '..')   {
                    unshift (@queue, "$file/$obj");
                }
            }
        }   else    {
            print "file \n";
            my $tags = new TagReader($file);

            if (
                $tags->getFileType() ne 'mp3' and 
                $tags->getFileType() ne 'ogg')
            {
                print "\t not an ogg or mp3 \n";
            }
            else
            {
                if (!   ($tags->getArtist() and 
                        $tags->getAlbum() and 
                        #  $tags->{TAG_TRACK} and 
                        $tags->getTitle()))
                {
                    print "\t missing tags \n";
                    print "\t Artist: " . $tags->getArtist() . " \n";
                    print "\t Album: " . $tags->getAlbum() . " \n";
                    print "\t Track: " . $tags->getTrack() . " \n";
                    print "\t Title: " . $tags->getTitle() . " \n";
                }
                else
                {
                    print "adding: \n\t"
                        . $tags->getArtist() . "\n\t"
                        . $tags->getAlbum() . "\n\t"
                        . $tags->getTitle() . "\n";
                    $index->addFile(
                        $tags->getArtist(),
                        $tags->getAlbum(),
                        $tags->getTitle(),
                        $file
                    );
                }
            }
        }
    }
}



$index->dump();

die("Test Complete \n");

$index->addArtist('AFI');
$index->addArtist('Army of Me');
$index->addArtist('Coheed & Cambria');

$index->addArtist('Coheed and Cambria');
$index->addArtist('Coheed and Cambria');
$index->addArtist('Coheed & Cambria');
$index->addArtist('Coheed & CAMbrIa');
$index->addArtist('cOHeed and   Cambria');

$index->addArtist('A.F.I.');
$index->addArtist('afi');
$index->addArtist('Afi');

$index->addArtist('army of me');
$index->addArtist('Army Of Me');
$index->addArtist('ARMY OF ME');


$index->addArtist('Velourium Camper III - Al the Killer');
$index->addArtist('Velourium Camper iii - Al The Killer');
$index->addArtist('Velourium Camper 3 - Al the Killer');
$index->addArtist('1. Test of Roman Numerals i');
$index->addArtist('2. Test of Roman Numerals ii');
$index->addArtist('3. Test of Roman Numerals iii');
$index->addArtist('4. Test of Roman Numerals iv');
$index->addArtist('5. Test of Roman Numerals v');
$index->addArtist('6. Test of Roman Numerals vi');
$index->addArtist('7. Test of Roman Numerals vii');
$index->addArtist('8. Test of Roman Numerals viii');
$index->addArtist('9. Test of Roman Numerals ix');
$index->addArtist('10. Test of Roman Numerals x');

$index->addArtist('Deer Hunter, The');
$index->addArtist('The Deer Hunter');

$index->addArtist('MC Hammer');
$index->addArtist('mc Hammer');

$index->addArtist('A.F.I.');
$index->addArtist('AFI');
$index->addArtist('H.I.M.');
$index->addArtist('HIM');


$index->addArtist('1 of the start');
$index->addArtist('I am the killer');
$index->addArtist('Someday I will know...');

$index->addAlbum('Coheed & Cambria', 'In Keeping Secrets of Silent Earth: 3');
$index->addTrack(
    'Coheed & Cambria', 
    'In Keeping Secrets of Silent earth: 3',
    'Three Evils (Embodied in love and shadow)');



$index->dump();







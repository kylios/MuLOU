#!/usr/bin/perl

# This structure acts as an index structure to store song data with references
# to files on the file system.  When indexing song data such as artist, album,
# and title tags, the index will automatically normalize the data and detect
# duplicate files.  

package TagIndex;

use strict;

# These words need to be lower case unless they are the first word
our @lower_words = (
    'and',
    'or',
    'but',
    'nor',
    'by',
    'the',
    'a', 
    'an',
    'in', 
    'then',
    'at',
    'by',
    'for',
    'from',
    'into',
    'of',
    'off',
    'on',
    'onto',
    'out',
    'over',
    'to',
    'up',
    'with',
    'am',
    'are',
    'is'
);

our @upper_words = (
    'DJ',
    'I',
    'MC'
);


sub new
{
    my $class = shift();
    my $self = {
        _artists => {}
    };

    bless $self, $class;
    return $self;
}

sub addArtist
{   
    my $self = shift();
    my $artist = shift();

    $artist = $self->normalize($artist);
  
#    add($self->{_artists}, $artist);
#    $self->{_artists}->{$artist}->{_albums} = {};

#    return;

    my $hashref = $self->{_artists};
    my $fixed = 0;
    while ((my $key, my $value) = each(%$hashref))    {
        # if this key is lower case but an upper case version exists in the
        #   index, then instead add this artist to the upper case version
        # if this key is upper case but a lower case version exists in the
        #   index, then remove the lower case version from the index and 
        #   add an upper case version to the index

        if (lc($key) eq lc($artist))  {
            if ($key =~ m/^[A-Z]+$/) {   # if key is upper case
                $self->{_artists}->{$key}->{_count}++;
                $fixed = 1;
            }   elsif ($artist =~ m/^[A-Z]+$/)   {
                $self->{_artists}->{$artist}->{_count}
                     = $self->{_artists}->{$key}->{_count} + 1;
                delete $self->{_artists}->{$key};
                $fixed = 1;
            }
        }
    }

    if (!$fixed)    {
        $self->{_artists}->{$artist} = {
            _count  => 0,
            _albums => {}
        }   if (not exists $self->{_artists}->{$artist});
        $self->{_artists}->{$artist}->{_count}++;
    }
}

sub addAlbum
{
    my $self = shift();
    my $artist = shift();
    my $album = shift();

    $artist = $self->normalize($artist);
    $album = $self->normalize($album);

    $self->addArtist ($artist)
        if (not exists $self->{_artists}->{$artist});

    my $hashref = $self->{_artists}->{$artist}->{_albums};
    my $fixed = 0;
    while ((my $key, my $value) = each(%$hashref))    {
        # if this key is lower case but an upper case version exists in the
        #   index, then instead add this artist to the upper case version
        # if this key is upper case but a lower case version exists in the
        #   index, then remove the lower case version from the index and 
        #   add an upper case version to the index

        if (lc($key) eq lc($album))  {
            if ($key =~ m/^[A-Z]+$/) {   # if key is upper case
                $hashref->{$key}->{_count}++;
                $fixed = 1;
            }   elsif ($album =~ m/^[A-Z]+$/)   {
                $hashref->{$album}->{_count}
                     = $hashref->{$key}->{_count} + 1;
                delete $hashref->{$key};
                $fixed = 1;
            }
        }
    }

    if (!$fixed)    {
        $hashref->{$album} = {
            _count  => 0,
            _tracks => {}
        }   if (not exists $hashref->{$album});
        $hashref->{$album}->{_count}++;
    }        
}

sub addTrack
{
    my $self = shift();
    my $artist = shift();
    my $album = shift();
    my $track = shift();

    $artist = $self->normalize($artist);
    $album = $self->normalize($album);
    $track = $self->normalize($track);

    $self->addArtist ($artist)
        if (not exists $self->{_artists}->{$artist});
    $self->addAlbum ($artist, $album)
        if (not exists $self->{_artists}->{$artist}->{_albums}->{$album});

    my $hashref = 
        $self->{_artists}->{$artist}->{_albums}->{$album}->{_tracks};
    my $fixed = 0;
    while ((my $key, my $value) = each(%$hashref))    {
        # if this key is lower case but an upper case version exists in the
        #   index, then instead add this artist to the upper case version
        # if this key is upper case but a lower case version exists in the
        #   index, then remove the lower case version from the index and 
        #   add an upper case version to the index

        if (lc($key) eq lc($track))  {
            if ($key =~ m/^[A-Z]+$/) {   # if key is upper case
                $hashref->{$key}->{_count}++;
                $fixed = 1;
            }   elsif ($album =~ m/^[A-Z]+$/)   {
                $hashref->{$track}->{_count}
                     = $hashref->{$key}->{_count} + 1;
                delete $hashref->{$key};
                $fixed = 1;
            }
        }
    }

    if (!$fixed)    {
        $hashref->{$track} = {
            _count  => 0,
            _files  => {}
        }   if (not exists $hashref->{$track});
        $hashref->{$track}->{_count}++;
    }        
}

sub addFile
{
    my $self = shift();
    my $artist = shift();
    my $album = shift();
    my $track = shift();
    my $file = shift();

    $artist = $self->normalize($artist);
    $album = $self->normalize($album);
    $track = $self->normalize($track);

    $self->addArtist ($artist)
        if (not exists $self->{_artists}->{$artist});
    $self->addAlbum ($artist, $album)
        if (not exists $self->{_artists}->{$artist}->{_albums}->{$album});
    $self->addTrack ($artist, $album, $track)
        if (not exists $self->{_artists}->{$artist}->{_albums}->{$album}->
            {_tracks}->{$track});

    my $hashref = 
        $self->{_artists}->{$artist}->{_albums}->{$album}->{_tracks}->
            {$track}->{_files};

    $hashref->{$file} = $file;
}

sub add
{
    my $hash = shift();
    my $key = shift();

    my $fixed = 0;
    while ((my $k, my $v) = each(%$hash))   {
        if ($k =~ m/^$key$/i)   {
            if ($k =~ m/^[A-Z]+$/)  {
                $hash->{$k}->{_count}++;
                $fixed = 1;
            }   elsif ($key =~ m/^[A-Z]+$/) {
                $hash->{$key}->{_count} = $hash->{$k}->{_count} + 1;
                delete $hash->{$k};
                $fixed = 1;
            }
        }
    }

    if (!$fixed)    {
        if (not exists $hash->{$key})   {
            $hash->{$key} = {_count => 0}; 
        }
        $hash->{$key}->{_count}++;
    }
}

sub dump
{
    my $self = shift();

    my $artist_hashref = $self->{_artists};
    while ((my $artist, my $artist_value) = each(%$artist_hashref))    {
        my $artist_count = $artist_value->{_count};
        print ("$artist: $artist_count \n");

        my $album_hashref = $artist_value->{_albums};
        while ((my $album, my $album_value) = each(%$album_hashref))    {
            my $album_count = $album_value->{_count};
            print ("\t$album: $album_count \n");

            my $track_hashref = $album_value->{_tracks};
            while ((my $track, my $track_value) = each(%$track_hashref))  {
                my $track_count = $track_value->{_count};
                print ("\t\t$track: $track_count \n");
            
                my $file_hashref = $track_value->{_files};
                while ((my $file, my $file_value) = each(%$file_hashref))  {
                    print ("\t\t\t$file\n");
                }
            }
        }
    }
}

sub normalize
{
    my $self = shift();
    my $name = shift();

    ###
    # define an action to take on the name
    # 0: upper camel case
    # 1: lower camel case
    # 2: upper case
    # 3: lower case
    my $action = 0;

    # Remove certain characters from a name
    # e.g.  Coheed & Cambria => Coheed and Cambria
    $name =~ s/&/and/g;

    if ($action == 0)   {   # set to upper camel case
        # convert names to upper camel case
        # e.g. COHEED AND CAMBRIA  to  Coheed and Cambria
        # Note: the proper words will remain lower case unless 
        #   they lead the phrase.
        #   see @lower_words defined at the top of the file
        $name = lc $name;
        my @words = split(/\s/, $name);
        $name = '';
        my $i = 0;
        my $start = 1;
        foreach my $word (@words)  {
            $word = trim($word);
            if (    not ($word =~ m/\s/) and 
                    length($word) > 0)    {
                

                my $word_pre = '';
                my $word_post = '';
#                if ($word =~ m/^([^A-Za-z]*)([A-Za-z]+)([^A-Za-z]*)$/){
#                    $word_pre = $1;
#                    $word_post = $3;
#                    $word = $2;
#                }
                if ($word =~ m/^\[(.*)/)    {
                    $word_pre = '[';
                    $word = $1;
                }
                if ($word =~ m/^(.*)\]$/)   {
                    $word_post = ']';
                    $word = $1;
                }


                if ($word =~ m/(.*)\((.*)/) {
                    my $word_begin = $self->normalize($1);
                    my $word_end = $self->normalize($2);
                    $name .= $word_begin . '(' . $word_end . ' ';
                    next;
                }

                if ($word =~ m/(.*)\)(.*)/) {
                    my $word_begin = $self->normalize($1);
                    my $word_end = $self->normalize($2);
                    $name .= $word_begin . ') ' . $word_end . ' ';
                    next;
                }
                #while (substr($word, 0, 1) eq "(")  {
                #    $word_pre .= "(";
                #    $word = substr($word, 1);
                #}

                #while (substr($word, -1) eq ")")    {
                #    $word_post .= ")";
                #    $word = substr($word, 0, length($word) - 1);
                #}
                
                # Make the word friendly to regexes
                # NOTE: it is appalling how many regex unfriendly song names
                #   there are.  Goddam The Killers, who have a song titled
                #   "Under the Gun [#][*]"  ...that's just a dick move right
                #   there...
                $word =~ s/\#/\\\#/g;
                $word =~ s/\*/\\\*/g;
                $word =~ s/\[/\\\[/g;
                $word =~ s/\]/\\\]/g;

                my $normWord = $word;

                # If the word is supposed to be all-uppercase
                # examples:
                #   MC
                #   H.I.M.
                if ($word =~ m/([A-Za-z]\.){2,}/ or 
                    grep(/^\Q$word\E$/i, @upper_words))    {
                    $word =~ s/\.//g;
                    $normWord = uc ($word);
                    $start = 0;
                }
               
                # if it is a lower case word (or, and, so, etc...)
                # and not the first word, then we lower case the word
                elsif (grep (/^\Q$word\E$/i, @lower_words) and !$start) {
                    $normWord = lc ($word);
                    $start = 0;
                }

                # Match a roman numeral and convert it to arabic
                elsif (isRomanNumerals($word)) {
                    $normWord = romanToArabic(uc($word));
                }
 

                # The standard action is to put the word in upper camel
                else    {
                    $normWord = uc (substr ($word, 0, 1)) . substr ($word, 1);
                    $start = 0;
                }

                # if the word was a number, then we set start back to 1
                # so that the next word will be upper camel regardless of
                # whether it is a lower word or not
                if ($word =~ m/^[0-9]+\.*$/)   {
                    $start = 1;
                }
                
                $name .= $word_pre . $normWord . $word_post . ' ';
                $i++;
            }
        }
        
        chop $name;
    }   elsif ($action == 1)    {   # set to lower camel case
    }   elsif ($action == 2)    {   # set to upper case
        $name = uc ($name);
    }   elsif ($action == 3)    {   # set to lower case
        $name = lc ($name);
    }

    if ($name =~ m/(.*)\,\sThe$/i)    {
        $name = "The $1";
    }

    if ($name =~ m/(.*)[\(\[]Disc \n[\)\]]$/)    {
        $name = $1;
    }

    return $name; 
}


sub isRomanNumerals
{
    my $name = shift();

    $name = uc ($name);
    
    return ($name =~ m/^[IVXMCDL]+$/i);
}

sub romanToArabic
{
    my $str = shift();

    my $numerals = {
        ''      => 0,
        'I'     => 1,
        'V'     => 5,
        'X'     => 10,
        'L'     => 50,
        'C'     => 100,
        'D'     => 500,
        'M'     => 1000
    };

    my $len = length($str);
    my $c1 = substr($str, 0, 1);
    my $c2 = '';
    my $c3 = '';
    my $total = 0;
    for (my $i = 1; $i < $len; $i++)    {
        $c3 = $c2;
        $c2 = $c1;
        $c1 = substr($str, $i, 1);

        if ($numerals->{$c2} < $numerals->{$c1})  {
            $total += $numerals->{$c1} - $numerals->{$c2};
        }   elsif ($numerals->{$c1} < $numerals->{$c2})    {
            $total += $numerals->{$c1} + $numerals->{$c2};
        }   else    {
            $total += $numerals->{$c1};
            if ($c3 eq '') {
                $total += $numerals->{$c2};
            }
        }
    }

    if ($total == 0)    {
        $total = $numerals->{$c1};
    }

    return '' . $total;
}

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}


1;

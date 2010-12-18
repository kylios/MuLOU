#!/usr/bin/perl

package TagReader;

use MP3::Tag;

# tag and file information
use constant TAG_ARTIST          => 'Artist';
use constant TAG_ALBUM           => 'Album';
use constant TAG_TRACK           => 'Track';
use constant TAG_TITLE           => 'Title';
use constant TAG_FILE_TYPE       => 'FileType';



sub new
{
    my $class = shift();
    my $file = shift();
    
    my $self = {
        file            => $file,
        TAG_FILE_TYPE   => '',
        TAG_ARTIST      => '',
        TAG_ALBUM       => '',
        TAG_TRACK       => '',
        TAG_TITLE       => ''
    };

    bless ($self, $class);

    $self->read_tags();

    return $self;
}

sub getFile
{
    my $self = shift();

    return $self->{file};
}

sub getArtist
{
    my $self = shift();

    return $self->{TAG_ARTIST};
}

sub getAlbum
{
    my $self = shift();

    return $self->{TAG_ALBUM};
}

sub getTitle
{
    my $self = shift();

    return $self->{TAG_TITLE};
}

sub getTrack
{
    my $self = shift();

    return $self->{TAG_TRACK};
}

sub getFileType
{
    my $self = shift();

    return $self->{TAG_FILE_TYPE};
}

sub read_tags
{
    my $self = shift;
    my $file = $self->getFile();

    my @tokens = split /\./, $file;
    my $ext = $tokens[$#tokens];
    
    if ($ext eq 'mp3')  {
        read_tags_mp3 ($self);

    }   elsif ($ext eq 'ogg') {
        read_tags_ogg ($self);
    }
    # add more types here
    #
    #
    $self->{TAG_FILE_TYPE} = $ext;
    
    return $tags;
}

sub read_tags_mp3
{
    my $self = shift();
    my $file = $self->getFile();

    $tags = MP3::Tag->new($file);
    $tags->get_tags();
    
    # check first for id3v2
    if (exists $tags->{ID3v2})  {
        $frames = $tags->{ID3v2}->get_frame_ids();
        
        ($self->{TAG_NUMBER}, $desc)    = $tags->{ID3v2}->get_frame('TRCK');
        ($self->{TAG_ARTIST}, $desc)    = $tags->{ID3v2}->get_frame('TPE1');
        ($self->{TAG_ALBUM}, $desc)     = $tags->{ID3v2}->get_frame('TALB');
        ($self->{TAG_TITLE}, $desc)     = $tags->{ID3v2}->get_frame('TIT2');
        
    }   elsif (exists $tags->{ID3v1}) {
        $self->{TAG_ARTIST}     = $tags->{ID3v1}->artist;
        $self->{TAG_TITLE}      = $tags->{ID3v1}->title;
        $self->{TAG_ALBUM}      = $tags->{ID3v1}->album;
        $self->{TAG_NUMBER}     = '';  # not sure how we can get this for real?
        
    }   else    {
        
        # we could probably get the tags by parsing the pathname here and then
        # normalizing them - but not now
        # TODO ^^^^^^
    }
    
    $tags->close();
}

sub read_tags_ogg
{
    my $self = shift();
    my $file = $self->getFile();
    
    open(TAGS, 'vorbiscomment -l "'.$file.'"|');
	my @tags = <TAGS>;
	close(TAGS);
	
	foreach my $tag (@tags)	{
		if ( $tag =~ m/^TITLE=(.*)/ )	{
			$self->{TAG_TITLE} = $1;
		}
		elsif ( $tag =~ m/^ARTIST=(.*)/ )	{
			$self->{TAG_ARTIST} = $1;
		}
		elsif ( $tag =~ m/^TRACKNUMBER=(.*)/ )	{
			$self->{TAG_TRACK} = $1;
		}
		elsif ( $tag =~ m/^ALBUM=(.*)/ )	{
			$self->{TAG_ALBUM} = $1;
		}
	}
}

1;

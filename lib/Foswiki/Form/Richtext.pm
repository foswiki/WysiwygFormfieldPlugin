# See bottom of file for license and copyright information
package Foswiki::Form::Richtext;

use strict;
use warnings;

#TODO: lazyload..?
use Foswiki::Plugins::WysiwygPlugin::Handlers;

use Foswiki::Form::Textarea ();
our @ISA = ('Foswiki::Form::Textarea');

sub new {
    my $class = shift;
    my $this  = $class->SUPER::new(@_);
    if ( $this->{size} =~ /^\s*(\d+)x(\d+)\s*$/ ) {
        $this->{cols} = $1;
        $this->{rows} = $2;
    }
    else {
        $this->{cols} = 50;
        $this->{rows} = 4;
    }
    return $this;
}

=begin TML

---++ ObjectMethod finish()
Break circular references.

=cut

# Note to developers; please undef *all* fields in the object explicitly,
# whether they are references or not. That way this method is "golden
# documentation" of the live fields in the object.
sub finish {
    my $this = shift;
    $this->SUPER::finish();
    undef $this->{cols};
    undef $this->{rows};
}

sub renderForEdit {
    my ( $this, $topicObject, $value ) = @_;
    my $class = 'foswikiRichtextFieldEdit';

    use Foswiki::Plugins::WysiwygFormfieldPlugin;
    my $not_ok =
      Foswiki::Plugins::WysiwygFormfieldPlugin::addWysiwygEdit( $value,
        $topicObject->topic(), $topicObject->web() );
    $class .= 'Disabled' if defined($not_ok);

    #print STDERR $not_ok;

    return (
        '',
        CGI::textarea(
            -class   => $this->cssClasses($class),
            -cols    => $this->{cols},
            -rows    => $this->{rows},
            -name    => $this->{name},
            -default => "\n" . $value
        )
    );
}

sub renderForDisplay {
    my ( $this, $format, $value, $attrs ) = @_;

    $value = Foswiki::Func::renderText($value);
    return $this->SUPER::renderForDisplay( $format, $value, $attrs );

}

sub populateMetaFromQueryData {
    my ( $this, $query, $meta, $old ) = @_;

    #TODO: wish we didn't need to duplicate this code
    return unless $this->{name};
    my %names = map { $_ => 1 } $query->param;

    if ( $names{ $this->{name} } ) {
        my $value;

        $value = $query->param( $this->{name} );
        $value = '' unless defined $value;

        #print STDERR "richtext::fromPOST($value)\n";

        my $WYSIWYG_SECRET_ID =
          $Foswiki::Plugins::WysiwygPlugin::Handlers::SECRET_ID;
        if ( $value =~ s/<!--$WYSIWYG_SECRET_ID-->//go ) {
            $value =
              Foswiki::Plugins::WysiwygPlugin::Handlers::TranslateHTML2TML(
                $value, $_[1], $_[2] );

#Foswiki::Plugins::WysiwygPlugin::afterEditHandler($value, $meta->topic, $meta->web);
#should be careful only to do the regex if we've actually wysiwyg converted
            $value =~ s/\n/\r\n/g;

            #remove placeholder so blank text == empty formfield
            $value =~ s/\r\n$//m;

            #print STDERR "richtext::populate($value)\n";
            $query->param( $this->{name}, $value );
        }
    }

    return $this->SUPER::populateMetaFromQueryData( $query, $meta, $old );
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) SvenDowideit & 2012 Foswiki Contributors. Foswiki 
Contributors are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.

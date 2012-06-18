# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::WysiwygFormfieldPlugin



=cut

package Foswiki::Plugins::WysiwygFormfieldPlugin;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Assert;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

our $VERSION = '$Rev$';
our $RELEASE = '0.3';
our $SHORTDESCRIPTION =
  'Wysiwyg HTML and TML edited textareas to Foswiki Data Forms';
our $NO_PREFS_IN_TOPIC = 1;

=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean
   * =$topic= - the name of the topic in the current CGI query
   * =$web= - the name of the web in the current CGI query
   * =$user= - the login name of the user
   * =$installWeb= - the name of the web the plugin topic is in
     (usually the same as =$Foswiki::cfg{SystemWebName}=)


=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    # Plugin correctly initialized
    return 1;
}

=begin TML

---++ finishPlugin()

Called when Foswiki is shutting down, this handler can be used by the plugin
to release resources - for example, shut down open database connections,
release allocated memory etc.

Note that it's important to break any cycles in memory allocated by plugins,
or that memory will be lost when Foswiki is run in a persistent context
e.g. mod_perl.

=cut

#sub finishPlugin {
#}

=begin TML

---++ addWysiwygEdit($text, $topic, $web )
   * =$text= - text that will be edited
   * =$topic= - the name of the topic in the current CGI query
   * =$web= - the name of the web in the current CGI query
This handler is called by the edit script just before presenting the edit text
in the edit box. It is called once when the =edit= script is run.

*NOTE*: meta-data may be embedded in the text passed to this handler 
(using %META: tags)

*Since:* Foswiki::Plugins::VERSION = '2.0'

=cut

sub addWysiwygEdit {
    my ( $text, $topic, $web ) = @_;

    my $mess = Foswiki::Plugins::TinyMCEPlugin::_notAvailable();
    if ($mess) {
        if ( ( $mess !~ /^Disabled/ || DEBUG )
            && defined &Foswiki::Func::setPreferencesValue )
        {
            Foswiki::Func::setPreferencesValue( 'EDITOR_MESSAGE',
                'WYSIWYG could not be started: ' . $mess );
        }
        return $mess;
    }
    if ( defined &Foswiki::Func::setPreferencesValue ) {
        Foswiki::Func::setPreferencesValue( 'EDITOR_HELP', 'TinyMCEQuickHelp' );
    }

    my $initTopic =
      Foswiki::Func::getPreferencesValue('WYSIWYGFORMFIELDPLUGIN_INIT_TOPIC')
      || $Foswiki::cfg{SystemWebName} . '.WysiwygFormfieldPlugin';
    my $init = Foswiki::Func::getPreferencesValue('WYSIWYGFORMFIELDPLUGIN_INIT')
      || Foswiki::Func::expandCommonVariables(
        '%INCLUDE{"'
          . $initTopic
          . '" section="WYSIWYGFORMFIELDPLUGIN_INIT" warn="off"}%',
        $topic, $web
      );

    require Foswiki::Plugins::WysiwygPlugin;
    my ( $browser, $defaultINIT_BROWSER ) =
      Foswiki::Plugins::WysiwygPlugin::getBrowserName();
    $mess = Foswiki::Plugins::WysiwygPlugin::notWysiwygEditable($text);
    if ($mess) {
        if ( defined &Foswiki::Func::setPreferencesValue ) {
            Foswiki::Func::setPreferencesValue( 'EDITOR_MESSAGE',
                'WYSIWYG could not be started: ' . $mess );
            Foswiki::Func::setPreferencesValue( 'EDITOR_HELP', undef );
        }
        return $mess;
    }

    #TODO: push this into template files, so that it can be fully abstracted.
    my $scripts = <<"SCRIPT";
<script type="text/javascript">
init = {
  $init
};
FoswikiTiny.install(init);
</script>
SCRIPT

    Foswiki::Func::addToZone( 'script', 'WysiwygFormfieldPlugin', $scripts,
        'TinyMCEPlugin' );

    # See %SYSTEMWEB%.IfStatements for a description of this context id.
    Foswiki::Func::getContext()->{textareas_hijacked} = 1;

    return;
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: SvenDowideit SvenDowideit@fosiki.com

Copyright (C) 2008-2011 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
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

# MODINFO module CGI::CookieSerial a wrapper for creating serialized cookies with Data::Serializer and CGI::Cookie
package CGI::CookieSerial;

# MODINFO dependency module 5.008
use 5.008;
# MODINFO dependency module warnings
use warnings;
# MODINFO dependency module CGI::Cookie
use CGI::Cookie;
# MODINFO dependency module Data::Serializer
use Data::Serializer;

# MODINFO version 0.01
our $VERSION = '0.01';

# MODINFO constructor new create a new CookieSerial object
sub new {
        my $class = shift;
        $class = ref($class) if ref($class);
        my($name,$data,$path,$domain,$secure,$expires) =
                CGI::Cookie::rearrange([NAME,[VALUE,VALUES],PATH,DOMAIN,SECURE,EXPIRES],@_);

        # Pull out our parameters.
        my @values;
        my $value;
        if (ref($value)) {
                if (ref($value) eq 'ARRAY') {
                        @values = @$value;
                } elsif (ref($value) eq 'HASH') {
                        @values = %$value;
                }
        } else {
                @values = ($value);
        }

        bless my $self = {
                'name'=>$name,
                'data'=>[@values],
        }, $class;

        # IE requires the path and domain to be present for some reason.
        $path ||= "/";

	# these function calls are ugly... need to change them
        $self->{path} = CGI::Cookie::path($path)     if defined $path;
        $self->{domain} = CGI::Cookie::domain($domain) if defined $domain;
        $self->{secure} = CGI::Cookie::secure($secure) if defined $secure;
        $self->{expires} = CGI::Cookie::expires($expires) if defined $expires;

        $self->{capncrunch} = Data::Serializer->new(	# yes, I know it's not a cookie cereal... it's just so good...
                cipher => 'Blowfish',
                secret => 'Sd35wsyJJ6l9zaPxkaeAQUZE3yoCDA83P9ZilFyuYefb+pVJ+qiKZKCp7JqBXpYz',
                compress => 1,
        );

        return $self;
}

# MODINFO method burn
sub burn {
        my $self = shift;
        my $cookie_data = shift || $self->{data};                        # data reference

        # make into cookie form
        my $cookie = CGI::Cookie->new(
                -name => $self->{name},
                -value => $self->{capncrunch}->freeze($cookie_data),
                -secure => $self->{secure},
                -path => $self->{domain},
                -expires => $self->{expires},
                -domain => $self->{domain},
        );

        # print header
        print "Set-Cookie: $cookie\n";
}

# MODINFO method cool
sub cool {
        my $self = shift;

        # prepare to eat the cookie

        # fetch cookie
        my %cookies = fetch CGI::Cookie;
        my $data = $cookies{$self->{name}}->value();

        # deserialize the data
        my $soggy = $self->{capncrunch}->thaw($data);

        return $soggy;
}

# MODINFO method eat
sub eat {
        my $self = shift;
        my $cookie_name = shift;

        print $self->cool($cookie_name);
}

1;
__END__

=head1 NAME

CGI::CookieSerial - a wrapper for creating serialized cookies with Data::Serializer and CGI::Cookie

=head1 SYNOPSIS

Setting a cookie with data:
#!/usr/bin/perl

 use strict;
 use CGI;
 use CGI::CookieSerial;

 my $cgi = new CGI;
 my $pbscookie = new CGI::CookieSerial(  
  	-name => 'ticklemeelmo', 
 );

 my @data = (
	{
 		'to' => 'di',
		'froo' => 'ti',
 		actor => 'Steve Martin',
		food => 3.14,
	},
	'apple',
	24,
 );

 $pbscookie->burn(\@data);
 print $cgi->header({  
	-type => 'text/html', 
 });

Retrieving a cookie with data:

 use strict;
 use Data::Dumper;
 use CGI;
 use CGI::CookieSerial;

 my $cgi = new CGI;
 my $pbscookie = new CGI::CookieSerial(  
	-name => 'ticklemeelmo', 
 );

 my @data = @{$pbscookie->cool()};

 print $cgi->header({  -type => 'text/html', });

 print "<html><body><pre>";
 print Dumper(@data)."<br>";
 print "$data[2]<br>";
 print "$data[0]{actor}";
 print "</body></html>"; 



=head1 ABSTRACT

  Although deceptively similar to the workings of CGI::Cookie, this module
  operates a little differently. By design, it is very simple to use. In
  essence, one need only instantiate a new object and name the cookie,
  create the data, and burn the cookie. Retrieval is just as simple.

=head1 DESCRIPTION

Stub documentation for CGI::CookieSerial, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head1 METHONDS

=head2 new()

This is shamelessly copied from CGI::Cookie (more or less); it takes all the same parameters as CGI::Cookie. In addition to the CGI::Cookie->new() parameters, new() also takes the same parameters as Data::Serializer->new(). This gives the following list of parameters:

 -name
 -value 
 -expires
 -domain
 -path 
 -secure 

and

 -serializer
 -digester
 -cipher
 -secret
 -portable
 -compress
 -serializer_token

=head2 burn()

This method takes a parameter that is a reference to the data you want to store in the cookie. It serializes it and then sends the header. Only call this method when you are ready to set the cookie header.

=head2 cool()

This method returns the value of the cookie, either a stings or a reference (depending on what you stored).

=head2 eat()

This method simply prints the value of the cookie. There's really not a great deal of use for this method, despite the name, unless you are debugging.

=head1 TODO

Implement this with inheritance
Not require that data be a reference, and have the module intelligently check and then Do The Right Thing

=head1 SEE ALSO

L<CGI>, L<CGI::Cookie>, L<Data::Serializer>

=head1 AUTHOR

Duncan McGreggor, E<lt>oubiwann at cpan dot orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Duncan McGreggor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

package Boxee;

use Coat;
use LWP::UserAgent;
use Dancer::Logger;
use BoxeeKey;

my %KEYS = %{ BoxeeKey->keys };

has server => (isa => 'Str', is => 'ro', required => 1);
has port   => (isa => 'Str', is => 'ro', required => 1, default => '8800');

sub BUILD { 
    my ($self) = @_;
}

sub send_command {
    my ($self, $command, @args) = @_;
    my $path = "/xbmcCmds/xbmcHttp?command=$command";
    return $self->send_http_request($self->server, $self->port, $path);
}

sub send_http_request {
    my ($self, $server, $port, $path) = @_;

    my $url = "http://${server}:${port}${path}";
    Dancer::Logger->debug("send_http_request: $url");
    my $req = HTTP::Request->new(GET => $url);
    my $res = LWP::UserAgent->new->request($req);

    if ($res->is_success) {
        return $res->content;
    }
    else {
        die $res->status_line;
    }
}

sub exit { shift->send_command('Exit()') }
sub pause { shift->send_command('Pause()') }

sub up { shift->send_command('SendKey('.$KEYS{ACTION_MOVE_UP}.')') }
sub left { shift->send_command('SendKey('.$KEYS{ACTION_MOVE_LEFT}.')') }
sub right { shift->send_command('SendKey('.$KEYS{ACTION_MOVE_RIGHT}.')') }
sub down { shift->send_command('SendKey('.$KEYS{ACTION_MOVE_DOWN}.')') }

sub ping { 
    my ($self) = @_;
    local $@;
    eval { $self->send_command('getcurrentlyplaying') };
    return $@ ? 0 : 1;
}

sub get_currently_playing {
    my ($self) = @_;
    my $content;

    local $@;
    eval { $content = $self->send_command('getcurrentlyplaying') };
    return undef if $@;

    my $playing = {};
    foreach my $line (split(/\n/, $content)) {
        if ($line =~ /<li>([^:]+):(.+)/) {
            Dancer::Logger->debug("$1 -> $2");
            $playing->{$1} = $2;
        }
    }
    return $playing;
}

1;

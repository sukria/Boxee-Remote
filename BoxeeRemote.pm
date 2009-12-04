package BoxeeRemote;
use Dancer;
use Template;

use lib 'lib';
use Boxee;

get '/' => sub {
    template 'connect';
};

post '/connect' => sub { 
    my $boxee = Boxee->new(
        server => params->{server},
        port   => params->{port},
    );

    if ($boxee->ping) {
        session boxee => $boxee;
        redirect '/remote';
    }
    else { 
        redirect '/error';
    }
};

get '/remote' => sub { 
    if (not session('boxee')) {
        redirect '/';
    }
    my $boxee = session('boxee');
    template 'remote', {
        boxee => $boxee,
        currently => $boxee->get_currently_playing,
    };
};

true;

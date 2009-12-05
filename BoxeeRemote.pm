package BoxeeRemote;
use Dancer;
use Template;

use lib 'lib';
use Boxee;

get '/' => sub {
    template 'connect';
};

post '/action/:action' => sub {
    my $boxee = session('boxee');
    my $action = params->{action};
    $boxee->$action;
    template boxee_status => {
        boxee => $boxee,
        currently => $boxee->get_currently_playing,
    }, { layout => false };
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

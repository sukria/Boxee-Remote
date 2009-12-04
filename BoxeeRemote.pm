package BoxeeRemote;
use Dancer;
use Template;

get '/' => sub {
    template 'index';
};

true;

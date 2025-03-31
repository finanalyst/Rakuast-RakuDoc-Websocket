use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Router::WebSocket;
use RakuDoc::To::HTML;

my $host = %*ENV<RAKU_WEB_REPL_HOST> // '0.0.0.0';
my $port = %*ENV<RAKU_WEB_REPL_PORT> // 50005;
my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    :$host,
    :$port,
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
    );
$http.start;
react {
    whenever signal(SIGINT) {
        $http.stop;
        done;
    }
}
sub routes() {
    route {
        get -> 'rakudoc_render' {
            web-socket :json, -> $incoming {
                supply whenever $incoming -> $message {
                    my $json = await $message.body;
                    if $json<source> {
                        my RakuDoc::Processor $rdp = RakuDoc::To::HTML.new.rdp;
                        my $ast;
                        my $error = '';
                        my $html;
                        try { $ast = $json<source>.AST }
                        $html = $rdp.render($ast);
                        CATCH {
                            default {
                                $error = .message;
                                $html = '';
                            }
                        }
                        emit({ :$html, :$error })
                    }
                    if $json<loaded> {
                        emit({ :connection<Confirmed> })
                    }
                }
            }
        }
    }
}

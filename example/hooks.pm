use Path::Tiny;

{
    start_save_session_post => sub {
        my ($self, $name, $dir) = @_;
        my $global = path($self->config->global_config)->basename->path('backups');
        $global->mkpath;
        path($dir, '.vtide.yml')->copy( $global, $name );
    },
}

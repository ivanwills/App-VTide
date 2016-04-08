use Path::Tiny;

{
    start_save_session_post => sub {
        my ($self, $name, $dir) = @_;
        my $global = path($self->config->global_config)->parent->path('backups');
        $global->mkpath;
        my $backup = path( $global, $name . '.yml' );
        path($dir, '.vtide.yml')->copy($backup);
    },
};

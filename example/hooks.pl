use Path::Tiny;

{
    init_name => sub {
        my ($self, $name_ref ) = @_;
        # keep all names lower case
        $$name_ref = lc $$name_ref;
    },
    start_pre => sub {
        my ($self, $name, $dir) = @_;
        my $global = path($self->config->global_config)->parent->path('backups');
        $global->mkpath;
        my $backup = path( $global, $name . '.yml' );
        path($dir, '.vtide.yml')->copy($backup);
    },
};

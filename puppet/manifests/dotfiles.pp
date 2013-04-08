# Definition: dotfilesSetup
#
# Description
#
# Parameters:
#
# Actions:
#
# Requires:
#  This definition has no requirements.
#
# Sample Usage:
#  dotfilesSetup
class  dotfiles {

    $username = 'salimane'
    $home_dir = "/home/${username}"

    exec {
        "chsh -s /bin/zsh ${username}":
            unless  => "grep -E '^${username}.+:/bin/zsh$' /etc/passwd",
            require => [ Package['zsh'], USER[$username]];

        'clone_dotfiles':
            cwd     =>"${home_dir}/htdocs",
            user    => $username,
            command => "git clone https://github.com/salimane/dotfiles.git ${home_dir}/htdocs/dotfiles",
            creates => "${home_dir}/htdocs/dotfiles",
            require => [Package['git'], Package['zsh'], USER[$username], File["${home_dir}/htdocs"]]
    }

    file {
        "/home/${username}/htdocs":
            ensure => 'directory',
            owner  => 'salimane';

        "${home_dir}/bin":
            ensure => 'directory',
            owner  => 'salimane';

        "${home_dir}/.zshrc":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/zsh/.zshrc",
            require => Exec['clone_dotfiles'];

        "${home_dir}/.wgetrc":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/wget/.wgetrc",
            require => Exec['clone_dotfiles'];

        "${home_dir}/.nanorc":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/nano/.nanorc",
            require => Exec['clone_dotfiles'];

        "${home_dir}/.gitconfig":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/git/.gitconfig",
            require => Exec['clone_dotfiles'];

        "${home_dir}/.gitattributes":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/git/.gitattributes",
            require => Exec['clone_dotfiles'];

        "${home_dir}/.gemrc":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/rb/.gemrc",
            require => Exec['clone_dotfiles'];

        "${home_dir}/.valgrindrc":
            ensure  => link,
            target  => "${home_dir}/htdocs/dotfiles/valgrind/.valgrindrc",
            require => Exec['clone_dotfiles'];
    }


    exec { 'copy-binfiles':
        cwd     => "${home_dir}/htdocs/dotfiles",
        user    => $username,
        command => "cp bin/* ${home_dir}/bin/ && chmod +x ${home_dir}/bin/*",
        require => Exec['clone_dotfiles'],
    }
}

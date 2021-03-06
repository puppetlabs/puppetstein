test_name "Patch puppet_agent components"

patchable_projects = ['puppet', 'hiera']

patchable_projects.each do |project|
  [agent, master].each do |host|
    host.install_package('git') if (ENV['puppet'] || ENV['hiera']) && host[:platform] !~ /osx/

    if patch_ref = ENV["#{project}"]
      project_fork, project_sha = patch_ref.split(':')
      step "Patch #{project} on #{host} with #{project_fork}:#{project_sha}" do
        if host[:platform] =~ /windows/
          pl_dir = '/cygdrive/c/Program Files/Puppet Labs/Puppet/sys/ruby/lib/ruby/vendor_ruby'
        else
          pl_dir = '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/'
        end
        clone_git_repo_on(host, '/tmp', extract_repo_info_from("https://github.com/#{project_fork}/#{project}##{project_sha}"))
        on(host, "/bin/cp -rf /tmp/#{project}/lib/* '#{pl_dir}'")
      end
    end
  end
end


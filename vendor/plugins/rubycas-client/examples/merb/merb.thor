***REMOVED***!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'fileutils'
require 'yaml'

***REMOVED*** Important - don't change this line or its position
MERB_THOR_VERSION = '0.2.1'

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

module ColorfulMessages
  
  ***REMOVED*** red
  def error(*messages)
    puts messages.map { |msg| "\033[1;31m***REMOVED***{msg}\033[0m" }
  end
  
  ***REMOVED*** yellow
  def warning(*messages)
    puts messages.map { |msg| "\033[1;33m***REMOVED***{msg}\033[0m" }
  end
  
  ***REMOVED*** green
  def success(*messages)
    puts messages.map { |msg| "\033[1;32m***REMOVED***{msg}\033[0m" }
  end
  
  alias_method :message, :success
  
  ***REMOVED*** magenta
  def note(*messages)
    puts messages.map { |msg| "\033[1;35m***REMOVED***{msg}\033[0m" }
  end
  
  ***REMOVED*** blue
  def info(*messages)
    puts messages.map { |msg| "\033[1;34m***REMOVED***{msg}\033[0m" }
  end
  
end

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

require 'rubygems/dependency_installer'
require 'rubygems/uninstaller'
require 'rubygems/dependency'

module GemManagement
  
  include ColorfulMessages
    
  ***REMOVED*** Install a gem - looks remotely and local gem cache;
  ***REMOVED*** won't process rdoc or ri options.
  def install_gem(gem, options = {})
    refresh = options.delete(:refresh) || []
    from_cache = (options.key?(:cache) && options.delete(:cache))
    if from_cache
      install_gem_from_cache(gem, options)
    else
      version = options.delete(:version)
      Gem.configuration.update_sources = false

      ***REMOVED*** Limit source index to install dir
      update_source_index(options[:install_dir]) if options[:install_dir]

      installer = Gem::DependencyInstaller.new(options.merge(:user_install => false))
      
      ***REMOVED*** Force-refresh certain gems by excluding them from the current index
      if !options[:ignore_dependencies] && refresh.respond_to?(:include?) && !refresh.empty?
        source_index = installer.instance_variable_get(:@source_index)
        source_index.gems.each do |name, spec| 
          source_index.gems.delete(name) if refresh.include?(spec.name)
        end
      end
      
      exception = nil
      begin
        installer.install gem, version
      rescue Gem::InstallError => e
        exception = e
      rescue Gem::GemNotFoundException => e
        if from_cache && gem_file = find_gem_in_cache(gem, version)
          puts "Located ***REMOVED***{gem} in gem cache..."
          installer.install gem_file
        else
          exception = e
        end
      rescue => e
        exception = e
      end
      if installer.installed_gems.empty? && exception
        error "Failed to install gem '***REMOVED***{gem} (***REMOVED***{version || 'any version'})' (***REMOVED***{exception.message})"
      end
      ensure_bin_wrapper_for_installed_gems(installer.installed_gems, options)
      installer.installed_gems.each do |spec|
        success "Successfully installed ***REMOVED***{spec.full_name}"
      end
      return !installer.installed_gems.empty?
    end
  end

  ***REMOVED*** Install a gem - looks in the system's gem cache instead of remotely;
  ***REMOVED*** won't process rdoc or ri options.
  def install_gem_from_cache(gem, options = {})
    version = options.delete(:version)
    Gem.configuration.update_sources = false
    installer = Gem::DependencyInstaller.new(options.merge(:user_install => false))
    exception = nil
    begin
      if gem_file = find_gem_in_cache(gem, version)
        puts "Located ***REMOVED***{gem} in gem cache..."
        installer.install gem_file
      else
        raise Gem::InstallError, "Unknown gem ***REMOVED***{gem}"
      end
    rescue Gem::InstallError => e
      exception = e
    end
    if installer.installed_gems.empty? && exception
      error "Failed to install gem '***REMOVED***{gem}' (***REMOVED***{e.message})"
    end
    ensure_bin_wrapper_for_installed_gems(installer.installed_gems, options)
    installer.installed_gems.each do |spec|
      success "Successfully installed ***REMOVED***{spec.full_name}"
    end
  end

  ***REMOVED*** Install a gem from source - builds and packages it first then installs.
  ***REMOVED*** 
  ***REMOVED*** Examples:
  ***REMOVED*** install_gem_from_source(source_dir, :install_dir => ...)
  ***REMOVED*** install_gem_from_source(source_dir, gem_name)
  ***REMOVED*** install_gem_from_source(source_dir, :skip => [...])
  def install_gem_from_source(source_dir, *args)
    installed_gems = []
    opts = args.last.is_a?(Hash) ? args.pop : {}
    Dir.chdir(source_dir) do      
      gem_name     = args[0] || File.basename(source_dir)
      gem_pkg_dir  = File.join(source_dir, 'pkg')
      gem_pkg_glob = File.join(gem_pkg_dir, "***REMOVED***{gem_name}-*.gem")
      skip_gems    = opts.delete(:skip) || []

      ***REMOVED*** Cleanup what's already there
      clobber(source_dir)
      FileUtils.mkdir_p(gem_pkg_dir) unless File.directory?(gem_pkg_dir)

      ***REMOVED*** Recursively process all gem packages within the source dir
      skip_gems << gem_name
      packages = package_all(source_dir, skip_gems)
      
      if packages.length == 1
        ***REMOVED*** The are no subpackages for the main package
        refresh = [gem_name]
      else
        ***REMOVED*** Gather all packages into the top-level pkg directory
        packages.each do |pkg|
          FileUtils.copy_entry(pkg, File.join(gem_pkg_dir, File.basename(pkg)))
        end
        
        ***REMOVED*** Finally package the main gem - without clobbering the already copied pkgs
        package(source_dir, false)
        
        ***REMOVED*** Gather subgems to refresh during installation of the main gem
        refresh = packages.map do |pkg|
          File.basename(pkg, '.gem')[/^(.*?)-([\d\.]+)$/, 1] rescue nil
        end.compact
        
        ***REMOVED*** Install subgems explicitly even if ignore_dependencies is set
        if opts[:ignore_dependencies]
          refresh.each do |name| 
            gem_pkg = Dir[File.join(gem_pkg_dir, "***REMOVED***{name}-*.gem")][0]
            install_pkg(gem_pkg, opts)
          end
        end
      end
      
      ensure_bin_wrapper_for(opts[:install_dir], opts[:bin_dir], *installed_gems)
      
      ***REMOVED*** Finally install the main gem
      if install_pkg(Dir[gem_pkg_glob][0], opts.merge(:refresh => refresh))
        installed_gems = refresh
      else
        installed_gems = []
      end
    end
    installed_gems
  end
  
  def install_pkg(gem_pkg, opts = {})
    if (gem_pkg && File.exists?(gem_pkg))
      ***REMOVED*** Needs to be executed from the directory that contains all packages
      Dir.chdir(File.dirname(gem_pkg)) { install_gem(gem_pkg, opts) }
    else
      false
    end
  end
  
  ***REMOVED*** Uninstall a gem.
  def uninstall_gem(gem, options = {})
    if options[:version] && !options[:version].is_a?(Gem::Requirement)
      options[:version] = Gem::Requirement.new ["= ***REMOVED***{options[:version]}"]
    end
    update_source_index(options[:install_dir]) if options[:install_dir]
    Gem::Uninstaller.new(gem, options).uninstall rescue nil
  end

  def clobber(source_dir)
    Dir.chdir(source_dir) do 
      system "***REMOVED***{Gem.ruby} -S rake -s clobber" unless File.exists?('Thorfile')
    end
  end

  def package(source_dir, clobber = true)
    Dir.chdir(source_dir) do 
      if File.exists?('Thorfile')
        thor ":package"
      elsif File.exists?('Rakefile')
        rake "clobber" if clobber
        rake "package"
      end
    end
    Dir[File.join(source_dir, 'pkg/*.gem')]
  end

  def package_all(source_dir, skip = [], packages = [])
    if Dir[File.join(source_dir, '{Rakefile,Thorfile}')][0]
      name = File.basename(source_dir)
      Dir[File.join(source_dir, '*', '{Rakefile,Thorfile}')].each do |taskfile|
        package_all(File.dirname(taskfile), skip, packages)
      end
      packages.push(*package(source_dir)) unless skip.include?(name)
    end
    packages.uniq
  end
  
  def rake(cmd)
    cmd << " >/dev/null" if $SILENT && !Gem.win_platform?
    system "***REMOVED***{Gem.ruby} -S ***REMOVED***{which('rake')} -s ***REMOVED***{cmd} >/dev/null"
  end
  
  def thor(cmd)
    cmd << " >/dev/null" if $SILENT && !Gem.win_platform?
    system "***REMOVED***{Gem.ruby} -S ***REMOVED***{which('thor')} ***REMOVED***{cmd}"
  end

  ***REMOVED*** Use the local bin/* executables if available.
  def which(executable)
    if File.executable?(exec = File.join(Dir.pwd, 'bin', executable))
      exec
    else
      executable
    end
  end
  
  ***REMOVED*** Partition gems into system, local and missing gems
  def partition_dependencies(dependencies, gem_dir)
    system_specs, local_specs, missing_deps = [], [], []
    if gem_dir && File.directory?(gem_dir)
      gem_dir = File.expand_path(gem_dir)
      ::Gem.clear_paths; ::Gem.path.unshift(gem_dir)
      ::Gem.source_index.refresh!
      dependencies.each do |dep|
        gemspecs = ::Gem.source_index.search(dep)
        local = gemspecs.reverse.find { |s| s.loaded_from.index(gem_dir) == 0 }
        if local
          local_specs << local
        elsif gemspecs.last
          system_specs << gemspecs.last
        else
          missing_deps << dep
        end
      end
      ::Gem.clear_paths
    else
      dependencies.each do |dep|
        gemspecs = ::Gem.source_index.search(dep)
        if gemspecs.last
          system_specs << gemspecs.last
        else
          missing_deps << dep
        end
      end
    end
    [system_specs, local_specs, missing_deps]
  end
  
  ***REMOVED*** Create a modified executable wrapper in the specified bin directory.
  def ensure_bin_wrapper_for(gem_dir, bin_dir, *gems)
    options = gems.last.is_a?(Hash) ? gems.last : {}
    options[:no_minigems] ||= []
    if bin_dir && File.directory?(bin_dir)
      gems.each do |gem|
        if gemspec_path = Dir[File.join(gem_dir, 'specifications', "***REMOVED***{gem}-*.gemspec")].last
          spec = Gem::Specification.load(gemspec_path)
          enable_minigems = !options[:no_minigems].include?(spec.name)
          spec.executables.each do |exec|
            executable = File.join(bin_dir, exec)
            message "Writing executable wrapper ***REMOVED***{executable}"
            File.open(executable, 'w', 0755) do |f|
              f.write(executable_wrapper(spec, exec, enable_minigems))
            end
          end
        end
      end
    end
  end
  
  def ensure_bin_wrapper_for_installed_gems(gemspecs, options)
    if options[:install_dir] && options[:bin_dir]
      gems = gemspecs.map { |spec| spec.name }
      ensure_bin_wrapper_for(options[:install_dir], options[:bin_dir], *gems)
    end
  end
  
  private

  def executable_wrapper(spec, bin_file_name, minigems = true)
    requirements = ['minigems', 'rubygems']
    requirements.reverse! unless minigems
    try_req, then_req = requirements
    <<-TEXT
***REMOVED***!/usr/bin/env ruby
***REMOVED***
***REMOVED*** This file was generated by Merb's GemManagement
***REMOVED***
***REMOVED*** The application '***REMOVED***{spec.name}' is installed as part of a gem, and
***REMOVED*** this file is here to facilitate running it.

begin 
  require '***REMOVED***{try_req}'
rescue LoadError 
  require '***REMOVED***{then_req}'
end

***REMOVED*** use gems dir if ../gems exists - eg. only for ./bin/***REMOVED***{bin_file_name}
if File.directory?(gems_dir = File.join(File.dirname(__FILE__), '..', 'gems'))
  $BUNDLE = true; Gem.clear_paths; Gem.path.replace([File.expand_path(gems_dir)])
  ENV["PATH"] = "\***REMOVED***{File.dirname(__FILE__)}:\***REMOVED***{gems_dir}/bin:\***REMOVED***{ENV["PATH"]}"
  if (local_gem = Dir[File.join(gems_dir, "specifications", "***REMOVED***{spec.name}-*.gemspec")].last)
    version = File.basename(local_gem)[/-([\\.\\d]+)\\.gemspec$/, 1]
  end
end

version ||= "***REMOVED***{Gem::Requirement.default}"

if ARGV.first =~ /^_(.*)_$/ and Gem::Version.correct? $1 then
  version = $1
  ARGV.shift
end

gem '***REMOVED***{spec.name}', version
load '***REMOVED***{bin_file_name}'
TEXT
  end

  def find_gem_in_cache(gem, version)
    spec = if version
      version = Gem::Requirement.new ["= ***REMOVED***{version}"] unless version.is_a?(Gem::Requirement)
      Gem.source_index.find_name(gem, version).first
    else
      Gem.source_index.find_name(gem).sort_by { |g| g.version }.last
    end
    if spec && File.exists?(gem_file = "***REMOVED***{spec.installation_path}/cache/***REMOVED***{spec.full_name}.gem")
      gem_file
    end
  end

  def update_source_index(dir)
    Gem.source_index.load_gems_in(File.join(dir, 'specifications'))
  end
    
end

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

class SourceManager
  
  include ColorfulMessages
  
  attr_accessor :source_dir
  
  def initialize(source_dir)
    self.source_dir = source_dir
  end
  
  def clone(name, url)
    FileUtils.cd(source_dir) do
      raise "destination directory already exists" if File.directory?(name)
      system("git clone --depth 1 ***REMOVED***{url} ***REMOVED***{name}")
    end
  rescue => e
    error "Unable to clone ***REMOVED***{name} repository (***REMOVED***{e.message})"
  end
  
  def update(name, url)
    if File.directory?(repository_dir = File.join(source_dir, name))
      FileUtils.cd(repository_dir) do
        repos = existing_repos(name)
        fork_name = url[/.com\/+?(.+)\/.+\.git/u, 1]
        if url == repos["origin"]
          ***REMOVED*** Pull from the original repository - no branching needed
          info "Pulling from origin: ***REMOVED***{url}"
          system "git fetch; git checkout master; git rebase origin/master"
        elsif repos.values.include?(url) && fork_name
          ***REMOVED*** Update and switch to a remote branch for a particular github fork
          info "Switching to remote branch: ***REMOVED***{fork_name}"
          system "git checkout -b ***REMOVED***{fork_name} ***REMOVED***{fork_name}/master"   
          system "git rebase ***REMOVED***{fork_name}/master"
        elsif fork_name
          ***REMOVED*** Create a new remote branch for a particular github fork
          info "Adding a new remote branch: ***REMOVED***{fork_name}"
          system "git remote add -f ***REMOVED***{fork_name} ***REMOVED***{url}"
          system "git checkout -b ***REMOVED***{fork_name} ***REMOVED***{fork_name}/master"
        else
          warning "No valid repository found for: ***REMOVED***{name}"
        end
      end
      return true
    else
      warning "No valid repository found at: ***REMOVED***{repository_dir}"
    end
  rescue => e
    error "Unable to update ***REMOVED***{name} repository (***REMOVED***{e.message})"
    return false
  end
  
  def existing_repos(name)
    repos = []
    FileUtils.cd(File.join(source_dir, name)) do
      repos = %x[git remote -v].split("\n").map { |branch| branch.split(/\s+/) }
    end
    Hash[*repos.flatten]
  end
  
end

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

module MerbThorHelper
  
  attr_accessor :force_gem_dir
  
  def self.included(base)
    base.send(:include, ColorfulMessages)
    base.extend ColorfulMessages
  end
  
  def use_edge_gem_server
    ::Gem.sources << 'http://edge.merbivore.com'
  end
  
  def source_manager
    @_source_manager ||= SourceManager.new(source_dir)
  end
  
  def extract_repositories(names)
    repos = []
    names.each do |name|
      if repo_url = Merb::Source.repo(name, options[:sources])
        ***REMOVED*** A repository entry for this dependency exists
        repo = [name, repo_url]
        repos << repo unless repos.include?(repo) 
      elsif (repo_name = Merb::Stack.lookup_repository_name(name)) &&
        (repo_url = Merb::Source.repo(repo_name, options[:sources]))
        ***REMOVED*** A parent repository entry for this dependency exists
        repo = [repo_name, repo_url]
        unless repos.include?(repo)
          puts "Found ***REMOVED***{repo_name}/***REMOVED***{name} at ***REMOVED***{repo_url}"
          repos << repo 
        end
      end
    end
    repos
  end
  
  def update_dependency_repositories(dependencies)
    repos = extract_repositories(dependencies.map { |d| d.name })
    update_repositories(repos)
  end
  
  def update_repositories(repos)
    repos.each do |(name, url)|
      if File.directory?(repository_dir = File.join(source_dir, name))
        message "Updating or branching ***REMOVED***{name}..."
        source_manager.update(name, url)
      else
        message "Cloning ***REMOVED***{name} repository from ***REMOVED***{url}..."
        source_manager.clone(name, url)
      end
    end
  end
  
  def install_dependency(dependency, opts = {})
    version = dependency.version_requirements.to_s
    install_opts = default_install_options.merge(:version => version)
    Merb::Gem.install(dependency.name, install_opts.merge(opts))
  end

  def install_dependency_from_source(dependency, opts = {})
    matches = Dir[File.join(source_dir, "**", dependency.name, "{Rakefile,Thorfile}")]
    matches.reject! { |m| File.basename(m) == 'Thorfile' }
    if matches.length == 1 && matches[0]
      if File.directory?(gem_src_dir = File.dirname(matches[0]))
        begin
          Merb::Gem.install_gem_from_source(gem_src_dir, default_install_options.merge(opts))
          puts "Installed ***REMOVED***{dependency.name}"
          return true
        rescue => e
          warning "Unable to install ***REMOVED***{dependency.name} from source (***REMOVED***{e.message})"
        end
      else
        msg = "Unknown directory: ***REMOVED***{gem_src_dir}"
        warning "Unable to install ***REMOVED***{dependency.name} from source (***REMOVED***{msg})"
      end
    elsif matches.length > 1
      error "Ambigous source(s) for dependency: ***REMOVED***{dependency.name}"
      matches.each { |m| puts "- ***REMOVED***{m}" }
    end
    return false
  end
  
  def clobber_dependencies!
    if options[:force] && gem_dir && File.directory?(gem_dir)
      ***REMOVED*** Remove all existing local gems by clearing the gems directory
      if dry_run?
        note 'Clearing existing local gems...'
      else
        message 'Clearing existing local gems...'
        FileUtils.rm_rf(gem_dir) && FileUtils.mkdir_p(default_gem_dir)
      end
    elsif !local.empty? 
      ***REMOVED*** Uninstall all local versions of the gems to install
      if dry_run?
        note 'Uninstalling existing local gems:'
        local.each { |gemspec| note "Uninstalled ***REMOVED***{gemspec.name}" }
      else
        message 'Uninstalling existing local gems:' if local.size > 1
        local.each do |gemspec|
          Merb::Gem.uninstall(gemspec.name, default_uninstall_options)
        end
      end
    end
  end
    
  def display_gemspecs(gemspecs)
    if gemspecs.empty?
      puts "- none"
    else
      gemspecs.each do |spec| 
        if hint = Dir[File.join(spec.full_gem_path, '*.strategy')][0]
          strategy = File.basename(hint, '.strategy')
          puts "- ***REMOVED***{spec.full_name} (***REMOVED***{strategy})"
        else
          puts "~ ***REMOVED***{spec.full_name}" ***REMOVED*** unknown strategy
        end
      end
    end
  end
  
  def display_dependencies(dependencies)
    if dependencies.empty?
      puts "- none"
    else
      dependencies.each { |d| puts "- ***REMOVED***{d.name} (***REMOVED***{d.version_requirements})" }
    end
  end
  
  def default_install_options
    { :install_dir => gem_dir, :bin_dir => bin_dir, :ignore_dependencies => ignore_dependencies? }
  end
  
  def default_uninstall_options
    { :install_dir => gem_dir, :bin_dir => bin_dir, :ignore => true, :all => true, :executables => true }
  end
  
  def dry_run?
    options[:"dry-run"]
  end
  
  def ignore_dependencies?
    options[:"ignore-dependencies"]
  end
  
  ***REMOVED*** The current working directory, or Merb app root (--merb-root option).
  def working_dir
    @_working_dir ||= File.expand_path(options['merb-root'] || Dir.pwd)
  end
  
  ***REMOVED*** We should have a ./src dir for local and system-wide management.
  def source_dir
    @_source_dir  ||= File.join(working_dir, 'src')
    create_if_missing(@_source_dir)
    @_source_dir
  end
    
  ***REMOVED*** If a local ./gems dir is found, return it.
  def gem_dir
    return force_gem_dir if force_gem_dir
    if File.directory?(dir = default_gem_dir)
      dir
    end
  end
  
  def default_gem_dir
    File.join(working_dir, 'gems')
  end
  
  ***REMOVED*** If we're in a Merb app, we can have a ./bin directory;
  ***REMOVED*** create it if it's not there.
  def bin_dir
    @_bin_dir ||= begin
      if gem_dir
        dir = File.join(working_dir, 'bin')
        create_if_missing(dir)
        dir
      end
    end
  end
  
  ***REMOVED*** Helper to create dir unless it exists.
  def create_if_missing(path)
    FileUtils.mkdir(path) unless File.exists?(path)
  end
  
  def sudo
    ENV['THOR_SUDO'] ||= "sudo"
    sudo = Gem.win_platform? ? "" : ENV['THOR_SUDO']
  end
    
  def local_gemspecs(directory = gem_dir)
    if File.directory?(specs_dir = File.join(directory, 'specifications'))
      Dir[File.join(specs_dir, '*.gemspec')].map do |gemspec_path|
        gemspec = Gem::Specification.load(gemspec_path)
        gemspec.loaded_from = gemspec_path
        gemspec
      end
    else
      []
    end
  end
  
end

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

$SILENT = true ***REMOVED*** don't output all the mess some rake package tasks spit out

module Merb
  
  class Gem < Thor
    
    include MerbThorHelper
    extend GemManagement
    
    attr_accessor :system, :local, :missing
    
    global_method_options = {
      "--merb-root"            => :optional,  ***REMOVED*** the directory to operate on
      "--version"              => :optional,  ***REMOVED*** gather specific version of gem
      "--ignore-dependencies"  => :boolean    ***REMOVED*** don't install sub-dependencies
    }
    
    method_options global_method_options
    def initialize(*args); super; end
    
    ***REMOVED*** List gems that match the specified criteria.
    ***REMOVED***
    ***REMOVED*** By default all local gems are listed. When the first argument is 'all' the
    ***REMOVED*** list is partitioned into system an local gems; specify 'system' to show
    ***REMOVED*** only system gems. A second argument can be used to filter on a set of known
    ***REMOVED*** components, like all merb-more gems for example.
    ***REMOVED*** 
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:gem:list                                    ***REMOVED*** list all local gems - the default
    ***REMOVED*** merb:gem:list all                                ***REMOVED*** list system and local gems
    ***REMOVED*** merb:gem:list system                             ***REMOVED*** list only system gems
    ***REMOVED*** merb:gem:list all merb-more                      ***REMOVED*** list only merb-more related gems
    ***REMOVED*** merb:gem:list --version 0.9.8                    ***REMOVED*** list gems that match the version    
       
    desc 'list [all|local|system] [comp]', 'Show installed gems'
    def list(filter = 'local', comp = nil)
      deps = comp ? Merb::Stack.select_component_dependencies(dependencies, comp) : dependencies
      self.system, self.local, self.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      case filter
      when 'all'
        message 'Installed system gems:'
        display_gemspecs(system)
        message 'Installed local gems:'
        display_gemspecs(local)
      when 'system'
        message 'Installed system gems:'
        display_gemspecs(system)
      when 'local'
        message 'Installed local gems:'
        display_gemspecs(local)
      else
        warning "Invalid listing filter '***REMOVED***{filter}'"
      end
    end
    
    ***REMOVED*** Install the specified gems.
    ***REMOVED***
    ***REMOVED*** All arguments should be names of gems to install.
    ***REMOVED***
    ***REMOVED*** When :force => true then any existing versions of the gems to be installed
    ***REMOVED*** will be uninstalled first. It's important to note that so-called meta-gems
    ***REMOVED*** or gems that exactly match a set of Merb::Stack.components will have their
    ***REMOVED*** sub-gems uninstalled too. For example, uninstalling merb-more will install
    ***REMOVED*** all contained gems: merb-action-args, merb-assets, merb-gen, ...
    ***REMOVED*** 
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:gem:install merb-core merb-slices          ***REMOVED*** install all specified gems
    ***REMOVED*** merb:gem:install merb-core --version 0.9.8      ***REMOVED*** install a specific version of a gem
    ***REMOVED*** merb:gem:install merb-core --force              ***REMOVED*** uninstall then subsequently install the gem
    ***REMOVED*** merb:gem:install merb-core --cache              ***REMOVED*** try to install locally from system gems
    ***REMOVED*** merb:gem:install merb --merb-edge               ***REMOVED*** install from edge.merbivore.com
     
    desc 'install GEM_NAME [GEM_NAME, ...]', 'Install a gem from rubygems'
    method_options "--cache"        => :boolean,
                   "--dry-run"      => :boolean,
                   "--force"        => :boolean,
                   "--merb-edge"    => :boolean
    def install(*names)
      opts = { :version => options[:version], :cache => options[:cache] }
      use_edge_gem_server if options[:"merb-edge"]
      current_gem = nil
      
      ***REMOVED*** uninstall existing gems of the ones we're going to install
      uninstall(*names) if options[:force]
      
      message "Installing ***REMOVED***{names.length} ***REMOVED***{names.length == 1 ? 'gem' : 'gems'}..."
      puts "This may take a while..."
      
      names.each do |gem_name|
        current_gem = gem_name      
        if dry_run?
          note "Installing ***REMOVED***{current_gem}..."
        else
          message "Installing ***REMOVED***{current_gem}..."
          self.class.install(gem_name, default_install_options.merge(opts))
        end
      end
    rescue => e
      error "Failed to install ***REMOVED***{current_gem ? current_gem : 'gem'} (***REMOVED***{e.message})"
    end
    
    ***REMOVED*** Uninstall the specified gems.
    ***REMOVED***
    ***REMOVED*** By default all specified gems are uninstalled. It's important to note that 
    ***REMOVED*** so-called meta-gems or gems that match a set of Merb::Stack.components will 
    ***REMOVED*** have their sub-gems uninstalled too. For example, uninstalling merb-more 
    ***REMOVED*** will install all contained gems: merb-action-args, merb-assets, ...
    ***REMOVED***
    ***REMOVED*** Existing dependencies will be clobbered; when :force => true then all gems
    ***REMOVED*** will be cleared, otherwise only existing local dependencies of the
    ***REMOVED*** matching component set will be removed.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:gem:uninstall merb-core merb-slices        ***REMOVED*** uninstall all specified gems
    ***REMOVED*** merb:gem:uninstall merb-core --version 0.9.8    ***REMOVED*** uninstall a specific version of a gem
    
    desc 'uninstall GEM_NAME [GEM_NAME, ...]', 'Unstall a gem'
    method_options "--dry-run" => :boolean
    def uninstall(*names)
      opts = { :version => options[:version] }
      current_gem = nil
      if dry_run?
        note "Uninstalling any existing gems of: ***REMOVED***{names.join(', ')}"
      else
        message "Uninstalling any existing gems of: ***REMOVED***{names.join(', ')}"
        names.each do |gem_name|
          current_gem = gem_name
          Merb::Gem.uninstall(gem_name, default_uninstall_options) rescue nil
          ***REMOVED*** if this gem is a meta-gem or a component set name, remove sub-gems
          (Merb::Stack.components(gem_name) || []).each do |comp|
            Merb::Gem.uninstall(comp, default_uninstall_options) rescue nil
          end
        end
      end 
    rescue => e
      error "Failed to uninstall ***REMOVED***{current_gem ? current_gem : 'gem'} (***REMOVED***{e.message})"
    end
    
    ***REMOVED*** Recreate all gems from gems/cache on the current platform.
    ***REMOVED***
    ***REMOVED*** This task should be executed as part of a deployment setup, where the 
    ***REMOVED*** deployment system runs this after the app has been installed.
    ***REMOVED*** Usually triggered by Capistrano, God...
    ***REMOVED***
    ***REMOVED*** It will regenerate gems from the bundled gems cache for any gem that has 
    ***REMOVED*** C extensions - which need to be recompiled for the target deployment platform.
    ***REMOVED***
    ***REMOVED*** Note: at least gems/cache and gems/specifications should be in your SCM.
    
    desc 'redeploy', 'Recreate all gems on the current platform'
    method_options "--dry-run" => :boolean, "--force" => :boolean
    def redeploy
      require 'tempfile' ***REMOVED*** for Dir::tmpdir access
      if gem_dir && File.directory?(cache_dir = File.join(gem_dir, 'cache'))
        specs = local_gemspecs
        message "Recreating ***REMOVED***{specs.length} gems from cache..."
        puts "This may take a while..."
        specs.each do |gemspec|
          if File.exists?(gem_file = File.join(cache_dir, "***REMOVED***{gemspec.full_name}.gem"))
            gem_file_copy = File.join(Dir::tmpdir, File.basename(gem_file))
            if dry_run?
              note "Recreating ***REMOVED***{gemspec.full_name}"
            else
              message "Recreating ***REMOVED***{gemspec.full_name}"       
              if options[:force] && File.directory?(gem = File.join(gem_dir, 'gems', gemspec.full_name))
                puts "Removing existing ***REMOVED***{gemspec.full_name}"
                FileUtils.rm_rf(gem) 
              end              
              ***REMOVED*** Copy the gem to a temporary file, because otherwise RubyGems/FileUtils
              ***REMOVED*** will complain about copying identical files (same source/destination).
              FileUtils.cp(gem_file, gem_file_copy)
              Merb::Gem.install(gem_file_copy, :install_dir => gem_dir, :ignore_dependencies => true)
              File.delete(gem_file_copy)
            end
          end
        end
      else
        error "No application local gems directory found"
      end
    end
    
    private
    
    ***REMOVED*** Return dependencies for all installed gems; both system-wide and locally;
    ***REMOVED*** optionally filters on :version requirement.
    def dependencies
      version_req = if options[:version]
        ::Gem::Requirement.create(options[:version])
      else
        ::Gem::Requirement.default
      end
      if gem_dir
        ::Gem.clear_paths; ::Gem.path.unshift(gem_dir)
        ::Gem.source_index.refresh!
      end
      deps = []
      ::Gem.source_index.each do |fullname, gemspec| 
        if version_req.satisfied_by?(gemspec.version)
          deps << ::Gem::Dependency.new(gemspec.name, "= ***REMOVED***{gemspec.version}")
        end
      end
      ::Gem.clear_paths if gem_dir
      deps.sort
    end
    
    public
    
    ***REMOVED*** Install gem with some default options.
    def self.install(name, options = {})
      defaults = {}
      defaults[:cache] = false unless opts[:install_dir]
      install_gem(name, defaults.merge(options))
    end
    
    ***REMOVED*** Uninstall gem with some default options.
    def self.uninstall(name, options = {})
      defaults = { :ignore => true, :executables => true }
      uninstall_gem(name, defaults.merge(options))
    end
    
  end
  
  class Tasks < Thor
    
    include MerbThorHelper
    
    ***REMOVED*** Show merb.thor version information
    ***REMOVED***
    ***REMOVED*** merb:tasks:version                                        ***REMOVED*** show the current version info
    ***REMOVED*** merb:tasks:version --info                                 ***REMOVED*** show extended version info
    
    desc 'version', 'Show verion info'
    method_options "--info" => :boolean
    def version
      message "Currently installed merb.thor version: ***REMOVED***{MERB_THOR_VERSION}"
      if options[:version]
        self.options = { :"dry-run" => true }
        self.update ***REMOVED*** run update task with dry-run enabled
      end
    end
    
    ***REMOVED*** Update merb.thor tasks from remotely available version
    ***REMOVED***
    ***REMOVED*** merb:tasks:update                                        ***REMOVED*** update merb.thor
    ***REMOVED*** merb:tasks:update --force                                ***REMOVED*** force-update merb.thor
    ***REMOVED*** merb:tasks:update --dry-run                              ***REMOVED*** show version info only
    
    desc 'update [URL]', 'Fetch the latest merb.thor and install it locally'
    method_options "--dry-run" => :boolean, "--force" => :boolean
    def update(url = 'http://merbivore.com/merb.thor')
      require 'open-uri'
      require 'rubygems/version'
      remote_file = open(url)
      code = remote_file.read
      
      ***REMOVED*** Extract version information from the source code
      if version = code[/^MERB_THOR_VERSION\s?=\s?('|")([\.\d]+)('|")/,2]
        ***REMOVED*** borrow version comparison from rubygems' Version class
        current_version = ::Gem::Version.new(MERB_THOR_VERSION)
        remote_version  = ::Gem::Version.new(version)
        
        if current_version >= remote_version
          puts "currently installed: ***REMOVED***{current_version}"
          if current_version != remote_version
            puts "available version:   ***REMOVED***{remote_version}"
          end
          info "No update of merb.thor necessary***REMOVED***{options[:force] ? ' (forced)' : ''}"
          proceed = options[:force]
        elsif current_version < remote_version
          puts "currently installed: ***REMOVED***{current_version}"
          puts "available version:   ***REMOVED***{remote_version}"
          proceed = true
        end
          
        if proceed && !dry_run?
          File.open(File.join(__FILE__), 'w') do |f|
            f.write(code)
          end
          success "Installed the latest merb.thor (v***REMOVED***{version})"
        end
      else
        raise "invalid source-code data"
      end      
    rescue OpenURI::HTTPError
      error "Error opening ***REMOVED***{url}"
    rescue => e
      error "An error occurred (***REMOVED***{e.message})"
    end
    
  end
  
  ***REMOVED******REMOVED******REMOVED******REMOVED*** MORE LOW-LEVEL TASKS ***REMOVED******REMOVED******REMOVED******REMOVED***
  
  class Source < Thor
    
    group 'core'
        
    include MerbThorHelper
    extend GemManagement
    
    attr_accessor :system, :local, :missing
    
    global_method_options = {
      "--merb-root"            => :optional,  ***REMOVED*** the directory to operate on
      "--ignore-dependencies"  => :boolean,   ***REMOVED*** don't install sub-dependencies
      "--sources"              => :optional   ***REMOVED*** a yml config to grab sources from
    }
    
    method_options global_method_options
    def initialize(*args); super; end
        
    ***REMOVED*** List source repositories, of either local or known sources.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:source:list                                   ***REMOVED*** list all local sources
    ***REMOVED*** merb:source:list available                         ***REMOVED*** list all known sources
    
    desc 'list [local|available]', 'Show git source repositories'
    def list(mode = 'local')
      if mode == 'available'
        message 'Available source repositories:'
        repos = self.class.repos(options[:sources])
        repos.keys.sort.each { |name| puts "- ***REMOVED***{name}: ***REMOVED***{repos[name]}" }
      elsif mode == 'local'
        message 'Current source repositories:'
        Dir[File.join(source_dir, '*')].each do |src|
          next unless File.directory?(src)
          src_name = File.basename(src)
          unless (repos = source_manager.existing_repos(src_name)).empty?
            puts "***REMOVED***{src_name}"
            repos.keys.sort.each { |b| puts "- ***REMOVED***{b}: ***REMOVED***{repos[b]}" }
          end
        end
      else
        error "Unknown listing: ***REMOVED***{mode}"
      end
    end

    ***REMOVED*** Install the specified gems.
    ***REMOVED***
    ***REMOVED*** All arguments should be names of gems to install.
    ***REMOVED***
    ***REMOVED*** When :force => true then any existing versions of the gems to be installed
    ***REMOVED*** will be uninstalled first. It's important to note that so-called meta-gems
    ***REMOVED*** or gems that exactly match a set of Merb::Stack.components will have their
    ***REMOVED*** sub-gems uninstalled too. For example, uninstalling merb-more will install
    ***REMOVED*** all contained gems: merb-action-args, merb-assets, merb-gen, ...
    ***REMOVED*** 
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:source:install merb-core merb-slices          ***REMOVED*** install all specified gems
    ***REMOVED*** merb:source:install merb-core --force              ***REMOVED*** uninstall then subsequently install the gem
    ***REMOVED*** merb:source:install merb-core --wipe               ***REMOVED*** clear repo then install the gem

    desc 'install GEM_NAME [GEM_NAME, ...]', 'Install a gem from git source/edge'
    method_options "--dry-run"      => :boolean,
                   "--force"        => :boolean,
                   "--wipe"         => :boolean
    def install(*names)
      use_edge_gem_server
      ***REMOVED*** uninstall existing gems of the ones we're going to install
      uninstall(*names) if options[:force] || options[:wipe]
      
      ***REMOVED*** We want dependencies instead of just names
      deps = names.map { |n| ::Gem::Dependency.new(n, ::Gem::Requirement.default) }
      
      ***REMOVED*** Selectively update repositories for the matching dependencies
      update_dependency_repositories(deps) unless dry_run?
      
      current_gem = nil
      deps.each do |dependency|
        current_gem = dependency.name      
        if dry_run?
          note "Installing ***REMOVED***{current_gem} from source..."
        else
          message "Installing ***REMOVED***{current_gem} from source..."
          puts "This may take a while..."
          unless install_dependency_from_source(dependency)
            raise "gem source not found"
          end
        end
      end
    rescue => e
      error "Failed to install ***REMOVED***{current_gem ? current_gem : 'gem'} (***REMOVED***{e.message})"
    end
    
    ***REMOVED*** Uninstall the specified gems.
    ***REMOVED***
    ***REMOVED*** By default all specified gems are uninstalled. It's important to note that 
    ***REMOVED*** so-called meta-gems or gems that match a set of Merb::Stack.components will 
    ***REMOVED*** have their sub-gems uninstalled too. For example, uninstalling merb-more 
    ***REMOVED*** will install all contained gems: merb-action-args, merb-assets, ...
    ***REMOVED***
    ***REMOVED*** Existing dependencies will be clobbered; when :force => true then all gems
    ***REMOVED*** will be cleared, otherwise only existing local dependencies of the
    ***REMOVED*** matching component set will be removed. Additionally when :wipe => true, 
    ***REMOVED*** the matching git repositories will be removed from the source directory.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:source:uninstall merb-core merb-slices       ***REMOVED*** uninstall all specified gems
    ***REMOVED*** merb:source:uninstall merb-core --wipe            ***REMOVED*** force-uninstall a gem and clear repo
    
    desc 'uninstall GEM_NAME [GEM_NAME, ...]', 'Unstall a gem (specify --force to remove the repo)'
    method_options "--version" => :optional, "--dry-run" => :boolean, "--wipe" => :boolean
    def uninstall(*names)
      ***REMOVED*** Remove the repos that contain the gem
      if options[:wipe] 
        extract_repositories(names).each do |(name, url)|
          if File.directory?(src = File.join(source_dir, name))
            if dry_run?
              note "Removing ***REMOVED***{src}..."
            else
              info "Removing ***REMOVED***{src}..."
              FileUtils.rm_rf(src)
            end
          end
        end
      end
      
      ***REMOVED*** Use the Merb::Gem***REMOVED***uninstall task to handle this
      gem_tasks = Merb::Gem.new
      gem_tasks.options = options
      gem_tasks.uninstall(*names)
    end
    
    ***REMOVED*** Update the specified source repositories.
    ***REMOVED***
    ***REMOVED*** The arguments can be actual repository names (from Merb::Source.repos)
    ***REMOVED*** or names of known merb stack gems. If the repo doesn't exist already,
    ***REMOVED*** it will be created and cloned.
    ***REMOVED***
    ***REMOVED*** merb:source:pull merb-core                         ***REMOVED*** update source of specified gem
    ***REMOVED*** merb:source:pull merb-slices                       ***REMOVED*** implicitly updates merb-more
    
    desc 'pull REPO_NAME [GEM_NAME, ...]', 'Update git source repository from edge'
    def pull(*names)
      repos = extract_repositories(names)
      update_repositories(repos)
      unless repos.empty?
        message "Updated the following repositories:"
        repos.each { |name, url| puts "- ***REMOVED***{name}: ***REMOVED***{url}" }
      else
        warning "No repositories found to update!"
      end
    end    
    
    ***REMOVED*** Clone a git repository into ./src. 
    
    ***REMOVED*** The repository can be a direct git url or a known -named- repository.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:source:clone merb-core 
    ***REMOVED*** merb:source:clone dm-core awesome-repo
    ***REMOVED*** merb:source:clone dm-core --sources ./path/to/sources.yml
    ***REMOVED*** merb:source:clone git://github.com/sam/dm-core.git
    
    desc 'clone (REPO_NAME|URL) [DIR_NAME]', 'Clone git source repository by name or url'
    def clone(repository, name = nil)
      if repository =~ /^git:\/\//
        repository_url  = repository
        repository_name = File.basename(repository_url, '.git')
      elsif url = Merb::Source.repo(repository, options[:sources])
        repository_url = url
        repository_name = repository
      end
      source_manager.clone(name || repository_name, repository_url)
    end
    
    ***REMOVED*** Git repository sources - pass source_config option to load a yaml 
    ***REMOVED*** configuration file - defaults to ./config/git-sources.yml and
    ***REMOVED*** ~/.merb/git-sources.yml - which you need to create yourself. 
    ***REMOVED***
    ***REMOVED*** Example of contents:
    ***REMOVED***
    ***REMOVED*** merb-core: git://github.com/myfork/merb-core.git
    ***REMOVED*** merb-more: git://github.com/myfork/merb-more.git
    
    def self.repos(source_config = nil)
      source_config ||= begin
        local_config = File.join(Dir.pwd, 'config', 'git-sources.yml')
        user_config  = File.join(ENV["HOME"] || ENV["APPDATA"], '.merb', 'git-sources.yml')
        File.exists?(local_config) ? local_config : user_config
      end
      if source_config && File.exists?(source_config)
        default_repos.merge(YAML.load(File.read(source_config)))
      else
        default_repos
      end
    end
    
    def self.repo(name, source_config = nil)
      self.repos(source_config)[name]
    end
    
    ***REMOVED*** Default Git repositories
    def self.default_repos
      @_default_repos ||= { 
        'merb'          => "git://github.com/wycats/merb.git",
        'merb-plugins'  => "git://github.com/wycats/merb-plugins.git",
        'extlib'        => "git://github.com/sam/extlib.git",
        'dm-core'       => "git://github.com/sam/dm-core.git",
        'dm-more'       => "git://github.com/sam/dm-more.git",
        'sequel'        => "git://github.com/wayneeseguin/sequel.git",
        'do'            => "git://github.com/sam/do.git",
        'thor'          => "git://github.com/wycats/thor.git",
        'rake'          => "git://github.com/jimweirich/rake.git"
      }
    end
       
  end
  
  class Dependencies < Thor
  
    group 'core'
    
    ***REMOVED*** The Dependencies tasks will install dependencies based on actual application
    ***REMOVED*** dependencies. For this, the application is queried for any dependencies.
    ***REMOVED*** All operations will be performed within this context.
    
    attr_accessor :system, :local, :missing, :extract_dependencies
    
    include MerbThorHelper
    
    global_method_options = {
      "--merb-root"            => :optional,  ***REMOVED*** the directory to operate on
      "--ignore-dependencies"  => :boolean,   ***REMOVED*** ignore sub-dependencies
      "--stack"                => :boolean,   ***REMOVED*** gather only stack dependencies
      "--no-stack"             => :boolean,   ***REMOVED*** gather only non-stack dependencies
      "--extract"              => :boolean,   ***REMOVED*** gather dependencies from the app itself
      "--config-file"          => :optional,  ***REMOVED*** gather from the specified yaml config
      "--version"              => :optional   ***REMOVED*** gather specific version of framework
    }
    
    method_options global_method_options
    def initialize(*args); super; end
    
    ***REMOVED*** List application dependencies.
    ***REMOVED***
    ***REMOVED*** By default all dependencies are listed, partitioned into system, local and
    ***REMOVED*** currently missing dependencies. The first argument allows you to filter
    ***REMOVED*** on any of the partitionings. A second argument can be used to filter on
    ***REMOVED*** a set of known components, like all merb-more gems for example.
    ***REMOVED*** 
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:dependencies:list                                    ***REMOVED*** list all dependencies - the default
    ***REMOVED*** merb:dependencies:list local                              ***REMOVED*** list only local gems
    ***REMOVED*** merb:dependencies:list all merb-more                      ***REMOVED*** list only merb-more related dependencies
    ***REMOVED*** merb:dependencies:list --stack                            ***REMOVED*** list framework dependencies
    ***REMOVED*** merb:dependencies:list --no-stack                         ***REMOVED*** list 3rd party dependencies
    ***REMOVED*** merb:dependencies:list --extract                          ***REMOVED*** list dependencies by extracting them
    ***REMOVED*** merb:dependencies:list --config-file file.yml             ***REMOVED*** list from the specified config file
       
    desc 'list [all|local|system|missing] [comp]', 'Show application dependencies'
    def list(filter = 'all', comp = nil)
      deps = comp ? Merb::Stack.select_component_dependencies(dependencies, comp) : dependencies
      self.system, self.local, self.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      case filter
      when 'all'
        message 'Installed system gem dependencies:' 
        display_gemspecs(system)
        message 'Installed local gem dependencies:'
        display_gemspecs(local)
        unless missing.empty?
          error 'Missing gem dependencies:'
          display_dependencies(missing)
        end
      when 'system'
        message 'Installed system gem dependencies:'
        display_gemspecs(system)
      when 'local'
        message 'Installed local gem dependencies:'
        display_gemspecs(local)
      when 'missing'
        error 'Missing gem dependencies:'
        display_dependencies(missing)
      else
        warning "Invalid listing filter '***REMOVED***{filter}'"
      end
      if missing.size > 0
        info "Some dependencies are currently missing!"
      elsif local.size == deps.size
        info "All dependencies have been bundled with the application."
      elsif local.size > system.size
        info "Most dependencies have been bundled with the application."
      elsif system.size > 0 && local.size > 0
        info "Some dependencies have been bundled with the application."  
      elsif local.empty? && system.size == deps.size
        info "All dependencies are available on the system."
      end
    end
    
    ***REMOVED*** Install application dependencies.
    ***REMOVED***
    ***REMOVED*** By default all required dependencies are installed. The first argument 
    ***REMOVED*** specifies which strategy to use: stable or edge. A second argument can be 
    ***REMOVED*** used to filter on a set of known components.
    ***REMOVED***
    ***REMOVED*** Existing dependencies will be clobbered; when :force => true then all gems
    ***REMOVED*** will be cleared first, otherwise only existing local dependencies of the
    ***REMOVED*** gems to be installed will be removed.
    ***REMOVED*** 
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:dependencies:install                                 ***REMOVED*** install all dependencies using stable strategy
    ***REMOVED*** merb:dependencies:install stable --version 0.9.8          ***REMOVED*** install a specific version of the framework
    ***REMOVED*** merb:dependencies:install stable missing                  ***REMOVED*** install currently missing gems locally
    ***REMOVED*** merb:dependencies:install stable merb-more                ***REMOVED*** install only merb-more related dependencies
    ***REMOVED*** merb:dependencies:install stable --stack                  ***REMOVED*** install framework dependencies
    ***REMOVED*** merb:dependencies:install stable --no-stack               ***REMOVED*** install 3rd party dependencies
    ***REMOVED*** merb:dependencies:install stable --extract                ***REMOVED*** extract dependencies from the actual app
    ***REMOVED*** merb:dependencies:install stable --config-file file.yml   ***REMOVED*** read from the specified config file
    ***REMOVED***
    ***REMOVED*** In addition to the options above, edge install uses the following: 
    ***REMOVED***
    ***REMOVED*** merb:dependencies:install edge                            ***REMOVED*** install all dependencies using edge strategy
    ***REMOVED*** merb:dependencies:install edge --sources file.yml         ***REMOVED*** install edge from the specified git sources config
    
    desc 'install [stable|edge] [comp]', 'Install application dependencies'
    method_options "--sources" => :optional, ***REMOVED*** only for edge strategy
                   "--local"   => :boolean,  ***REMOVED*** force local install
                   "--dry-run" => :boolean, 
                   "--force"   => :boolean                   
    def install(strategy = 'stable', comp = nil)
      if strategy?(strategy)
        ***REMOVED*** Force local dependencies by creating ./gems before proceeding
        create_if_missing(default_gem_dir) if options[:local]
        
        where = gem_dir ? 'locally' : 'system-wide'
        
        ***REMOVED*** When comp == 'missing' then filter on missing dependencies
        if only_missing = comp == 'missing'
          message "Preparing to install missing gems ***REMOVED***{where} using ***REMOVED***{strategy} strategy..."
          comp = nil
          clobber = false
        else
          message "Preparing to install ***REMOVED***{where} using ***REMOVED***{strategy} strategy..."
          clobber = true
        end
        
        ***REMOVED*** If comp given, filter on known stack components
        deps = comp ? Merb::Stack.select_component_dependencies(dependencies, comp) : dependencies
        self.system, self.local, self.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
        
        ***REMOVED*** Only install currently missing gems (for comp == missing)
        if only_missing
          deps.reject! { |dep| not missing.include?(dep) }
        end
        
        if deps.empty?
          warning "No dependencies to install..."
        else
          puts "***REMOVED***{deps.length} dependencies to install..."
          puts "This may take a while..."
          install_dependencies(strategy, deps, clobber)
        end
        
        ***REMOVED*** Show current dependency info now that we're done
        puts ***REMOVED*** Seperate output
        list('local', comp)
      else
        warning "Invalid install strategy '***REMOVED***{strategy}'"
        puts
        message "Please choose one of the following installation strategies: stable or edge:"
        puts "$ thor merb:dependencies:install stable"
        puts "$ thor merb:dependencies:install edge"
      end      
    end
    
    ***REMOVED*** Uninstall application dependencies.
    ***REMOVED***
    ***REMOVED*** By default all required dependencies are installed. An optional argument 
    ***REMOVED*** can be used to filter on a set of known components.
    ***REMOVED***
    ***REMOVED*** Existing dependencies will be clobbered; when :force => true then all gems
    ***REMOVED*** will be cleared, otherwise only existing local dependencies of the
    ***REMOVED*** matching component set will be removed.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:dependencies:uninstall                               ***REMOVED*** uninstall all dependencies - the default
    ***REMOVED*** merb:dependencies:uninstall merb-more                     ***REMOVED*** uninstall merb-more related gems locally
    
    desc 'uninstall [comp]', 'Uninstall application dependencies'
    method_options "--dry-run" => :boolean, "--force" => :boolean
    def uninstall(comp = nil)
      ***REMOVED*** If comp given, filter on known stack components
      deps = comp ? Merb::Stack.select_component_dependencies(dependencies, comp) : dependencies
      self.system, self.local, self.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      ***REMOVED*** Clobber existing local dependencies - based on self.local
      clobber_dependencies!
    end
    
    ***REMOVED*** Recreate all gems from gems/cache on the current platform.
    ***REMOVED***
    ***REMOVED*** Note: use merb:gem:redeploy instead
    
    desc 'redeploy', 'Recreate all gems on the current platform'
    method_options "--dry-run" => :boolean, "--force" => :boolean
    def redeploy
      warning 'Warning: merb:dependencies:redeploy has been deprecated - use merb:gem:redeploy instead'
      gem = Merb::Gem.new
      gem.options = options
      gem.redeploy
    end
    
    ***REMOVED*** Create a dependencies configuration file.
    ***REMOVED***
    ***REMOVED*** A configuration yaml file will be created from the extracted application
    ***REMOVED*** dependencies. The format of the configuration is as follows:
    ***REMOVED***
    ***REMOVED*** --- 
    ***REMOVED*** - merb-core (= 0.9.8, runtime)
    ***REMOVED*** - merb-slices (= 0.9.8, runtime)
    ***REMOVED*** 
    ***REMOVED*** This format is exactly the same as Gem::Dependency***REMOVED***to_s returns.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:dependencies:configure --force                       ***REMOVED*** overwrite the default config file
    ***REMOVED*** merb:dependencies:configure --version 0.9.8               ***REMOVED*** configure specific framework version
    ***REMOVED*** merb:dependencies:configure --config-file file.yml        ***REMOVED*** write to the specified config file 
    
    desc 'configure [comp]', 'Create a dependencies config file'
    method_options "--dry-run" => :boolean, "--force" => :boolean, "--versions" => :boolean
    def configure(comp = nil)
      self.extract_dependencies = true ***REMOVED*** of course we need to consult the app itself
      ***REMOVED*** If comp given, filter on known stack components
      deps = comp ? Merb::Stack.select_component_dependencies(dependencies, comp) : dependencies
      
      ***REMOVED*** If --versions is set, update the version_requirements with the actual version available
      if options[:versions]
        specs = local_gemspecs
        deps.each do |dep|
          if spec = specs.find { |s| s.name == dep.name }
            dep.version_requirements = ::Gem::Requirement.create(spec.version)
          end
        end
      end
      
      config = YAML.dump(deps.map { |d| d.to_s })
      puts "***REMOVED***{config}\n"
      if File.exists?(config_file) && !options[:force]
        error "File already exists! Use --force to overwrite."
      else
        if dry_run?
          note "Written ***REMOVED***{config_file}"
        else
          FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)
          File.open(config_file, 'w') { |f| f.write config }
          success "Written ***REMOVED***{config_file}"
        end
      end
    rescue  
      error "Failed to write to ***REMOVED***{config_file}"
    end 
    
    ***REMOVED******REMOVED******REMOVED*** Helper Methods
    
    def strategy?(strategy)
      if self.respond_to?(method = :"***REMOVED***{strategy}_strategy", true)
        method
      end
    end
    
    def install_dependencies(strategy, deps, clobber = true)
      if method = strategy?(strategy)
        ***REMOVED*** Clobber existing local dependencies
        clobber_dependencies! if clobber
        
        ***REMOVED*** Run the chosen strategy - collect files installed from stable gems
        installed_from_stable = send(method, deps).map { |d| d.name }

        unless dry_run?
          ***REMOVED*** Sleep a bit otherwise the following steps won't see the new files
          sleep(deps.length) if deps.length > 0 && deps.length <= 10
          
          ***REMOVED*** Leave a file to denote the strategy that has been used for this dependency
          self.local.each do |spec|
            next unless File.directory?(spec.full_gem_path)
            unless installed_from_stable.include?(spec.name)
              FileUtils.touch(File.join(spec.full_gem_path, "***REMOVED***{strategy}.strategy"))
            else
              FileUtils.touch(File.join(spec.full_gem_path, "stable.strategy"))
            end           
          end
        end
        return true
      end
      false
    end
    
    def dependencies
      if extract_dependencies?
        ***REMOVED*** Extract dependencies from the current application
        deps = Merb::Stack.core_dependencies(gem_dir, ignore_dependencies?)
        deps += Merb::Dependencies.extract_dependencies(working_dir)        
      else
        ***REMOVED*** Use preconfigured dependencies from yaml file
        deps = config_dependencies
      end
      
      stack_components = Merb::Stack.components

      if options[:stack]
        ***REMOVED*** Limit to stack components only
        deps.reject! { |dep| not stack_components.include?(dep.name) }
      elsif options[:"no-stack"]
        ***REMOVED*** Limit to non-stack components
        deps.reject! { |dep| stack_components.include?(dep.name) }
      end
      
      if options[:version]
        version_req = ::Gem::Requirement.create("= ***REMOVED***{options[:version]}")
      elsif core = deps.find { |d| d.name == 'merb-core' }
        version_req = core.version_requirements
      end
      
      if version_req
        ***REMOVED*** Handle specific version requirement for framework components
        framework_components = Merb::Stack.framework_components
        deps.each do |dep|
          if framework_components.include?(dep.name)
            dep.version_requirements = version_req
          end
        end
      end
      
      deps
    end
    
    def config_dependencies
      if File.exists?(config_file)
        self.class.parse_dependencies_yaml(File.read(config_file))
      else
        warning "No dependencies.yml file found at: ***REMOVED***{config_file}"
        []
      end
    end
    
    def extract_dependencies?
      options[:extract] || extract_dependencies
    end
    
    def config_file
      @config_file ||= begin
        options[:"config-file"] || File.join(working_dir, 'config', 'dependencies.yml')
      end
    end
    
    def config_dir
      File.dirname(config_file)
    end
    
    ***REMOVED******REMOVED******REMOVED*** Strategy handlers
    
    private
    
    def stable_strategy(deps)
      installed_from_rubygems = []
      if core = deps.find { |d| d.name == 'merb-core' }
        if dry_run?
          note "Installing ***REMOVED***{core.name}..."
        else
          if install_dependency(core)
            installed_from_rubygems << core
          else
            msg = "Try specifying a lower version of merb-core with --version"
            if version_no = core.version_requirements.to_s[/([\.\d]+)$/, 1]
              num = "%03d" % (version_no.gsub('.', '').to_i - 1)
              puts "The required version (***REMOVED***{version_no}) probably isn't available as a stable rubygem yet."
              info "***REMOVED***{msg} ***REMOVED***{num.split(//).join('.')}"
            else
              puts "The required version probably isn't available as a stable rubygem yet."
              info msg
            end           
          end
        end
      end
      
      deps.each do |dependency|
        next if dependency.name == 'merb-core'
        if dry_run?
          note "Installing ***REMOVED***{dependency.name}..."
        else
          install_dependency(dependency)
          installed_from_rubygems << dependency
        end        
      end
      installed_from_rubygems
    end
    
    def edge_strategy(deps)
      use_edge_gem_server
      installed_from_rubygems = []
      
      ***REMOVED*** Selectively update repositories for the matching dependencies
      update_dependency_repositories(deps) unless dry_run?
      
      if core = deps.find { |d| d.name == 'merb-core' }
        if dry_run?
          note "Installing ***REMOVED***{core.name}..."
        else
          if install_dependency_from_source(core)
          elsif install_dependency(core)
            info "Installed ***REMOVED***{core.name} from rubygems..."
            installed_from_rubygems << core
          end
        end
      end
      
      deps.each do |dependency|
        next if dependency.name == 'merb-core'
        if dry_run?
          note "Installing ***REMOVED***{dependency.name}..."
        else
          if install_dependency_from_source(dependency)
          elsif install_dependency(dependency)
            info "Installed ***REMOVED***{dependency.name} from rubygems..."
            installed_from_rubygems << dependency
          end
        end        
      end
      
      installed_from_rubygems
    end
    
    ***REMOVED******REMOVED******REMOVED*** Class Methods
    
    public
    
    def self.list(filter = 'all', comp = nil, options = {})
      instance = Merb::Dependencies.new
      instance.options = options
      instance.list(filter, comp)
    end
    
    ***REMOVED*** Extract application dependencies by querying the app directly.
    def self.extract_dependencies(merb_root)
      require 'merb-core'
      if !@_merb_loaded || Merb.root != merb_root
        Merb.start_environment(
          :log_level => :fatal,
          :testing => true, 
          :adapter => 'runner', 
          :environment => ENV['MERB_ENV'] || 'development', 
          :merb_root => merb_root
        )
        @_merb_loaded = true
      end
      Merb::BootLoader::Dependencies.dependencies
    rescue StandardError => e     
      error "Couldn't extract dependencies from application!"
      error e.message
      puts  "Make sure you're executing the task from your app (--merb-root)"
      return []
    rescue SystemExit      
      error "Couldn't extract dependencies from application!"
      error "application failed to run"
      puts  "Please check if your application runs using 'merb'; for example,"
      puts  "look for any gem version mismatches in dependencies.rb"
      return []
    end
        
    ***REMOVED*** Parse the basic YAML config data, and process Gem::Dependency output.
    ***REMOVED*** Formatting example: merb_helpers (>= 0.9.8, runtime)
    def self.parse_dependencies_yaml(yaml)
      dependencies = []
      entries = YAML.load(yaml) rescue []
      entries.each do |entry|
        if matches = entry.match(/^(\S+) \(([^,]+)?, ([^\)]+)\)/)
          name, version_req, type = matches.captures
          dependencies << ::Gem::Dependency.new(name, version_req, type.to_sym)
        else
          error "Invalid entry: ***REMOVED***{entry}"
        end
      end
      dependencies
    end
    
  end
  
  class Stack < Thor
    
    group 'core'
    
    ***REMOVED*** The Stack tasks will install dependencies based on known sets of gems,
    ***REMOVED*** regardless of actual application dependency settings.
    
    DM_STACK = %w[
      extlib
      data_objects
      dm-core
      dm-aggregates
      dm-migrations
      dm-timestamps
      dm-types
      dm-validations
      merb_datamapper
    ]
    
    MERB_STACK = %w[
      extlib
      merb-core
      merb-action-args
      merb-assets
      merb-cache
      merb-helpers
      merb-mailer
      merb-slices
      merb-auth
      merb-auth-core
      merb-auth-more 
      merb-auth-slice-password
      merb-param-protection
      merb-exceptions
    ] + DM_STACK
    
    MERB_BASICS = %w[
      extlib
      merb-core
      merb-action-args
      merb-assets
      merb-cache
      merb-helpers
      merb-mailer
      merb-slices
    ]
    
    ***REMOVED*** The following sets are meant for repository lookup; unlike the sets above
    ***REMOVED*** these correspond to specific git repository items.
    
    MERB_MORE = %w[
      merb-action-args
      merb-assets
      merb-auth
      merb-auth-core
      merb-auth-more 
      merb-auth-slice-password
      merb-cache
      merb-exceptions
      merb-gen
      merb-haml
      merb-helpers
      merb-mailer
      merb-param-protection
      merb-slices
      merb_datamapper
    ]
    
    MERB_PLUGINS = %w[
      merb_activerecord
      merb_builder
      merb_jquery
      merb_laszlo
      merb_parts
      merb_screw_unit
      merb_sequel
      merb_stories
      merb_test_unit
    ]
    
    DM_MORE = %w[
      dm-adjust
      dm-aggregates
      dm-ar-finders
      dm-cli
      dm-constraints
      dm-is-example
      dm-is-list
      dm-is-nested_set
      dm-is-remixable
      dm-is-searchable
      dm-is-state_machine
      dm-is-tree
      dm-is-versioned
      dm-migrations
      dm-observer
      dm-querizer
      dm-serializer
      dm-shorthand
      dm-sweatshop
      dm-tags
      dm-timestamps
      dm-types
      dm-validations
      
      dm-couchdb-adapter
      dm-ferret-adapter
      dm-rest-adapter
    ]
    
    DATA_OBJECTS = %w[
      data_objects 
      do_derby do_hsqldb 
      do_jdbc
      do_mysql
      do_postgres
      do_sqlite3
    ]
    
    attr_accessor :system, :local, :missing
    
    include MerbThorHelper
    
    global_method_options = {
      "--merb-root"            => :optional,  ***REMOVED*** the directory to operate on
      "--ignore-dependencies"  => :boolean,   ***REMOVED*** skip sub-dependencies
      "--version"              => :optional   ***REMOVED*** gather specific version of framework    
    }
    
    method_options global_method_options
    def initialize(*args); super; end
    
    ***REMOVED*** List components and their dependencies.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED*** 
    ***REMOVED*** merb:stack:list                                           ***REMOVED*** list all standard stack components
    ***REMOVED*** merb:stack:list all                                       ***REMOVED*** list all component sets
    ***REMOVED*** merb:stack:list merb-more                                 ***REMOVED*** list all dependencies of merb-more
  
    desc 'list [all|comp]', 'List available components (optionally filtered, defaults to merb stack)'
    def list(comp = 'stack')
      if comp == 'all'
        Merb::Stack.component_sets.keys.sort.each do |comp|
          unless (components = Merb::Stack.component_sets[comp]).empty?
            message "Dependencies for '***REMOVED***{comp}' set:"
            components.each { |c| puts "- ***REMOVED***{c}" }
          end
        end
      else
        message "Dependencies for '***REMOVED***{comp}' set:"
        Merb::Stack.components(comp).each { |c| puts "- ***REMOVED***{c}" }
      end      
    end
    
    ***REMOVED*** Install stack components or individual gems - from stable rubygems by default.
    ***REMOVED***
    ***REMOVED*** See also: Merb::Dependencies***REMOVED***install and Merb::Dependencies***REMOVED***install_dependencies
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:stack:install                                        ***REMOVED*** install the default merb stack
    ***REMOVED*** merb:stack:install basics                                 ***REMOVED*** install a basic set of dependencies
    ***REMOVED*** merb:stack:install merb-core                              ***REMOVED*** install merb-core from stable
    ***REMOVED*** merb:stack:install merb-more --edge                       ***REMOVED*** install merb-core from edge
    ***REMOVED*** merb:stack:install merb-core thor merb-slices             ***REMOVED*** install the specified gems                  
      
    desc 'install [COMP, ...]', 'Install stack components'
    method_options  "--edge"      => :boolean,
                    "--sources"   => :optional,
                    "--force"     => :boolean,
                    "--dry-run"   => :boolean,
                    "--strategy"  => :optional
    def install(*comps)
      use_edge_gem_server if options[:edge]
      mngr = self.dependency_manager
      deps = gather_dependencies(comps)
      mngr.system, mngr.local, mngr.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      mngr.install_dependencies(strategy, deps)
    end
        
    ***REMOVED*** Uninstall stack components or individual gems.
    ***REMOVED***
    ***REMOVED*** See also: Merb::Dependencies***REMOVED***uninstall
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:stack:uninstall                                      ***REMOVED*** uninstall the default merb stack
    ***REMOVED*** merb:stack:uninstall merb-more                            ***REMOVED*** uninstall merb-more
    ***REMOVED*** merb:stack:uninstall merb-core thor merb-slices           ***REMOVED*** uninstall the specified gems
    
    desc 'uninstall [COMP, ...]', 'Uninstall stack components'
    method_options "--dry-run" => :boolean, "--force" => :boolean
    def uninstall(*comps)
      deps = gather_dependencies(comps)
      self.system, self.local, self.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      ***REMOVED*** Clobber existing local dependencies - based on self.local
      clobber_dependencies!
    end
    
    ***REMOVED*** Install or uninstall minigems from the system.
    ***REMOVED***
    ***REMOVED*** Due to the specific nature of MiniGems it can only be installed system-wide.
    ***REMOVED***
    ***REMOVED*** Examples:
    ***REMOVED***
    ***REMOVED*** merb:stack:minigems install                               ***REMOVED*** install minigems
    ***REMOVED*** merb:stack:minigems uninstall                             ***REMOVED*** uninstall minigems
    
    desc 'minigems (install|uninstall)', 'Install or uninstall minigems (needs sudo privileges)'
    def minigems(action)
      case action
      when 'install'
        Kernel.system "***REMOVED***{sudo} thor merb:stack:install_minigems"
      when 'uninstall'
        Kernel.system "***REMOVED***{sudo} thor merb:stack:uninstall_minigems"
      else
        error "Invalid command: merb:stack:minigems ***REMOVED***{action}"
      end
    end    
    
    ***REMOVED*** hidden minigems install task
    def install_minigems
      message "Installing MiniGems"
      mngr = self.dependency_manager
      deps = gather_dependencies('minigems')
      mngr.system, mngr.local, mngr.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      mngr.force_gem_dir = ::Gem.dir
      mngr.install_dependencies(strategy, deps)
      Kernel.system "***REMOVED***{sudo} minigem install"
    end
    
    ***REMOVED*** hidden minigems uninstall task
    def uninstall_minigems
      message "Uninstalling MiniGems"
      Kernel.system "***REMOVED***{sudo} minigem uninstall"
      deps = gather_dependencies('minigems')
      self.system, self.local, self.missing = Merb::Gem.partition_dependencies(deps, gem_dir)
      ***REMOVED*** Clobber existing local dependencies - based on self.local
      clobber_dependencies!      
    end
    
    protected
    
    def gather_dependencies(comps = [])
      if comps.empty?
        gems = MERB_STACK
      else
        gems = comps.map { |c| Merb::Stack.components(c) }.flatten
      end
      
      version_req = if options[:version]
        ::Gem::Requirement.create(options[:version])
      end
      
      framework_components = Merb::Stack.framework_components
      
      gems.map do |gem|
        if version_req && framework_components.include?(gem)
          ::Gem::Dependency.new(gem, version_req)
        else
          ::Gem::Dependency.new(gem, ::Gem::Requirement.default)
        end
      end
    end
    
    def strategy
      options[:strategy] || (options[:edge] ? 'edge' : 'stable')
    end
    
    def dependency_manager
      @_dependency_manager ||= begin
        instance = Merb::Dependencies.new
        instance.options = options
        instance
      end
    end
    
    public
    
    def self.repository_sets
      @_repository_sets ||= begin
        ***REMOVED*** the component itself as a fallback
        comps = Hash.new { |(hsh,c)| [c] }
        
        ***REMOVED*** git repository based component sets
        comps["merb"]         = ["merb-core"] + MERB_MORE
        comps["merb-more"]    = MERB_MORE.sort
        comps["merb-plugins"] = MERB_PLUGINS.sort
        comps["dm-more"]      = DM_MORE.sort
        comps["do"]           = DATA_OBJECTS.sort
        
        comps
      end     
    end
    
    def self.component_sets
      @_component_sets ||= begin
        ***REMOVED*** the component itself as a fallback
        comps = Hash.new { |(hsh,c)| [c] }
        comps.update(repository_sets)
        
        ***REMOVED*** specific set of dependencies
        comps["stack"]        = MERB_STACK.sort
        comps["basics"]       = MERB_BASICS.sort
        
        ***REMOVED*** orm dependencies
        comps["datamapper"]   = DM_STACK.sort
        comps["sequel"]       = ["merb_sequel", "sequel"]
        comps["activerecord"] = ["merb_activerecord", "activerecord"]
        
        comps
      end
    end
    
    def self.framework_components
      %w[merb-core merb-more].inject([]) do |all, comp| 
        all + components(comp)
      end
    end
    
    def self.components(comp = nil)
      if comp
        component_sets[comp]
      else
        comps = %w[merb-core merb-more merb-plugins dm-core dm-more]
        comps.inject([]) do |all, grp|
          all + (component_sets[grp] || [])
        end
      end
    end
    
    def self.select_component_dependencies(dependencies, comp = nil)
      comps = components(comp) || []
      dependencies.select { |dep| comps.include?(dep.name) }
    end
    
    def self.base_components
      %w[thor rake extlib]
    end
    
    def self.all_components
      base_components + framework_components
    end
    
    ***REMOVED*** Find the latest merb-core and gather its dependencies.
    ***REMOVED*** We check for 0.9.8 as a minimum release version.
    def self.core_dependencies(gem_dir = nil, ignore_deps = false)
      @_core_dependencies ||= begin
        if gem_dir ***REMOVED*** add local gems to index
          orig_gem_path = ::Gem.path
          ::Gem.clear_paths; ::Gem.path.unshift(gem_dir)
        end
        deps = []
        merb_core = ::Gem::Dependency.new('merb-core', '>= 0.9.8')
        if gemspec = ::Gem.source_index.search(merb_core).last
          deps << ::Gem::Dependency.new('merb-core', gemspec.version)
          if ignore_deps 
            deps += gemspec.dependencies.select do |d| 
              base_components.include?(d.name)
            end
          else
            deps += gemspec.dependencies
          end
        end
        ::Gem.path.replace(orig_gem_path) if gem_dir ***REMOVED*** reset
        deps
      end
    end
    
    def self.lookup_repository_name(item)
      set_name = nil
      ***REMOVED*** The merb repo contains -more as well, so it needs special attention
      return 'merb' if self.repository_sets['merb'].include?(item)
      
      ***REMOVED*** Proceed with finding the item in a known component set
      self.repository_sets.find do |set, items| 
        next if set == 'merb'
        items.include?(item) ? (set_name = set) : nil
      end
      set_name
    end
    
  end
  
end
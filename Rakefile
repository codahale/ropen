require "spec/rake/spectask"
require "rake/clean"
require "rake/rdoctask"
require "rake/gempackagetask"

task :default => [:spec]

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.spec_opts = ["-o", "spec/spec.opts"]
end

CLOBBER.include(
  "doc/coverage"
)

STATS_DIRECTORIES = [
  ['Code', 'lib/'],
  ['Unit tests', 'spec']
].collect { |name, dir| [ name, "./#{dir}" ] }.
  select  { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require File.join(File.dirname(__FILE__), "tools", "code_statistics")
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

namespace :spec do
  desc "Run all specs and store html output in doc/specs.html"
  Spec::Rake::SpecTask.new('html') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--diff','--format html','--backtrace','--out doc/specs.html']
  end
  
  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new("rcov") do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
    t.spec_opts = ["-o", "spec/spec.opts"]
    t.rcov = true
    t.rcov_dir = 'doc/coverage'
    t.rcov_opts = ['--exclude', 'spec\/spec,spec\/.*_spec.rb', "-T"]
  end
end

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--title' << 'ropen' << '--line-numbers' << '--inline-source' << '--main' << 'README.markdown'
  rdoc.template = ENV['TEMPLATE'] if ENV['TEMPLATE']
  rdoc.rdoc_files.include('README.markdown', 'MIT-LICENSE', 'CHANGELOG', 'lib/**/*.rb')
end

PKG_NAME = "ropen"
PKG_VERSION   = "1.0.0"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb', 
  'spec/**/*.rb'
]

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = "A better way to control spawned processes."
  s.description = <<-EOF
    Like popen, only not sucky.
  EOF
  
  s.files = PKG_FILES.to_a
  s.require_path = 'lib'

  s.has_rdoc = true
  s.rdoc_options = rd.options
  s.extra_rdoc_files = rd.rdoc_files.to_a
  
  s.authors = ["Coda Hale"]
  s.email = "coda.hale@gmail.com"
  s.homepage = "http://www.github.com/codahale/ropen"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
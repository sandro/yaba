require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Generate documentation for the openid_wrapper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'OpenidWrapper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Custom git push deploy'
task :push do
  `git push origin master`
  `git push github master`
  `git push rubyforge master`
end

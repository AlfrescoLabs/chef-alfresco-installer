#!/usr/bin/env rake
require 'foodcritic'
require 'rake'

desc "Runs foodcritic test"
task :foodcritic do
  FoodCritic::Rake::LintTask.new
  sh "bundle exec foodcritic -f any ."
end

desc "Runs rubocop checks"
task :rubocop do
  sh "bundle exec rubocop --fail-level warn"
end

task :default => [:foodcritic, :rubocop]

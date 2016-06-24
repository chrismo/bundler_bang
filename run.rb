require 'fileutils'

FileUtils.rm Dir.glob("Gemfile*lock")

installed = `gem list bundler`.scan(/\Abundler \((.*)\)/).join.split(',')

def puts_system(cmd)
  puts cmd
  system cmd
end

# 1.0.22 1.1.5 1.2.5 => don't work with RubyGems 2.0
# 1.3.6 1.5.3 1.6.9  => doesn't support :source option with `gem` command
versions = %w(1.7.15 1.8.9 1.9.10 1.10.5 1.11.2 1.12.5)
versions.each do |bundler_ver|
  puts_system("gem install bundler --version #{bundler_ver}") unless installed.include?(bundler_ver)
  puts_system("bundle _#{bundler_ver}_ install")
  FileUtils.mv "Gemfile.lock", "Gemfile.#{bundler_ver}.lock"
  puts '-' * 80
end




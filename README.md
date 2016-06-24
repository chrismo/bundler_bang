# Bundler Bang

When _does_ Bundler decide to use a `!` when labeling `DEPENDENCIES` in the lockfile? There appears to be
[some](https://github.com/bundler/bundler/issues/3502)
[confusion](https://groups.google.com/forum/#!topic/ruby-bundler/QxlNGzK3rEY) on them thar internets, so maybe
some code can help.

## The Answer?

It's no more complicated then when a declared dependency in a Gemfile has an explicit source attached to it,
whether that comes from a source block, a `source:` option, or `git` or `file` source.

```ruby
source 'https://rubygems.org'

# no bang
gem 'rack'

# bang
gem 'ast', source: 'https://rubygems.org'

# bang
source 'https://rubygems.org' do
  gem 'needle'
end

# bang
gem 'slop', git: 'https://github.com/leejarvis/slop.git'
```

## Which Version of Bundler Changed This?

It's at least been this way back to 1.7.x which first supported source blocks. The `!` itself goes back to
[this 1.0.0.beta1 tagged commit](https://github.com/bundler/bundler/blob/2b9094e9d0f0cc21d8acf503da98fd908e29f6ff/lib/bundler/dependency.rb#L28).

All of the generated lockfiles in this repo are identical (except for `BUNDLED WITH` in 1.10+). You can re-create
them yourself with the included run.rb script.

```
diff Gemfile.1.7.15.lock Gemfile.1.8.9.lock
diff Gemfile.1.8.9.lock Gemfile.1.9.10.lock
diff Gemfile.1.9.10.lock Gemfile.1.10.5.lock
21a22,24
>
> BUNDLED WITH
>    1.10.5
diff Gemfile.1.10.5.lock Gemfile.1.11.2.lock
24c24
<    1.10.5
---
>    1.11.2
diff Gemfile.1.11.2.lock Gemfile.1.12.5.lock
24c24
<    1.11.2
---
>    1.12.5
```

## Why Does It Record It?

Mostly to ensure the Dependency instance has its Source instance restored. For path sources, it also does an extra
bit. ([1.12.5 version](https://github.com/bundler/bundler/blob/a65a2db118ed714586ac4c56a0584c97bf0305df/lib/bundler/lockfile_parser.rb#L172-L197)).

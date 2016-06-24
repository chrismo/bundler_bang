# Bundler Bang

When _does_ Bundler decide to use a `!` when labeling `DEPENDENCIES` in the lockfile? There appears to be
[some](https://github.com/bundler/bundler/issues/3502)
[confusion](https://groups.google.com/forum/#!topic/ruby-bundler/QxlNGzK3rEY) on them thar internets, so maybe
some code can help.

## The Answer?

It's no more complicated then when a declared dependency in a Gemfile has an explicit source attached to it,
whether that comes from a source block, a `source:` option, or `git` or `file` source.

## Which Version of Bundler Changed This?

It's at least been this way back to 1.7.x which first supported source blocks. The `!` itself goes back to
[this 1.0.0.beta1 tagged commit](https://github.com/bundler/bundler/blob/2b9094e9d0f0cc21d8acf503da98fd908e29f6ff/lib/bundler/dependency.rb#L28).

All of the generated lockfiles in this repo are identical (except for `BUNDLED WITH` in 1.10+). You can re-create
them yourself with the included run.rb script.

## Why Does It Even Record It?

For path sources.

In the same 1.0.0.beta1 commit, the LockfileParser has
[this comment and code](https://github.com/bundler/bundler/blob/2b9094e9d0f0cc21d8acf503da98fd908e29f6ff/lib/bundler/lockfile_parser.rb#L52-L73):

```ruby
    def parse_dependency(line)
      if line =~ %r{^ {2}#{NAME_VERSION}(!)?$}
        name, version, pinned = $1, $2, $3

        dep = Bundler::Dependency.new(name, version)

        if pinned
          dep.source = @specs.find { |s| s.name == dep.name }.source

          # Path sources need to know what the default name / version
          # to use in the case that there are no gemspecs present. A fake
          # gemspec is created based on the version set on the dependency
          # TODO: Use the version from the spec instead of from the dependency
          if version =~ /^= (.+)$/ && dep.source.is_a?(Bundler::Source::Path)
            dep.source.name    = name
            dep.source.version = $1
          end
        end

        @dependencies << dep
      end
    end
```

And this code is largely unchanged today
([1.12.5 version](https://github.com/bundler/bundler/blob/a65a2db118ed714586ac4c56a0584c97bf0305df/lib/bundler/lockfile_parser.rb#L172-L197)).

## So ... That's It?

Yeup.

## So ... I Can Probably Ignore It?

Yeah, probably.

## What If You're Wrong?

There's a good chance I am. Submit a PR!

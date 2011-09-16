# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sekka}
  s.version = "0.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kiyoka Nishiyama"]
  s.date = %q{2011-09-16}
  s.description = %q{Sekka is a SKK like input method. Sekka server provides REST Based API. If you are SKK user, let's try it.}
  s.email = %q{kiyoka@sumibi.org}
  s.executables = ["sekka-jisyo", "sekka-server", "sekka-benchmark", "sekka-path"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "COPYING",
    "README",
    "bin/sekka-benchmark",
    "bin/sekka-jisyo",
    "bin/sekka-path",
    "bin/sekka-server",
    "emacs/http-cookies.el",
    "emacs/http-get.el",
    "emacs/popup.el",
    "emacs/sekka.el",
    "lib/sekka.ru",
    "lib/sekka/alphabet-lib.nnd",
    "lib/sekka/approximatesearch.rb",
    "lib/sekka/convert-jisyo.nnd",
    "lib/sekka/google-ime.nnd",
    "lib/sekka/henkan.nnd",
    "lib/sekka/jisyo-db.nnd",
    "lib/sekka/kvs.rb",
    "lib/sekka/path.rb",
    "lib/sekka/roman-lib.nnd",
    "lib/sekka/sekkaversion.rb",
    "lib/sekka/sharp-number.nnd",
    "lib/sekka/util.nnd",
    "lib/sekkaconfig.rb",
    "lib/sekkaserver.rb",
    "script/sekkaserver.debian",
    "test/alphabet-lib.nnd",
    "test/approximate-bench.nnd",
    "test/azik-verification.nnd",
    "test/common.nnd",
    "test/google-ime.nnd",
    "test/henkan-bench.nnd",
    "test/henkan-main.nnd",
    "test/jisyo.nnd",
    "test/memcache.nnd",
    "test/roman-lib.nnd",
    "test/sharp-number.nnd",
    "test/skk-azik-table.nnd",
    "test/util.nnd"
  ]
  s.homepage = %q{http://github.com/kiyoka/sekka}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Sekka is a SKK like input method.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<fuzzy-string-match>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<memcache-client>, [">= 0"])
      s.add_runtime_dependency(%q<nendo>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<redis>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-progressbar>, [">= 0"])
      s.add_development_dependency(%q<rubyforge>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<fuzzy-string-match>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<memcache-client>, [">= 0"])
      s.add_runtime_dependency(%q<nendo>, ["= 0.5.3"])
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-progressbar>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<fuzzy-string-match>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<nendo>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<redis>, [">= 0"])
      s.add_dependency(%q<ruby-progressbar>, [">= 0"])
      s.add_dependency(%q<rubyforge>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<fuzzy-string-match>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<nendo>, ["= 0.5.3"])
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<ruby-progressbar>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<fuzzy-string-match>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<nendo>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<redis>, [">= 0"])
    s.add_dependency(%q<ruby-progressbar>, [">= 0"])
    s.add_dependency(%q<rubyforge>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<fuzzy-string-match>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<nendo>, ["= 0.5.3"])
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<ruby-progressbar>, [">= 0"])
  end
end


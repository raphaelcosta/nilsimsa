Gem::Specification.new do |spec|
  # Descriptive and source information for this gem.
  spec.name = "nilsimsa"
  spec.version = "1.0.6"
  spec.summary = "Computes Nilsimsa values.  Nilsimsa is a distance based hash"
  spec.author = "Jonathan Wilkins (update to ruby 1.9 by Adam Schepis)"
  spec.email = "jwilkins[at]nospam[dot]bitland[dot]net"
  spec.has_rdoc = true
  spec.extra_rdoc_files = ["README"]

  spec.files = %w(README nilsimsa.gemspec nilsimsa.rb bin/nilsimsa
                  examples/simple.rb ext/extconf.rb ext/nilsimsa.c)
  spec.executables = ['nilsimsa']
  spec.require_paths = ["lib"]

  # optional native component
  spec.extensions = ['ext/extconf.rb']
end

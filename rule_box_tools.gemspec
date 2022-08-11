# frozen_string_literal: true

require_relative 'lib/rule_box_tools/version'

Gem::Specification.new do |spec|
  spec.name = 'rule_box_tools'
  spec.version = RuleBoxTools::VERSION
  spec.authors = ['Ralph Baesso']
  spec.email = ['ralphsbaesso@gmail.com']

  spec.summary = 'RuleBoxTools'
  spec.description = 'Tools to complement RuleBox gem.'
  spec.homepage = 'https://github.com/ralphsbaesso/rule_box_tools'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ralphsbaesso/rule_box_tools'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.files -= %w[.gitignore .rspec .rspec_status]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rule_box', '~> 0.2.0'
end

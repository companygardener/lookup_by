### [v0.12.0](https://github.com/companygardener/lookup_by/compare/v0.11.2...v0.12.0)

Require ruby 2.7. Support ruby 3.1

* Appraisal: remove rails 5.0, 5.1, and 5.2
* Appraisal: add rails 7.0
* Dev: .ruby-version 3.1.2

### [v0.11.2](https://github.com/companygardener/lookup_by/compare/v0.11.1...v0.11.2)

Merged a few PRs. Shouldn't break anything.

* Appraisal: add rails 5.1 and 5.2
* Appraisal: bundle update
* Fix: alias_method_chain was deprecated a long time ago
* Fix: clearing the cache will also clear the reverse lookup cache
* Dev: .ruby-version 2.6.1
* Doc: docs for :scope and :inverse_scope options on `lookup_for` method
* Doc: add changelog

### [v0.11.1](https://github.com/companygardener/lookup_by/compare/v0.11.0...v0.11.1)

#### Fix .all on lookup models

Version 0.11.0 breaks Model.where(field: 'value').first_or_create! when
Model is configured with `lookup_by :field, cache: true`.

### [v0.11.0](https://github.com/companygardener/lookup_by/compare/v0.10.9...v0.11.0)

#### Rails 5.0.0 support

Update .count signature to support Rails 5.

- Require ruby 2.2.2+
- PostgreSQL 9.2+
- Drop support for JRuby

#### Default to a threadsafe cache

### [v0.10.9](https://github.com/companygardener/lookup_by/compare/v0.10.8...v0.10.9)

### [v0.10.8](https://github.com/companygardener/lookup_by/compare/v0.10.7...v0.10.8)

### [v0.10.7](https://github.com/companygardener/lookup_by/compare/v0.10.6...v0.10.7)

### [v0.10.6](https://github.com/companygardener/lookup_by/compare/v0.10.5...v0.10.6)

### [v0.10.5](https://github.com/companygardener/lookup_by/compare/v0.10.4...v0.10.5)

### [v0.10.4](https://github.com/companygardener/lookup_by/compare/v0.10.3...v0.10.4)

### [v0.10.3](https://github.com/companygardener/lookup_by/compare/v0.10.2...v0.10.3)

### [v0.10.2](https://github.com/companygardener/lookup_by/compare/v0.10.1...v0.10.2)

### [v0.10.1](https://github.com/companygardener/lookup_by/compare/v0.10.0...v0.10.1)

### [v0.10.0](https://github.com/companygardener/lookup_by/compare/v0.9.1...v0.10.0)

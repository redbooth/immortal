# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [3.0.0]
### Added

- Modern gem management
- Contributor Covenant CoC

### Changed

- Upgraded rspec and tests syntax

### Deprecated

- Rails versions smaller than 4.1.x

### Removed

- Support for rails versions below 4.1.x

### Fixed
### Security

## [2.0.0]
### Deprecated

- Rails versions smaller than 4.0.x

### Removed

- Support for rails versions below 4.0.x

## [1.0.5]

### Changed

- Use separate internal accessors for with/only_deleted singular association readers

## [1.0.4] 
### Changed

- Extract with_deleted singular assoc readers to separate module

## [1.0.3] 
### Added

- Added back feature where using immortal finders doesn't unscope association scopes.

## [1.0.2] 
### Added

- Added with/only_deleted singular association readers (see specs)

## [1.0.1] 
### Added

- Made compatible with Rails 3.1.X

## [1.0.0] 
### Changed

- Changed the API, made it compatible with Rails 3.1, removed functionality

## [0.1.6] 
### Fixed

- issue 2: with_deleted breaks associations

## [0.1.5] 
### Added

- "without deleted" scope to join model by overriding
  HasManyThroughAssociation#construct_conditions rather than simply adding to
  has_many conditions.

## [0.1.4] 
### Fixed

- Bug where ALL records of any dependent associations were immortally deleted if
  assocation has `:dependant => :delete_all` option set

## [0.1.3] 
### Fixed

- Bug where join model is not immortal

## [0.1.2] 
### Fixed

- Loading issue when the `deleted` column doesn't exist (or even the table)

## [0.1.1] 
### Fixed

- Behavior with `has_many :through` associations

[Unreleased]: https://github.com/teambox/immortal/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/teambox/immortal/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/teambox/immortal/compare/v1.0.5...v2.0.0
[1.0.5]: https://github.com/teambox/immortal/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/teambox/immortal/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/teambox/immortal/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/teambox/immortal/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/teambox/immortal/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/teambox/immortal/compare/v0.1.6...v1.0.0
[0.1.6]: https://github.com/teambox/immortal/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/teambox/immortal/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/teambox/immortal/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/teambox/immortal/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/teambox/immortal/compare/v0.1.1...v0.1.2

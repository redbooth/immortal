# Immortal

Make any ActiveRecord model paranoid by just including `Immortal`, and instead of being deleted from the database, the object will just marked as 'deleted' with a boolean field in the database.

## Installation

Add the gem dependency to your Gemfile:

    gem 'immortal'

## Usage

    class User < ActiveRecord::Base
      include Immortal
    end

And add a boolean field called `deleted` to that model:

    class AddDeletedToUsers < ActiveRecord::Migration
      def self.up
        add_column :users, :deleted, :boolean
      end

      def self.down
        remove_column :users, :deleted
      end
    end

## TODO

- Add documentation in the code

## Contributing

If you want to improve immortal

1. Fork the repo
2. Create a topic branch `git checkout -b my_feature`
3. Push it! `git push origin my_feature`
4. Open a pull request

## CHANGELOG

- 2.0.0 [WARNING NON-BACKWARDS COMPATIBLE RELEASE]

  The major new feature here is we've removed the default_scope.

  To get find to NOT return records marked as deleted by immortal, 
  you now need to be explicit and use the supplied 'without_deleted' scope.

    Task.without_deleted.first

  If you want all records then don't bother with the scope:

    Task.first

  If you only want deleted records use the 'only_deleted' scope.

    Task.only_deleted.first

  The 'with_deleted' scope is no longer.

  See the updated specs for a feel of what using immortal is like now.

- 1.0.5 Use separate internal accessors for with/only_deleted singular association readers
- 1.0.4 Extract with_deleted singular assoc readers to separate module
- 1.0.3 Added back feature where using immortal finders doesn't unscope association scopes.
- 1.0.2 Added with/only_deleted singular association readers (see specs)
- 1.0.1 Made compatible with Rails 3.1.X
- 1.0.0 Changed the API, made it compatible with Rails 3.1, removed
  functionality
- 0.1.6 Fixing immortal issue 2: with_deleted breaks associations
- 0.1.5 Add "without deleted" scope to join model by overriding HasManyThroughAssociation#construct_conditions
    rather than simply adding to has_many conditions.
- 0.1.4 fix bug where ALL records of any dependent associations were
  immortally deleted if assocation has :dependant => :delete_all option
  set
- 0.1.3 fix bug where join model is not immortal
- 0.1.2 fix loading issue when the `deleted` column doesn't exist (or even the table)
- 0.1.1 fix behavior with `has_many :through` associations

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
- Spec associations
- Add support for a :with_deleted option in associations, like acts_as_paranoid
- Improve compatibility with acts_as_paranoid

## Contributing

If you want to improve immortal

1. Fork the repo
2. Create a topic branch `git checkout -b my_feature`
3. Push it! `git push origin my_feature`
4. Open a pull request

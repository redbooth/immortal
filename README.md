# Immortal

Make any ActiveRecord model paranoid by just including `Immortal`, and instead
of being deleted from the database, the object will just marked as 'deleted'
with a boolean field in the database.

## Installation

Add the gem dependency to your Gemfile:

```ruby
gem 'immortal'
```

## Usage

```ruby
class User < ActiveRecord::Base
  include Immortal
end
```

And add a boolean field called `deleted` to that model:

```ruby
class AddDeletedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :deleted, :boolean
  end

  def self.down
    remove_column :users, :deleted
  end
end
```

## TODO

- Add documentation in the code

## Contributing

If you want to improve immortal

1. Fork the repo
2. Create a topic branch `git checkout -b my_feature`
3. Push it! `git push origin my_feature`
4. Open a pull request

## License

(The MIT License)

Copyright (c) Redbooth

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Python

Python implemented in pure Ruby without any libraries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'python'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install python

## Usage

Executable script "python.rb" will be installed in your bin path.
You can execute python program by two way.
One way is through command-line interpreter (REPL), and another is from source-file.

### Command-line interpreter (REPL)

    $ python.rb
    python.rb> 1 + 2
    3
    python.rb>

### Executing program from source file

```python
# demo.py
class A:
    def __init__(self, x):
        self.x = x

    def add(self, d):
        self.x = self.x + d
        return self

a = A(1).add(2).add(3)
print(a.x)
```

    $ python.rb demo.py
    6
    $

## Contributing

1. Fork it ( https://github.com/sawaken/python.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

# Ruby Yank FQN

## About
This plugin yanks the absolute path name (FQN) of the current cursor
position inside a ruby module/class.

## Installation

I recommend [Vundle](https://github.com/VundleVim/Vundle.vim)

    Plugin 'codegourmet/ruby-yank-fqn'

## Usage

Setup the method via your preferred keybinding inside `.vimrc`:

    nmap yf !silent :call YankFQN()<CR>

Then trigger the yanking inside a module.

## Example

```
module Foo
  class Class1
  end

  class Class2
    # [x] cursor is here
  end
end
```

if you press `yf` (or your custom combination, see above) at
the marked cursor position, the string `Foo::Class2`
will get yanked into the unnamed register (@").

NOTE: you can yank from any position. If the cursor is on a `class`,
`module` or `end` statement, it will still count as being inside the scope.

example:

```
  module Foo
    class Class1
    end
    # ^-- cursor is on the end statement
  end
```

will yield `Foo::Class1`

## Settings

### g:yankfqn_register
If you're using `clipboard=unnamed` or `clipboard=unnamedplus`,
you might want to change the target register.

    let g:yankfqn_register = '*'

Default: `"` (unnamed yank register)

### g:yankfqn_verbose
If this flag is set to 1, the yanked string will be output as message.

Default: `0`

## Contributing
If you think anything's missing or buggy, please drop me a line or a pull request.

## TODO

vim docs

## License
Same license as Vim.

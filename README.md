# Blackify

Blackify is a emacs-lisp function that format python buffer using 
[black](https://github.com/psf/black). The package is inspired by 
[yapfify](https://github.com/JorisE/yapfify) and has similar interface to it.
Yapfify (yapf) can be easily replaced to blackify (black) only by renaming
"yapfify" to "blackify" in `init.el`.

## Configuration

- sample configuration ([use-package](https://github.com/jwiegley/use-package) + [straight](https://github.com/raxod502/straight.el))

```lisp
(use-package blackify
    :straight (blackify :type git :branch "main" :repo "https://github.com/y-kitamu/blackify")
    :hook (python-mode . blackify-mode))
```

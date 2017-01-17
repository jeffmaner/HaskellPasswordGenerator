HaskellPasswordGenerator
========================

Synopsis
--------

My exploration of [XKCD's Password Generator][1] via [Haskell][2].

I didn't want to install the full [Haskell Platform][3] on the machine on which
I did most of this work, so I just used [Hugs][4] instead. I expect the code
will run with the full [Haskell Platform][3], but I haven't verified this.

I haven't yet implemented all the options as fully as I have with [my Red][5]
and Rebol implementations.

Running the Generator
---------------------

From within [Hugs][4]:

```
Hugs> :load "<path-to-file>\\generate-passwords.hs"
Main> :main -h
```

will display the usage.

N.b.
----

Calling

```
Main> :main
```

and, again

```
Main> :main
```

will result in the same passwords generated. This is a result of Haskell's
functional paradigm, and my use of [System.Random][6] To generate a different
list of passwords,

```
Main> :load "<path-to-file>\\generate-passwords.hs"
```

then

```
Main> :main
```

again.

[Caveat Lector][7]
------------------

The reader of delicate sensibilities should stick with the dictionary word
listing `EN_sample.txt` and avoid `EN_curse.txt`. The cursed passwords
generated using the dictionary curse word listing make me laugh.

[1]: https://xkpasswd.net/s/
[2]: https://www.haskell.org/
[3]: https://www.haskell.org/downloads#platform
[4]: https://www.haskell.org/hugs/
[5]: https://github.com/jeffmaner/RedPasswordGenerator
[6]: http://hackage.haskell.org/package/random-1.1/docs/System-Random.html
[7]: https://www.merriam-webster.com/dictionary/caveat%20lector

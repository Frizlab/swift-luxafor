# Swift Luxafor
A simple library to control the [Luxafor Flag](https://luxafor.com/luxafor-flag/).

## Examples

For rainbow radness
```
go get -v -u  github.com/leosunmo/goluxafor/example/rainbow
rainbow
```

Quick 'n dirty CLI
```
go get -v -u github.com/leosunmo/goluxafor/example/luxcli

$ luxcli red
$ luxcli green
$ luxcli off
```



## Usage

```go
package main

import (
	"github.com/leosunmo/goluxafor"
)

func main() {
	luxafor := goluxafor.NewLuxafor()
	luxafor.Pattern(goluxafor.Pattern8, 0)

	luxafor.Close()
}
```

## Constants

### LEDs

<img src="/luxaforflag.png" height="250">


* `goluxafor.LedAll` - All LEDs
* `goluxafor.LedA`   - Back side
* `goluxafor.LedB`   - Flag side
* `goluxafor.Led1`   - Lower flag
* `goluxafor.Led2`   - Middle flag
* `goluxafor.Led3`   - Top flag
* `goluxafor.Led4`   - Lower back
* `goluxafor.Led5`   - Middle back
* `goluxafor.Led6`   - Top back


### Static colours and fade

Set whole flag to red colour and set `fadeTime` to a non-zero value up to 255 to control the fade speed.
```go
luxafor.Colour(goluxafor.ledAll, 255, 0, 0, fadeTime)
```
Also works for individual LEDs.

### Strobe

Strobe can be set on individual LEDs, sides or all.

Set strobe frequency with `speed` and number of repeats with `repeat`, `0` is forever.
```go
luxafor.Strobe(goluxafor.LedAll, randomColour(), randomColour(), randomColour(), speed, repeat)
```

### Wave

Wave is executed on the whole flag and has 5 different wave patterns.

Set wave change speed with `speed` and number of repetitions with `repeat`, `0` is forever.
```go
luxafor.Wave(goluxafor.Wave2, randomColour(), randomColour(), randomColour(), speed, repeat)
```

### Patterns

Patterns are pre-programmed patterns on the device itself that are executed on all LEDs.

You can only specify the pattern type and `repeat`. Again, `0` will loop the pattern forever.

```go
luxafor.Pattern(goluxafor.Pattern5, 0) // Loop police lights forever
```

Patterns:

* `goluxafor.Pattern1` - Traffic lights
* `goluxafor.Pattern2` - Colour walk
* `goluxafor.Pattern3` - Random pattern
* `goluxafor.Pattern4` - Random fading pattern
* `goluxafor.Pattern5` - Police pattern
* `goluxafor.Pattern6` - Random quick fade pattern
* `goluxafor.Pattern7` - Colourful police pattern
* `goluxafor.Pattern8` - Quick rainbow pattern

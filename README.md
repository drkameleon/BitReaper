# BitReaper
Automated Web-Scraping Client for Ruby

### Installation

```gem install bitreaper
```

### Usage

*A sample parser file, let's call it `parser.br`:*

```sdl
//------------------------------------
// Wikipedia scraper
// for Country pages
//
// @copyright drkameleon
//------------------------------------

country "#firstHeading"

infobox {
    capital "//th[contains(text(),'Capital')]/../td/a" \
        prepend="{{country}}" \
        trim=on \
        replace="o||x" \
        uppercase=on 

    language "//th[contains(text(),'Official language')]/../td/a"

    details {
        currency "//th[contains(text(),'Currency')]/../td/a" \
            select.include="/[A-Z]+/" \
            select.match="Euro"

        callingCode "//th/a[contains(text(),'Calling code')]/../../td"

        drivingSide "//th/a[contains(text(),'Driving side')]/../../td" \
            append="-->{{infobox.details.callingCode}}"

        TLD "//th/a[contains(text(),'Internet TLD')]/../../td" \
            append="_{{infobox.capital}}"
    }

}
```

*A sample input file, let's call it `input.lst`:*

```
https://en.wikipedia.org/wiki/Spain
https://en.wikipedia.org/wiki/Italy
https://en.wikipedia.org/wiki/France
https://en.wikipedia.org/wiki/Greece
```

**How do I run this thing?**

Simple:

```bitreaper parser.br -i input.lst -o output.json```

**And here's the output:**

*(weird admittedly, but showcasing what BitReaper is capable of ;-)

```json
[
  {
    "country": "Spain",
    "infobox": {
      "capital": "SPAINMADRID",
      "language": "Spanish",
      "details": {
        "currency": [
          "Euro"
        ],
        "callingCode": "+34",
        "drivingSide": "right-->+34",
        "TLD": ".es[h]_SPAINMADRID"
      }
    }
  },
  {
    "country": "Italy",
    "infobox": {
      "capital": "ITALYRXME",
      "details": {
        "currency": [

        ],
        "callingCode": "+39c",
        "drivingSide": "right-->+39c",
        "TLD": ".itd_ITALYRXME"
      }
    }
  },
  {
    "country": "France",
    "infobox": {
      "capital": "FRANCEPARIS",
      "language": "French",
      "details": {
        "callingCode": "+33[XI]",
        "drivingSide": "right-->+33[XI]",
        "TLD": ".fr[XII]_FRANCEPARIS"
      }
    }
  },
  {
    "country": "Greece",
    "infobox": {
      "capital": "GREECEATHENS",
      "language": "Greek",
      "details": {
        "currency": [
          "Euro"
        ],
        "callingCode": "+30",
        "drivingSide": "right-->+30",
        "TLD": ".gra.ελ_GREECEATHENS"
      }
    }
  }
]
```

### License

Copyright 2020 Ioannis Zafeiropoulos (a.k.a. Dr.Kameleon)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

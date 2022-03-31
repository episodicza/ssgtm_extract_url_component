# GTM Server-Side Variable Template for Extracting URL Components
This variable template enables you to extract various URL components into a variable. The options are configurable for formatting and fallback return values.

You can extract:
- Full URL
- Scheme / Protocol
- Port
- Hostname with or without the leading 'www'
- Path
- Query String or specific Query Parameters with or without the query string seperator ('?')
- Hash fragment with or without the fragment seperator ('#')

## Why a new template?
The existing templates (at time of writing) that offer similar functionality are
- Simo Ahava's [URL Parser](https://github.com/mbaersch/extract-parameters)
- Markus Baersch's [Extract Parameters From Event Data](https://github.com/mbaersch/extract-parameters)

Both are great tempaltes and served as the inspiration for some of the concepts in this template. However, there were some features and specific parse handling of that I felt were needed in a general purpose variable template like this.
- Fallback return values for all extraction types (undefined or empty string)
- the ability to conditionally format the output according to the specific component (e.g. strip query param seperator)
- better filename extension detection

## How it works
You simply:
- choose a source for the URL
- choose which component you want extracted
- check any formatting options specific to that component

The tests are reasonably complete and you can see the basics of how it operates there.

The _fallback_ option allows you to specify whether you want the return value to be `undefined` or the empty string `""` if the component you want is not found. The default is to use `undefined`.

### Choose a URL source
The default is to use the `eventData.page_location` however you can change this to any variable you choose.

### Extract Query String
Choose _Query Parameters_ from the _Component Type_ dropdown. Leaving the _Query Key_ option blank will extract the entire query string.

You can opt to strip the query string seperator ('?') from the result by checking the formatting option.

### Extract Specific Query Param
Choose _Query Parameters_ from the _Component Type_ dropdown. Enter a parameter name in the _Query Key_ option. This will scan the query string for that parameter and return the first matching value (URL decoded).

For example:
- with a URL as `https://www.example.com?gclid=abc123` and `gclid` in the _Query Key_, your return value would be `abc123`
- with a URL as `https://www.example.com?gclid=abc123` and `xyz` in the _Query Key_, your return value would be `undefined` (or `""`)
- with a URL as `https://www.example.com?abc=123&abc=456` and `abc` in the _Query Key_, your return value would be `123` and not `456` nor an array of the two values

### Extract Fragment
Choose _Fragment_ from the _Component Type_ dropdown. This will return any `#foo` type anchor/fragment in the URL.

You can opt to strip the fragment seperator ('#') from the result by checking the formatting option.

### Extract Filename Extension
Choose _Filename Extension_ from the _Component Type_ dropdown. This will try and find any `.ext` type extension in the page path.

For example:
- If the path is `/foo/file.pdf` then the return value is `pdf`
- If the path is `/foo/file` then the return value is undefined (or `""`)
- If the path is `/foo.bar/file.pdf` then the return value is `pdf`
- If the path is `/foo.bar/file` then the return value is undefined (or `""`)

These last two are where other templates deviate from this one. I wanted to keep the detection of the extension limited to the possible extension of the final sub-path.






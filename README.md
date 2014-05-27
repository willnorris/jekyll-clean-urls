jekyll-clean-urls
=================

This jekyll plugin allows for clean URLs of the form `/:title` (with no
trailing slash or ".html" extension).  This is done by creating destination
files of the form `/:title.html`, but URLs of the form `/:title`.  Your
webserver must be configured to serve these files using something like apache's
[multiviews][] or with an nginx config similar to:

``` nginx
location / {
  try_files $uri $uri/ $uri.html =404;
}
```

[multiviews]: https://httpd.apache.org/docs/2.4/content-negotiation.html#multiviews


Usage
------

Drop this plugin into your `_plugins` directory.  There are no new
configuration options.  Instead, just specify a permalink setting that does not
include a trailing slash or file extension:

``` yaml
permalink: /:year/:month/:title
```

From there, jekyll will create destination files of the form
`/:year/:month/:title.html`, but will create links without the file extension.
Similarly, you can specify a permalink in the front matter of an individual
post or page and the same logic will be applied.

Just make sure you configure your webserver to serve these files appropriately,
as noted above.


Related Work
------------

I've found a handful of other attempts to make this work with Jekyll.  Most
notably, [jekyll#156][] and [jekyll#2294][] either include or link to patches
that add something like this to jekyll core.  [jekyll#219][] does something a
little similar, but is more targetted at a specific permalink structure.  Then
there are things like [gist:10739376][] and [this post][aminbandali] that
approximate something sort of similar using various web server rewrite rules,
but do nothing to try and get jekyll to create links with the correct URLs in
the first place.

[jekyll#156]: https://github.com/jekyll/jekyll/issues/156
[jekyll#2294]: https://github.com/jekyll/jekyll/issues/2294
[jekyll#219]: https://github.com/jekyll/jekyll/issues/219
[gist:10739376]: https://gist.github.com/andrewlkho/10739376
[aminbandali]: http://aminbandali.com/misc/clean-urls/


To Do
-----

 - allow for pagination links of the form `/page/2` without a trailing slash


License
-------

This plugin is released under the MIT license, the [same as Jekyll itself][jekyll-mit].

[jekyll-mit]: https://github.com/jekyll/jekyll/blob/master/LICENSE

# This plugin allows for clean URLs of the form /:title (with no trailing slash
# or ".html" extension).  This is done by creating destination files of the
# form '/:title.html', but URLs of the form '/:title'.  Your webserver must be
# configured to serve these files using something like apache's multiviews or
# with an nginx config similar to:
#
#     location / {
#       try_files $uri $uri/ $uri.html =404;
#     }


# Clean URLs are specified by a permalink that does not end in ".html" or a
# trailing slash.
#
# permalink - The String permalink for the post or page
#
# Returns the Boolean of whether clean URLs are requested.
def clean_urls?(permalink)
  permalink = site.permalink_style.to_s if permalink.nil?
  return permalink !~ /\.html$/ && permalink !~ /\/$/
end

module Jekyll
  class Post
    # Obtain destination path, using clean URLs if requested.
    #
    # By default, Jekyll will treat /:title permalinks the same as /:title/,
    # using a destination file of /:title/index.html.  Instead, we change the
    # destination file to /:title.html if clean URLs are requested.
    def destination_with_clean_urls(dest)
      path = destination_without_clean_urls(dest)
      path.sub!(/\/index.html$/, '.html') if clean_urls?(permalink)
      path
    end

    alias_method :destination_without_clean_urls, :destination
    alias_method :destination, :destination_with_clean_urls
  end

  class Page
    # The template of the permalink.  Use extensionless template if clean URLs
    # are requested.
    #
    # By default, Jekyll uses the template "/:path/:basename:output_ext" for
    # pages if the permalink setting is anything other than "pretty".  Instead,
    # we drop the :output_ext for non-index HTML pages if clean URLs are
    # requested.
    def template_with_clean_urls
      if html? && !index? && clean_urls?(permalink)
        "/:path/:basename"
      else
        template_without_clean_urls
      end
    end

    alias_method :template_without_clean_urls, :template
    alias_method :template, :template_with_clean_urls

    # Obtain destination path, appending ".html" for HTML files that do not
    # currently have a file extension specified.
    #
    # At this point, the only time the destination file for an HTML page
    # wouldn't already have the ".html" extension is because of the custom
    # template we used above in template_with_clean_urls.  In that case, we
    # manually add the ".html" extension.
    def destination_with_clean_urls(dest)
      path = destination_without_clean_urls(dest)
      path += ".html" if html? && path !~ /\.html$/
      path
    end

    alias_method :destination_without_clean_urls, :destination
    alias_method :destination, :destination_with_clean_urls

  end
end

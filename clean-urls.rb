# Copyright 2014 Google Inc. All rights reserved.
#
# Use of this source code is governed by the MIT
# license that can be found in the LICENSE file.

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
  permalink !~ /\.html$/ && permalink !~ /\/$/
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

    # The generated relative url of this page. e.g. /about.html.  If clean URLs
    # are requested, "index.html" is removed from the end of URLs for HTML
    # pages.
    #
    # Returns the String url.
    def url_with_clean_urls
      url = url_without_clean_urls
      url.sub!(/\/index\.html$/, '/') if clean_urls?(permalink)
      url
    end

    alias_method :url_without_clean_urls, :url
    alias_method :url, :url_with_clean_urls
  end

  class Document
    # Obtain destination path, appending file extension for documents that lack one.
    def destination_with_clean_urls(dest)
      path = destination_without_clean_urls(dest)
      ext = Jekyll::Renderer.new(site, self).output_ext
      if !(asset_file? || yaml_file?) && path !~ /#{ext}$/
        path += ext
      end
      path
    end

    alias_method :destination_without_clean_urls, :destination
    alias_method :destination, :destination_with_clean_urls
  end

  module Paginate
    class Pagination < Generator
      # Paginates the blog's posts.
      #
      # By default, Jekyll always renders index.html files into paginated
      # directories based on the 'paginate_path' config option.  Instead,
      # the 'paginate_path' config variable is treated as a permalink template,
      # meaning that paginated pages need not be directories.  For example, a
      # config of '/pages/:num.html' will generate page/2.html, page/3.html,
      # etc.
      def paginate_with_clean_urls(site, page)
        all_posts = site.site_payload['site']['posts']
        pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)
        (1..pages).each do |num_page|
          pager = Pager.new(site, num_page, all_posts, pages)
          if num_page > 1
            newpage = Page.new(site, site.source, page.dir, page.name)
            newpage.pager = pager
            paginate_path = Pager.paginate_path(site, num_page)
            newpage.dir = paginate_path
            newpage.data["permalink"] = File.join(page.dir, paginate_path)
            site.pages << newpage
          else
            page.pager = pager
          end
        end
      end

      alias_method :paginate_without_clean_urls, :paginate
      alias_method :paginate, :paginate_with_clean_urls
    end
  end
end

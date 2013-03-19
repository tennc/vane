# encoding: UTF-8

class WpTheme < WpItem
  module Findable

    # Find the main theme of the blog
    # returns a WpTheme object or nil
    def find(target_uri)
      methods.grep(/find_from_/).each do |method|
        if wp_theme = self.send(method, target_uri)
          wp_theme.found_from = method

          return wp_theme
        end
      end
    end

    protected
    # Discover the wordpress theme name by parsing the css link rel
    def find_from_css_link(target_uri)
      response = Browser.instance.get_and_follow_location(target_uri.to_s)

      # https + domain is optional because of relative links
      matches = %r{(?:https?://[^"']+)?/([^/]+)/themes/([^"']+)/style.css}i.match(response.body)
      if matches
        return new(
          target_uri,
          {
            name:           matches[2],
            style_url:      matches[0],
            wp_content_dir: matches[1]
          }
        )
      end
    end

    # http://code.google.com/p/wpscan/issues/detail?id=141
    def find_from_wooframework(target_uri)
      body = Browser.instance.get(target_uri.to_s).body
      regexp = %r{<meta name="generator" content="([^\s"]+)\s?([^"]+)?" />\s+<meta name="generator" content="WooFramework\s?([^"]+)?" />}

      matches = regexp.match(body)
      if matches
        woo_theme_name = matches[1]
        woo_theme_version = matches[2]
        woo_framework_version = matches[3] # Not used at this time

        return new(
          target_uri,
          {
            name:    woo_theme_name,
            version: woo_theme_version
            #path:   woo_theme_name
          }
        )
      end
    end

  end
end

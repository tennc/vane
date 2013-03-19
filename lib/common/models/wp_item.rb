# encoding: UTF-8

require 'wp_item/findable'
require 'wp_item/versionable'
require 'wp_item/vulnerable'
require 'wp_item/existable'
require 'wp_item/infos'
require 'wp_item/output'

class WpItem

  extend  WpItem::Findable
  include WpItem::Versionable
  include WpItem::Vulnerable
  include WpItem::Existable
  include WpItem::Infos
  include WpItem::Output

  attr_reader   :path
  attr_accessor :name, :wp_content_dir, :wp_plugins_dir

  def allowed_options
    [:name, :wp_content_dir, :wp_plugins_dir, :path, :version, :vulns_file]
  end

  # options :
  #   See allowed_options
  def initialize(target_base_uri, options = {})

    options[:wp_content_dir] ||= 'wp-content'
    options[:wp_plugins_dir] ||= options[:wp_content_dir] + '/plugins'

    set_options(options)
    forge_uri(target_base_uri)
  end

  def set_options(options)
    allowed_options.each do |allowed_option|
      if options.has_key?(allowed_option)
        method = :"#{allowed_option}="

        if self.respond_to?(method)
          self.send(method, options[allowed_option])
        else
          raise "#{self.class} does not respond to #{method}"
        end
      end
    end
  end
  private :set_options

  def forge_uri(target_base_uri)
    @uri = target_base_uri
  end

  def uri
    return path ? @uri.merge(path) : @uri
  end

  def url; uri.to_s end

  def path=(path)
    @path = URI.encode(
      path.gsub(/\$wp-plugins\$/i, wp_plugins_dir).gsub(/\$wp-content\$/i, wp_content_dir)
    )
  end

  def <=>(other)
    name <=> other.name
  end

  def ==(other)
    name === other.name
  end

  def ===(other)
    self == other && version === other.version
  end

end

module ShopifyAppMixins::SequelSessionStorage
  extend ActiveSupport::Concern

  class_methods do
    def store(session)
      shop = find_or_create shopify_domain: session.url do |shop|
        shop.shopify_token = session.token
      end
      shop.pk
    end

    def retrieve(pk)
      return unless pk
      if shop = self[pk]
        ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      end
    end
  end

  def with_shopify_session(&block)
    ShopifyAPI::Session.temp(shopify_domain, shopify_token, &block)
  end

  def connect
    session = ShopifyAPI::Session.new(shopify_domain, shopify_token)
    ShopifyAPI::Base.activate_session(session)
  end

  def metadata
    @metadata ||= ShopifyAPI::Shop.current
  end
end

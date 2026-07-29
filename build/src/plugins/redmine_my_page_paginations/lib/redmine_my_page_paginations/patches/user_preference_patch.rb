module RedmineMyPagePaginationLinks
  module Patches
    module UserPreferencePatch
      def my_page_pagination; self["my_page_pagination"] end
      def my_page_pagination=(value); self["my_page_pagination"]=value end

      def my_page_pagination_per_page(query)
        id = query.id ? "#{query.id}" : ::Digest::MD5.hexdigest(query.name)
        per_page = (self["my_page_pagination"] && self["my_page_pagination"].dig(id, "per_page").presence) || Setting.search_results_per_page
        per_page.to_i > 0 ? per_page.to_i : 10
      end

      def my_page_pagination_page(query)
        id = query.id ? "#{query.id}" : ::Digest::MD5.hexdigest(query.name)
        page = (self["my_page_pagination"] && self["my_page_pagination"].dig(id, "page"))
        page.to_i > 0 ? page.to_i : 1
      end
    end
  end
end

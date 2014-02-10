SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav nav-pills nav-stacked'
    if $settings.respond_to? :sidebar_links
      $settings.sidebar_links.each do |l, i|
        primary.item "sidebar_link_#{i}", l['text'], l['url']
      end
    end
  end
end

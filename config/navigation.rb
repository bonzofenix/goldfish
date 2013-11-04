SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav nav-pills nav-stacked'
    Category.all.each do |c|
      primary.item c.name.to_sym, c.name.capitalize, "/#{c.name}"
    end
  end
end

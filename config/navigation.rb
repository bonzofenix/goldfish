SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active' # sets selected tab/pill to .active class that Bootstrap uses navigation.active_leaf_class = 'active-leaf' # optional: an extra class simplnav applies changed for clarity
  navigation.items do |primary|
    primary.dom_class = 'nav nav-pills nav-stacked' # sets the containing ul class="nav nav tab" for Bootstrap primary.dom_id = 'nav-tabs' # optional: id set to "", this changed for clarity
    primary.item :about_me, 'About Me', '/'
    primary.item :trips, 'Trips', '/posts/trips'
    primary.item :technology, 'Technology', '/posts/technology'
    primary.item :music, 'Music', '/posts/music'
  end
end

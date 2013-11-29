
FactoryGirl.define do
  sequence(:title) {|n| "This is the post number #{n}" }
  sequence(:name) {|n| "tag_#{n}" }

  to_create do |instance|
    if !instance.save
      raise "Save failed for #{instance.class} error: #{instance.errors.map{|e| e.inspect}}"
    end
  end

  factory :post do
    title
    short_description 'this is a short description'
    content 'some content'
    publish true
    date Time.now
  end


  factory :tag do
    name
    trait :with_post do
      after :create do |tag|
        FactoryGirl.create_list :post, 1, tags: [ tag ]
      end
    end
  end
end

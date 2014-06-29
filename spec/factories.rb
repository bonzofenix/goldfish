
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
    content 'some content'
    publish true
    date Time.now

    trait :with_tag do
      after :create do |post|
        FactoryGirl.create_list :tag, 1, posts: [ post ]
      end
    end
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

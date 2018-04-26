FactoryGirl.define do
  factory :query do
    project
    media_cloud_url 'https://explorer.mediacloud.org/#/queries/search?q=[{"label":"health","q":"health","color":"%23e14c11","startDate":"2017-6-4","endDate":"2017-6-4","sources":[],"collections":[8875027]},{"label":"gender","q":"gender","color":"%2320b1b8","startDate":"2017-6-4","endDate":"2017-6-4","sources":[],"collections":[8875027]}]'
  end
end

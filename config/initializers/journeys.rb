require 'journeys'

Rails.application.config.after_initialize do
  Rails.application.reload_routes!
  JOURNEYS = Journeys.new(Rails.application.routes.url_helpers.methods) do
    at :will_it_work_for_me_submit,
       [:resident_last_12_months, :above_age_threshold] => :select_documents,
       [:resident_last_12_months] => :why_might_this_not_work_for_me,
       [:address_but_not_resident] => :may_not_work_if_you_live_overseas,
       [:no_uk_address] => :will_not_work_without_uk_address,
       [] => :why_might_this_not_work_for_me
  end
end

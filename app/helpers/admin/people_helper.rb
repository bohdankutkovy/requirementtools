module Admin::PeopleHelper

  def thumb_column(record, field)
    image_tag User.find_by_id(record[:id]).avatar.url(:thumb).to_s
  end

  def name_column(record, field)
    link_to User.find_by_id(record[:id]).name, profile_path(record[:id]), :target => "_blank"
  end






end
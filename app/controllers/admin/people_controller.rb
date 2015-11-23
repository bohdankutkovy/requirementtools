class Admin::PeopleController < ApplicationController

  before_filter :ensure_user_is_super_admin?
  before_filter :entry_accessed?, only: :index

  active_scaffold :user do |config|

    # Columns to show in view
    config.columns        = [:name, :email, :password, :password_confirmation, :is_super_admin, :is_active]
    config.create.columns = [:name, :email, :password, :password_confirmation, :is_super_admin, :assignments]
    config.update.columns = [:name, :email, :password, :password_confirmation, :is_super_admin, :is_active, :assignments]
    config.show.columns   = [:thumb, :name, :email, :is_super_admin, :is_active]
    config.list.columns   = [:name, :email, :is_super_admin, :is_active]

    # Excluding search
    config.actions.exclude(:search)

    columns[:password].form_ui = :password
    columns[:projects].form_ui = :select
    columns[:password_confirmation].form_ui = :password

    config.action_links.add :change_user_status, type: :member, crud_type: :update, method: :put, position: false
    config.delete.link = false
  end

  def change_user_status
    process_action_link_action do |record|
      record.status ? record.disable_account : record.activate_account
      record.save
    end
  end

  def conditions_for_collection
    if current_user
      user_email = current_user.email
      [ '\''+ user_email.to_s+'\''+'!= email']
    end
  end

end
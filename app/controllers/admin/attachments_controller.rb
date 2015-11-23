class Admin::AttachmentsController < ApplicationController
  before_filter :ensure_user_is_super_admin?
  before_filter :entry_accessed?

  active_scaffold :attachment do |config|
    config.list.columns   = [:file]
    config.create.columns = [:file]
    config.update.columns = [:file]

    config.actions.exclude(:search)
  end
end
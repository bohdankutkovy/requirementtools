class Attachment < ActiveRecord::Base
  mount_uploader :file, FileUploader

  belongs_to :requirement

  validate :file_size_validation
  validates_presence_of :file

  def authorized_for?(action)
    true if current_user.is_super_admin?
  end

  def name
    comp = File.basename file.to_s
    "#{comp}"
  end

  def file_size_validation
    errors[:file] << "should be less than 10MB" if file.size > 10.megabytes
  end

end

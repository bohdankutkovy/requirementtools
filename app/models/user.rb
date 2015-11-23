class User < ActiveRecord::Base
  before_save :check_password_changed
  mount_uploader :avatar, AvatarUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :confirmable# :validatable

  has_many :assignments, dependent: :destroy
  has_many :projects,    through: :assignments

  scope :is_active, -> {where(is_active: true) }

  validates_presence_of     :name, :email
  validates_uniqueness_of   :name, :email
  validates_format_of       :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
	validates_length_of       :password, in: 4..16, if: :password_required?
  validates_confirmation_of :password, if: :password_required?

  validates :avatar, file_size: { less_than: 5.megabytes }

  # validates_format_of :password, :with => /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?!.*(_|[^\w])).+$/, :multiline => true,
  #                                   :message => ": at least one number, letter, capital-case letter, no spaces or other special chars allowed!"

  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # new function to provide access to protected method unless_confirmed
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  def disable_account
    self.is_active = false
  end

  def activate_account
    self.is_active = true
  end

  def status
    is_active
  end

  def active_for_authentication?
    super && is_active
  end

  def authorized_for?(action)
    ![:delete].include?(action[:crud_type])
  end

  private

  def check_password_changed
    if self.sign_in_count != 0
      self.info_edited = true if changed.include? 'encrypted_password'
    end
  end

  protected

  def password_required?
   !persisted? || password.present? || password_confirmation.present?
  end

end

# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, :password, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  acts_as_tenant :court, optional: true

  encrypts :private_key

  def after_confirmation
    super
    generate_key_pair
    save!(validate: false)
  end

  def judge?
    role?('Judge')
  end

  def clerk?
    role?('Clerk')
  end

  def registrar?
    role?('Registrar')
  end

  def plaintiff?
    role?('Plaintiff')
  end

  def defendant?
    role?('Defendant')
  end

  def prosecutor?
    role?('Prosecutor')
  end

  def lawyer?
    role?('Lawyer')
  end

  def admin?
    role?('Admin')
  end

  def role?(role_name)
    cached_roles.include?(role_name)
  end

  private

  def cached_roles
    @cached_roles ||= roles.pluck(:name)
  end

  def generate_key_pair
    key_pair = EccKeyGenerator.generate
    self.public_key = key_pair[:public_key]
    self.private_key = key_pair[:private_key]
  end
end

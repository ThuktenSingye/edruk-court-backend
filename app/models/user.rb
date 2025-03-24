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

  private

  def generate_key_pair
    key_pair = EccKeyGenerator.generate
    self.public_key = key_pair[:public_key]
    self.private_key = key_pair[:private_key]
  end
end

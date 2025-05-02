# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  rolify

  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create

  has_one :profile, dependent: :destroy
  has_many :notifications, class_name: 'Noticed::Notification', as: :recipient, dependent: :destroy
  accepts_nested_attributes_for :profile

  after_create :generate_key_pair

  acts_as_tenant :court, optional: true

  encrypts :private_key

  ROLES = %w[Judge Clerk Registrar Plaintiff Defendant Prosecutor Lawyer Admin User].freeze

  def unread_notifications
    notifications.unread.newest_first.limit(20)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def mark_all_notifications_as_read
    notifications.unread.mark_as_read!
  end

  ROLES.each do |role|
    define_method(:"#{role.downcase}?") do
      role?(role)
    end
  end
  def role?(role_name)
    cached_roles.include?(role_name)
  end

  def accessible_court_ids
    if court.present?
      [court.id] + court.child_courts.where(court_type: :bench).pluck(:id)
    else
      []
    end
  end

  private

  def cached_roles
    @cached_roles ||= roles.pluck(:name)
  end

  def generate_key_pair
    key_pair = EccKeyGenerator.generate
    self.public_key = key_pair[:public_key]
    self.private_key = key_pair[:private_key]
    save!(validate: false)
  end
end

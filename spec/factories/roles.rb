# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { 'User' }
  end

  trait :admin_role do
    name { 'Admin' }
  end

  trait :judge_role do
    name { 'Judge' }
  end

  trait :clerk_role do
    name { 'Clerk' }
  end

  trait :registrar_role do
    name { 'Registrar' }
  end

  trait :plaintiff_role do
    name { 'Plaintiff' }
  end

  trait :defendant_role do
    name { 'Defendant' }
  end

  trait :lawyer_role do
    name { 'Lawyer' }
  end

  trait :prosecutor_role do
    name { 'Prosecutor' }
  end
end

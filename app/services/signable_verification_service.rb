# frozen_string_literal: true

# Service Class for signature verification
class SignableVerificationService
  attr_reader :errors

  SHA256_DIGEST = OpenSSL::Digest.new('SHA256')

  def initialize(court_case, signables, current_user)
    @court_case = court_case
    @signables = Array(signables)
    @current_user = current_user
    @errors = []
  end

  def verify_all
    @signables.all? { |signable| verify_signature(signable) }
  end

  private

  def verify_signature(signable)
    user = signer(signable)
    signature_record = signable.document_signatures.find_by(signer: user)
    return false unless signature_record

    perform_verification(signable, user, signature_record)
  end

  def perform_verification(signable, user, signature_record)
    public_key = user_public_key(user)
    hash_binary = [signable.hash_value].pack('H*')
    signature_binary = Base64.decode64(signature_record.signature_data)
    public_key.verify(SHA256_DIGEST, signature_binary, hash_binary)
  rescue StandardError => e
    @errors << "Verification error for signable ID #{signable.id}: #{e.message}"
    false
  end

  def user_public_key(user)
    return unless user

    OpenSSL::PKey::EC.new(user.public_key)
  end

  def signer(signable)
    if signable.hearing.blank? || signable.hearing.hearing_type&.name&.downcase == 'miscellaneous'
      pre_hearing_signer
    else
      post_hearing_signer
    end
  end

  def pre_hearing_signer
    return plaintiff_participant if @current_user.registrar?

    registrar_participant if @current_user.judge?
  end

  def post_hearing_signer
    return plaintiff_participant if @current_user.clerk?

    clerk_participant if @current_user.judge?
  end

  def plaintiff_participant
    participant = CaseParticipant.find_by(case_id: @court_case.id, role_id: plaintiff_roles_ids)
    User.unscoped.find_by(id: participant.user_id)
  end

  def clerk_participant
    participant = CaseParticipant.find_by(case_id: @court_case.id, role_id: Role.find_by(name: 'Clerk'))
    User.unscoped.find_by(id: participant.user_id).first
  end

  def registrar_participant
    User.unscoped.where(court_id: @court_case.court_id).with_role(:Registrar).first
  end

  def defendant_participant
    participant = CaseParticipant.find_by(case_id: @court_case.id, role_id: Role.find_by(name: 'Defendant'))
    User.unscoped.find_by(id: participant.user_id).first
  end

  def plaintiff_roles_ids
    Role.where(name: %w[Prosecutor Plaintiff Lawyer]).pluck(:id)
  end
end

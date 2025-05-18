# frozen_string_literal: true

# Service class for document/evidence/attachment signing
# rubocop:disable Metrics/ClassLength
class SignableSigningService
  attr_reader :errors

  SHA256_DIGEST = OpenSSL::Digest.new('SHA256')

  def initialize(court_case, signables, current_user)
    @court_case = court_case
    @signables = Array(signables)
    @current_user = current_user
    @errors = []
  end

  def sign_all
    return false if @signables.blank?

    @signables.all? { |signable| sign(signable) }
  end

  private

  def sign(signable)
    return false unless valid?(signable)

    perform_signing(signable)
  rescue StandardError => e
    @errors << "Failed to Sign: #{e.message}"
    false
  end

  def perform_signing(signable)
    ActiveRecord::Base.transaction do
      signable_hash = ensure_hash_value(signable)
      signature = sign_hash(signable_hash)
      success = create_signature_record(signable, signature)
      raise ActiveRecord::Rollback unless success
      binding.pry
      update_document(signable)
      true
    end
  end

  def valid?(signable)
    attached_file = attached_file_type(signable)
    unless attached_file&.attached?
      @errors << 'Invalid File: file not attached'
      return false
    end
    true
  end

  def ensure_hash_value(signable)
    return signable.hash_value if signable.hash_value.present?

    hash = compute_hash(attached_file_type(signable))
    signable.update!(hash_value: hash)
    hash
  end

  def create_signature_record(signable, signature)
    signer = find_signer
    unless signer
      @errors << 'Current user is not a participant in the case'
      return false
    end

    signable.document_signatures.create!(
      signature_data: signature,
      signed_at: Time.current,
      signer: signer
    )
  end

  def compute_hash(attachment)
    blob = attachment.blob

    if blob.byte_size < 10.megabytes
      SHA256_DIGEST.hexdigest(blob.download)
    else
      update_hash_in_chunks(blob, sha256)
      SHA256_DIGEST.hexdigest
    end
  end

  def update_hash_in_chunks(blob, sha256)
    blob.open do |file|
      while (chunk = file.read(5.megabytes))
        sha256.update(chunk)
      end
    end
  end

  def attached_file_type(signable)
    if signable.respond_to?(:document)
      signable.document
    elsif signable.respond_to?(:evidence)
      signable.evidence
    end
  end

  def sign_hash(hash_value)
    private_key = user_private_key
    binary_hash = [hash_value].pack('H*')
    signature = private_key.sign(SHA256_DIGEST, binary_hash)
    Base64.strict_encode64(signature)
  end

  def update_document(signable)
    if @current_user.registrar?
      update_document_status(signable)
    else
      case user_role
      when 'clerk'
        update_document_status(signable)
      when 'judge'
        update_verified_document(signable)
      else
        update_signed_document(signable)
      end
    end
  end

  def update_signed_document(signable)
    if signable.hearing.present?
      if signable.hearing.hearing_type&.name&.downcase == 'withdraw'
        role = user_role
        plaintiff = find_user(plaintiff_role_id)
        defendant = find_user(defendant_role_id)
        if %w[plaintiff prosecutor].include?(role)
          if signable.document_signatures.exists?(signer: defendant)
            signable.update!(document_status: :signed)
          end
        else
          if signable.document_signatures.exists?(signer: plaintiff)
            signable.update!(document_status: :signed)
          end
        end
      else
        # Previously in the `if` block
        signable.update!(document_status: :signed)
      end
    else
      signable.update!(document_status: :signed)
    end
  end

  def update_document_status(signable)
    signable.update!(document_status: :verified)
  end

  def update_verified_document(signable)
    signable.update!(verified_at: Time.current, verified_by_judge: true)
  end

  def plaintiff_role_id
    Role.find_by(name: 'Plaintiff').id || Role.find_by(name: 'Prosecutor').id
  end

  def defendant_role_id
    Role.find_by(name: 'Defendant').id
  end

  def user_role
    participant = CaseParticipant.find_by(user_id: @current_user.id, case_id: @court_case.id)
    participant.role&.name&.downcase
  end

  def find_user(role_id)
    participant = @court_case.case_participants.find_by(role_id: role_id)
    participant&.user
  end


  def find_signer
    if @current_user.registrar?
      @current_user
    else
      participant = @court_case.case_participants.find_by(user_id: @current_user.id)
      participant&.user
    end
  end

  def user_private_key
    OpenSSL::PKey::EC.new(@current_user.private_key)
  end
  # rubocop:enable Metrics/ClassLength
end

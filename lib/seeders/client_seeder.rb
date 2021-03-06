require 'open-uri'

# This seeding process was wrapped in a class to make it testable
# We have discussed the potential of regulalry updating our services from a remote service
# It is important to make these scripts testable and robust for future use.
class ClientSeeder
  def initialize(filepath)
    @csv_data = begin
      body = open(filepath).read
      CSV.parse(body, headers: :first_row, encoding: 'UTF-8')
    rescue Errno::ENOENT
      puts 'Didn\'t find file'
      []
    end
  end

  def import
    @failures = ''
    @csv_data.each do |row|
      import_client(row)
    end
    puts "@failures #{@failures}"
  end

  def import_client(row) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    # OK for 100 or so clients
    client = Client.find_or_initialize_by(first_name: row['First Name'], last_name: row['Surname'], imported: true)

    puts "importing #{client.name}"
    puts 'updating existing record' if client.id
    email = row['Email Address']

    if row['Email Address'].blank?
      @failures << "Not importing #{row['First Name']} #{row['Surname']} without an Email Address\n"
    elsif row['Contact Number'].blank?
      @failures << "Not importing #{row['First Name']} #{row['Surname']} without a Phone Number\n"
    else
      puts "email #{email}"
      begin
        client.tap do |c|
          c.consent_given = true
          c.advisor_id = row['Advisor']
          c.phone = row['Contact Number']
          c.address_line_1 = row['Address line 1']
          c.address_line_2 = row['Address line 2']
          c.postcode = row['Postcode']
          c.login = UserLogin.new(email: email.downcase, password: Devise.friendly_token.first(20)) if c.login.blank?
          c.rag_status = row['Current Status (RAGG)'].try(:downcase).try(:strip) || :un_assessed
          c.gender = row['Gender']
          c.receive_benefits = row['Receiving benefits?']
          c.studying = work_out_boolean(row['Currently studying?'])
          c.employed = work_out_boolean(row['Currently employed?'])
          c.health_condition = row['Any health conditions?']&.capitalize
          c.assessment_notes = generate_assessment_notes(row) if c.assessment_notes.empty?
        end

        # not all have email addresses
        client.save!
        puts row['Date of Registration']
        client.update_attribute(:created_at, row['Date of Registration']) if row['Date of Registration']
      rescue ActiveRecord::RecordInvalid => e
        @failures << "error thrown importing #{client.name} #{e}\n"
        # client.save(validate: false)
      end
    end
  end

  private

  def work_out_boolean(value)
    return if value.blank?
    case value.downcase
    when 'yes'
      true
    when 'no'
      false
    end
  end

  def generate_assessment_notes(row)
    notes = []
    notes << AssessmentNote.new(content_key: 'job_goal_1', content: row['Job Goal 1']) if row['Job Goal 1'].present?
    notes << AssessmentNote.new(content_key: 'job_goal_2', content: row['Job Goal 2']) if row['Job Goal 2'].present?
    notes << AssessmentNote.new(content_key: 'general', content: row['Notes']) if row['Notes'].present?
    notes
  end
end

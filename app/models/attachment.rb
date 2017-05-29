class Attachment < ApplicationRecord

  after_create :queue_processing

  def queue_processing
    AttachmentJob.perform_later self
  end

  def upload
    process!
  end

  def salesforce_client
    client = Restforce.new(username: ENV['USERNAME'],
                           password: ENV['PASSWORD'],
                           security_token: ENV['SECURITY_TOKEN'] || '',
                           client_id: ENV['CLIENT_ID'],
                           client_secret: ENV['CLIENT_SECRET'],
                           api_version: '38.0')
    client
  end

  def tmp_file(filename)
    Dir.mktmpdir 'download' do |dir|
      File.open(File.join(dir, self.class.escape_filename(filename)), 'wb+') do |file|
        yield file
      end
    end
  end

  def download
    attachment = salesforce_client.query("select Id, Name, Body from Attachment where Id = '#{sfid}'").first
    return if attachment.nil?
    tmp_file(self.class.escape_filename(attachment.Name)) do |file|
      file.write(attachment.Body)
      file.rewind
      yield file
    end
  end

  def process!
    download do |file|
      Net::SFTP.start(ENV['HOST'], ENV['SFTP_USERNAME'], password: ENV['SFTP_PASSWORD']) do |sftp|
        puts file.inspect
        sftp.upload!(file.path, "/root/#{File.basename(file.path)}")
      end
    end
  end

  def self.test
    Net::SFTP.start(ENV['HOST'], ENV['SFTP_USERNAME'], password: ENV['SFTP_PASSWORD']) do |sftp|
      sftp.upload!(File.join(Rails.root, 'public','404.html'), '/root/404.html')
    end
  end


  def self.escape_filename(filename)
    ext = File.extname(filename)
    return filename.parameterize if ext.blank?
    [
        File.basename(filename, ext).parameterize,
        '.' + ext[1..-1].parameterize
    ].join('')
  end
end

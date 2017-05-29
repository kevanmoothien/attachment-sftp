class AttachmentJob < ApplicationJob
  queue_as :default

  def perform(attachment)
    attachment.upload
  end
end

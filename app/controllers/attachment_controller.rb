class AttachmentController < ApplicationController
  def index
    render json: Attachment.all
  end

  def create
    attachment = Attachment.create! sfid: params[:sfid], processed: false

    render json: attachment
  end
end

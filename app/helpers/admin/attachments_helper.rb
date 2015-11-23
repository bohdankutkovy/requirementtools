module Admin::AttachmentsHelper

  def file_column(record, field)
    comp = File.basename record.file.to_s
    link_to comp, record.file.to_s
  end


end
require_dependency 'attachment'

module RedmineLightbox2
  module AttachmentsPatch
    def download_inline
      find_attachment
      file_readable
      read_authorize

      send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                :type => detect_content_type(@attachment),
                :disposition => 'inline'
    end
  end
end

Paperclip::Attachment.default_options.merge!(
  :url  => "/system/:class/:id_partition/:style/:basename.:extension",
  :path => ":rails_root/public/system/:class/:id_partition/:style/:basename.:extension",
  
  :convert_options => { :all => "-quality 100" }
)

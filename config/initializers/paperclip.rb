Paperclip::Attachment.default_options.merge!(
  :convert_options => { :all => "-quality 100" }
)

if Rails::Config[:s3]
  Paperclip::Attachment.default_options.merge!(
    :storage => :s3,
    :s3_protocol => 'https',

    :s3_credentials => {
      :access_key_id      => Rails::Config.s3.access_key,
      :secret_access_key  => Rails::Config.s3.secret
    },
    :bucket => Rails::Config.s3.bucket,
    
    :s3_headers => { 'Expires' => 1.year.from_now.httpdate },
    
    :path => ":class/:id_partition/:style.:extension",
    :url  => ":class/:id_partition/:style.:extension"
  )
else
  Paperclip::Attachment.default_options.merge!(
    :url  => "/system/:class/:id_partition/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:id_partition/:style/:basename.:extension"
  )
end
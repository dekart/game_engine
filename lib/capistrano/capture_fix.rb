# Fixes problem with 'capture' method being improperly delegated to Kernel. More details here:
# https://github.com/capistrano/capistrano/issues/168

Capistrano::Configuration::Namespaces::Namespace.class_eval do
  def capture(*args)
    parent.capture *args
  end
end
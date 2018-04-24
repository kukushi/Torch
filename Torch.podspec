Pod::Spec.new do |s|

  s.name         = "Torch"
  s.version      = "0.4.0"
  s.summary      = "A lightweight Swift Cache"

  s.description  = <<-DESC
  					Lily provide swifty way API for lightweight data cache.
                   DESC

  s.homepage     = "https://github.com/kukushi/Torch"
  s.license      = "MIT"
  s.author             = { "Xing He" => "" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/kukushi/Torch.git", :tag => s.version }
  s.source_files  = "Classes", "Classes/**/*.{h,m}", "Torch/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true

end
